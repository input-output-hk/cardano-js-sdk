/* eslint-disable @typescript-eslint/no-explicit-any */
import * as envalid from 'envalid';
import { Cardano } from '@cardano-sdk/core';
import { ChildProcess, fork } from 'child_process';
import { InitializeTxResult, ObservableWallet, SingleAddressWallet } from '@cardano-sdk/wallet';
import { ServiceNames } from '@cardano-sdk/cardano-services';
import {
  assetProviderFactory,
  chainHistoryProviderFactory,
  getLogger,
  keyAgentById,
  networkInfoProviderFactory,
  rewardsProviderFactory,
  stakePoolProviderFactory,
  txSubmitProviderFactory,
  utxoProviderFactory
} from '../../../src/factories';
import { filter, firstValueFrom } from 'rxjs';
import { removeRabbitMQContainer, setupRabbitMQContainer } from '../../../../rabbitmq/test/jest-setup/docker';
import JSONBig from 'json-bigint';
import path from 'path';

// Verify environment.
export const env = envalid.cleanEnv(process.env, {
  ASSET_PROVIDER: envalid.str(),
  ASSET_PROVIDER_PARAMS: envalid.json({ default: {} }),
  CHAIN_HISTORY_PROVIDER: envalid.str(),
  CHAIN_HISTORY_PROVIDER_PARAMS: envalid.json({ default: {} }),
  KEY_MANAGEMENT_PARAMS: envalid.json({ default: {} }),
  KEY_MANAGEMENT_PROVIDER: envalid.str(),
  LOGGER_MIN_SEVERITY: envalid.str({ default: 'info' }),
  NETWORK_INFO_PROVIDER: envalid.str(),
  NETWORK_INFO_PROVIDER_PARAMS: envalid.json({ default: {} }),
  OGMIOS_URL: envalid.str(),
  RABBITMQ_URL: envalid.url(),
  REWARDS_PROVIDER: envalid.str(),
  REWARDS_PROVIDER_PARAMS: envalid.json({ default: {} }),
  STAKE_POOL_PROVIDER: envalid.str(),
  STAKE_POOL_PROVIDER_PARAMS: envalid.json({ default: {} }),
  START_LOCAL_HTTP_SERVER: envalid.bool(),
  TRANSACTIONS_NUMBER: envalid.num(),
  TX_SUBMIT_HTTP_URL: envalid.str(),
  TX_SUBMIT_PROVIDER: envalid.str(),
  TX_SUBMIT_PROVIDER_PARAMS: envalid.json({ default: {} }),
  UTXO_PROVIDER: envalid.str(),
  UTXO_PROVIDER_PARAMS: envalid.json({ default: {} }),
  WORKER_PARALLEL_TRANSACTION: envalid.num()
});

interface TestOptions {
  directlyToOgmios?: boolean;
  parallel?: boolean;
  withRunningWorker?: boolean;
}

interface TestReport extends TestOptions {
  timeBeforeSubmitTxs: number;
  timeAfterWorkerStarted: number;
  timeAfterTxsInMempool: number;
  timeAfterTxsInBlockchain: number;
}

const containerName = 'rabbitmq-load-test';

const logger = getLogger(env.LOGGER_MIN_SEVERITY);

const commonArgs = [
  '--logger-min-severity',
  'info',
  '--ogmios-url',
  env.OGMIOS_URL,
  '--rabbitmq-url',
  env.RABBITMQ_URL
];

const getWallet = async () =>
  new SingleAddressWallet(
    { name: 'Test Wallet' },
    {
      assetProvider: await assetProviderFactory.create(env.ASSET_PROVIDER, env.ASSET_PROVIDER_PARAMS),
      chainHistoryProvider: await chainHistoryProviderFactory.create(
        env.CHAIN_HISTORY_PROVIDER,
        env.CHAIN_HISTORY_PROVIDER_PARAMS
      ),
      keyAgent: await keyAgentById(0, env.KEY_MANAGEMENT_PROVIDER, env.KEY_MANAGEMENT_PARAMS),
      networkInfoProvider: await networkInfoProviderFactory.create(
        env.NETWORK_INFO_PROVIDER,
        env.NETWORK_INFO_PROVIDER_PARAMS
      ),
      rewardsProvider: await rewardsProviderFactory.create(env.REWARDS_PROVIDER, env.REWARDS_PROVIDER_PARAMS),
      stakePoolProvider: await stakePoolProviderFactory.create(env.STAKE_POOL_PROVIDER, env.STAKE_POOL_PROVIDER_PARAMS),
      txSubmitProvider: await txSubmitProviderFactory.create(env.TX_SUBMIT_PROVIDER, env.TX_SUBMIT_PROVIDER_PARAMS),
      utxoProvider: await utxoProviderFactory.create(env.UTXO_PROVIDER, env.UTXO_PROVIDER_PARAMS)
    }
  );

const runCli = (args: string[], startedString: string) =>
  new Promise<ChildProcess>((resolve, reject) => {
    const proc = fork(path.join(__dirname, '..', '..', '..', '..', 'cardano-services', 'dist', 'cjs', 'cli.js'), args, {
      stdio: 'pipe'
    });

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
        env.TX_SUBMIT_HTTP_URL,
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

    logger.debug('Waiting to settle wallet status');
    await firstValueFrom(wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)));
    logger.debug('Wallet status settled');
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
      logger.info('Fragmentation completed');
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
    const { directlyToOgmios, parallel, withRunningWorker } = options;
    const submitPromises: Promise<void>[] = [];
    const txIds: Cardano.TransactionId[] = [];
    let timeAfterWorkerStarted = 0;
    let timeBeforeSubmitTxs = 0;

    try {
      logger.debug(`Starting test with options: ${JSON.stringify({ directlyToOgmios, parallel, withRunningWorker })}`);

      await fragmentWhenRequired(options);

      const startWorkerForTest = async () => {
        if (!directlyToOgmios) await startWorker(options);
        timeAfterWorkerStarted = Date.now();
      };

      const finalizeAndSubmit = async (tx: InitializeTxResult) => {
        try {
          await wallet.submitTx(await wallet.finalizeTx(tx));
        } catch (error) {
          logger.error(JSONBig.stringify(tx), error);
          throw error;
        }
      };

      const submitTransactions = async () => {
        timeBeforeSubmitTxs = Date.now();
        for (let i = 0; i < env.TRANSACTIONS_NUMBER; ++i) {
          const coins = 1_000_000n + 1000n * BigInt(i);
          const tx = await wallet.initializeTx({ outputs: new Set([{ address, value: { coins } }]) });

          submitPromises.push(finalizeAndSubmit(tx));
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

      await expect(Promise.all(submitPromises)).resolves.not.toThrow();
      const timeAfterTxsInMempool = Date.now();

      await Promise.all(txIds.map((txId) => waitForTxInBlockchain(txId)));

      testReports.push({
        ...options,
        timeAfterTxsInBlockchain: Date.now(),
        timeAfterTxsInMempool,
        timeAfterWorkerStarted,
        timeBeforeSubmitTxs
      });

      logger.debug(`Completed test with options: ${JSON.stringify({ directlyToOgmios, parallel, withRunningWorker })}`);
    } catch (error) {
      logger.error(
        `Failed test with options: ${JSON.stringify({ directlyToOgmios, parallel, withRunningWorker })}`,
        error
      );
    }
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
