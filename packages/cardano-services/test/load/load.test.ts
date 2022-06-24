import * as envalid from 'envalid';
import { Cardano } from '@cardano-sdk/core';
import { ChildProcess, fork } from 'child_process';
import { ObservableWallet, SingleAddressWallet } from '@cardano-sdk/wallet';
import { ServiceNames } from '../../src';
import {
  assetProvider,
  chainHistoryProvider,
  env as configEnv,
  keyAgentByIdx,
  logger,
  networkInfoProvider,
  rewardsProvider,
  stakePoolProvider,
  txSubmitProvider,
  utxoProvider
} from '../../../wallet/test/e2e/config';
import { filter, firstValueFrom } from 'rxjs';
import { removeRabbitMQContainer, setupRabbitMQContainer } from '../../../rabbitmq/test/jest-setup/docker';
import path from 'path';

interface TestOptions {
  directlyToOgmios?: boolean;
  parallel?: boolean;
  withRunningWorker?: boolean;
}

interface TestReport extends TestOptions {
  timeBeforeSubmitTxs: number;
  timeAfterWorkerStarted: number;
  timeAfterTxsInMempool: number; // TODO: will work after https://input-output.atlassian.net/browse/ADP-1823
  timeAfterTxsInBlockchain: number;
}

const containerName = 'rabbitmq-load-test';

export const env = envalid.cleanEnv(process.env, {
  RABBITMQ_URL: envalid.url(),
  START_LOCAL_HTTP_SERVER: envalid.bool(),
  TRANSACTIONS_NUMBER: envalid.num(),
  WORKER_PARALLEL_TRANSACTION: envalid.num()
});

const commonArgs = [
  '--logger-min-severity',
  'info',
  '--ogmios-url',
  configEnv.OGMIOS_URL,
  '--rabbitmq-url',
  env.RABBITMQ_URL
];

const getWallet = async () =>
  new SingleAddressWallet(
    { name: 'Test Wallet' },
    {
      assetProvider: await assetProvider,
      chainHistoryProvider: await chainHistoryProvider,
      keyAgent: await keyAgentByIdx(0),
      networkInfoProvider: await networkInfoProvider,
      rewardsProvider: await rewardsProvider,
      stakePoolProvider,
      txSubmitProvider: await txSubmitProvider,
      utxoProvider: await utxoProvider
    }
  );

const runCli = (args: string[], startedString: string) =>
  new Promise<ChildProcess>((resolve, reject) => {
    const proc = fork(path.join(__dirname, '..', '..', 'dist', 'cjs', 'cli.js'), args, { stdio: 'pipe' });

    const logChunk = (method: typeof logger.info, chunk: string) => {
      for (const line of chunk.split('\n')) {
        if (line) {
          let msg = line;

          try {
            ({ msg } = JSON.parse(line));
            // eslint-disable-next-line no-empty
          } catch {}

          method(`${args[0]}: ${msg}`);
        }
      }
    };

    proc.stderr!.once('data', (data) => reject(new Error(data.toString())));
    proc.stderr!.on('data', (data) => logChunk(logger.error.bind(logger), data.toString()));
    proc.stdout!.on('data', (data) => {
      const chunk = data.toString();

      logChunk(logger.info.bind(logger), chunk);
      if (chunk.includes(startedString)) resolve(proc);
    });
    proc.once('error', reject);
  });

const stopProc = (proc: ChildProcess) =>
  new Promise<void>((resolve) => (proc?.kill() ? proc.on('close', resolve) : resolve()));

let serverProc: ChildProcess;
let workerProc: ChildProcess;

const startServer = async (options: TestOptions = {}) => {
  await setupRabbitMQContainer(containerName);
  if (env.START_LOCAL_HTTP_SERVER)
    serverProc = await runCli(
      [
        'start-server',
        '--api-url',
        configEnv.TX_SUBMIT_HTTP_URL,
        ...(options.directlyToOgmios ? [] : ['--use-queue']),
        ...commonArgs,
        ServiceNames.TxSubmit
      ],
      '"msg":"Started'
    );
};

const startWorker = async (options: TestOptions = {}) => {
  workerProc = await runCli(
    [
      'start-worker',
      ...commonArgs,
      ...(options.parallel ? ['--parallel', '--parallel-txs', env.WORKER_PARALLEL_TRANSACTION.toString()] : [])
    ],
    '"msg":"TxSubmitWorker: starting'
  );
};

const stopServer = () => stopProc(serverProc);
const stopWorker = () => stopProc(workerProc);

describe('load', () => {
  const testReports: TestReport[] = [];

  let wallet: ObservableWallet;
  let address: Cardano.Address;

  const prepareWallets = async () => {
    wallet = await getWallet();
    ({ address } = (await firstValueFrom(wallet.addresses$))[0]);

    await firstValueFrom(wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)));
  };

  const waitForTxInBlockchain = (txId: Cardano.TransactionId) =>
    firstValueFrom(wallet.transactions.history$.pipe(filter((txs) => txs.filter((tx) => tx.id === txId).length === 1)));

  const fragmentWhenRequired = async (options: TestOptions) => {
    const utxo = await firstValueFrom(wallet.utxo.available$);
    const coins = 1_000_000n + 1000n * BigInt(env.TRANSACTIONS_NUMBER - 1);
    const requiredUtxo = env.TRANSACTIONS_NUMBER * 3 + 1;
    const suitableUtxo = utxo.filter(([, txOut]) => txOut.value.coins >= coins);
    const haveEnoughUtxo = suitableUtxo.length >= requiredUtxo;

    if (haveEnoughUtxo) return;

    const fragment = async () => {
      const output = { address, value: { coins } };
      const tx = await wallet.initializeTx({
        // eslint-disable-next-line unicorn/no-new-array
        outputs: new Set([...new Array(requiredUtxo)].map((_) => ({ ...output })))
      });

      logger.info(`Fragmentation tx: ${tx.hash}`);

      await wallet.submitTx(await wallet.finalizeTx(tx));
      await waitForTxInBlockchain(tx.hash);
    };

    if (options.directlyToOgmios) await fragment();
    else {
      await Promise.all([startWorker(), fragment()]);
      await stopWorker();
    }
  };

  beforeAll(async () => {
    jest.setTimeout(180_000);

    await startServer({ directlyToOgmios: true });
    await prepareWallets();
  });

  afterAll(async () => {
    for (const report of testReports) {
      const {
        directlyToOgmios,
        parallel,
        withRunningWorker,
        timeAfterTxsInBlockchain,
        timeAfterTxsInMempool,
        timeAfterWorkerStarted,
        timeBeforeSubmitTxs
      } = report;

      const timeReport =
        directlyToOgmios || withRunningWorker
          ? `submission   -> mempool: ${timeAfterTxsInMempool - timeBeforeSubmitTxs}ms`
          : `start worker -> mempool: ${timeAfterTxsInMempool - timeAfterWorkerStarted}ms`;

      const workerDescription = `with${withRunningWorker ? '   ' : 'out'} running ${
        parallel ? 'parallel' : 'serial  '
      } worker`;

      logger.info(
        `     ${
          directlyToOgmios ? 'directly to ogmios             ' : workerDescription
        } - ${timeReport} - mempool -> blockchain: ${timeAfterTxsInBlockchain - timeAfterTxsInMempool}ms     `
      );
    }

    wallet.shutdown();

    // Dependencies teardown parallelization
    await Promise.all([removeRabbitMQContainer(containerName), stopServer()]);
  });

  afterEach(stopWorker);

  const performTest = async (options: TestOptions) => {
    const { directlyToOgmios, withRunningWorker } = options;
    const submitPromises: Promise<void>[] = [];
    const txIds: Cardano.TransactionId[] = [];
    let timeAfterWorkerStarted = 0;
    let timeBeforeSubmitTxs = 0;

    await fragmentWhenRequired(options);

    const startWorkerForTest = async () => {
      if (!directlyToOgmios) await startWorker(options);
      timeAfterWorkerStarted = Date.now();
    };

    const submitTransactions = async () => {
      timeBeforeSubmitTxs = Date.now();
      for (let i = 0; i < env.TRANSACTIONS_NUMBER; ++i) {
        const coins = 1_000_000n + 1000n * BigInt(i);
        const tx = await wallet.initializeTx({ outputs: new Set([{ address, value: { coins } }]) });

        submitPromises.push(wallet.submitTx(await wallet.finalizeTx(tx)));
        txIds.push(tx.hash);
      }
    };

    if (withRunningWorker) {
      await startWorkerForTest();
      await submitTransactions();
    } else {
      await submitTransactions();
      await startWorkerForTest();
    }

    await Promise.all(submitPromises);
    const timeAfterTxsInMempool = Date.now();

    await Promise.all(txIds.map((txId) => waitForTxInBlockchain(txId)));

    testReports.push({
      ...options,
      timeAfterTxsInBlockchain: Date.now(),
      timeAfterTxsInMempool,
      timeAfterWorkerStarted,
      timeBeforeSubmitTxs
    });
  };

  describe('directly to ogmios', () => {
    afterAll(stopServer);

    it('without queue', async () => await performTest({ directlyToOgmios: true }));
  });

  describe('using queue', () => {
    beforeAll(() => startServer({}));

    it('without running serial worker', async () => await performTest({}));
    it('with running serial worker', async () => await performTest({ withRunningWorker: true }));
    it('without running parallel worker', async () => await performTest({ parallel: true }));
    it('with running parallel worker', async () => await performTest({ parallel: true, withRunningWorker: true }));
  });
});
