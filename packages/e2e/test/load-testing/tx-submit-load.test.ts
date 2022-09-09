/* eslint-disable @typescript-eslint/no-explicit-any */
import * as envalid from 'envalid';
import { Cardano } from '@cardano-sdk/core';
import { ChildProcess, fork } from 'child_process';
import { InitializeTxResult, ObservableWallet } from '@cardano-sdk/wallet';
import { RabbitMQContainer } from '../../../cardano-services/test/TxSubmit/rabbitmq/docker';
import { ServiceNames } from '@cardano-sdk/cardano-services';
import { createLogger } from '@cardano-sdk/util-dev';
import { filter, firstValueFrom } from 'rxjs';
import { getWallet } from '../../src/factories';
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

interface TestWallet {
  address: Cardano.Address;
  coins: bigint;
  wallet: ObservableWallet;
}

const logger = createLogger({ env: process.env.TL_LEVEL ? process.env : { ...process.env, TL_LEVEL: 'info' } });

let commonArgs: string[];

const runCli = (args: string[], startedString: string) =>
  new Promise<ChildProcess>((resolve, reject) => {
    const proc = fork(path.join(__dirname, '..', '..', '..', 'cardano-services', 'dist', 'cjs', 'cli.js'), args, {
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

          if (!msg.includes('\u001B[')) method(`${args[0]}: ${msg}`);
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

let rabbitmqUrl: URL;
let serverProc: ChildProcess;
let workerProc: ChildProcess;

const startServer = async (options: TestOptions = {}) => {
  if (env.START_LOCAL_HTTP_SERVER)
    serverProc = await runCli(
      [
        'start-server',
        '--api-url',
        env.TX_SUBMIT_HTTP_URL,
        ...(options.directlyToOgmios ? [] : ['--use-queue', 'true']),
        ...commonArgs,
        ServiceNames.TxSubmit
      ],
      '[HttpServer] Started'
    );
};

const startWorker = async (options: TestOptions = {}) => {
  workerProc = await runCli(
    [
      'start-worker',
      ...commonArgs,
      ...(options.parallel ? ['--parallel', 'true', '--parallel-txs', env.WORKER_PARALLEL_TRANSACTION.toString()] : [])
    ],
    '"msg":"TxSubmitWorker: starting'
  );
};

const stopServer = () => stopProc(serverProc);
const stopWorker = () => stopProc(workerProc);

const grace = (time: number) => `${time.toString().padStart(5, ' ')}ms`;

const waitForTxInBlockchain = async (wallet: ObservableWallet, txId: Cardano.TransactionId) => {
  logger.info(`Waiting for tx ${txId} in blockchain...`);
  await firstValueFrom(
    wallet.transactions.history$.pipe(filter((txs) => txs.filter((tx) => tx.id === txId).length === 1))
  );
  logger.info(`Tx ${txId} in blockchain`);
};

describe('load', () => {
  const container = new RabbitMQContainer('rabbitmq-load-test');
  const testReports: TestReport[] = [];
  const testWallets: TestWallet[] = [];

  const prepareWallet = async (idx: number) => {
    const { wallet } = await getWallet({ env, idx, logger, name: `Test Wallet ${idx}` });
    const { address } = (await firstValueFrom(wallet.addresses$))[0];
    logger.info(`Got wallet idx: ${idx} - address: ${address}`);

    logger.debug(`Waiting to settle wallet ${idx} status`);
    await firstValueFrom(wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)));
    logger.debug(`Wallet ${idx} status settled`);

    testWallets.push({ address, coins: 0n, wallet });
  };

  const prepareWallets = async () => {
    const promises: Promise<void>[] = [];

    logger.info('Preparing wallets...');

    for (let i = 0; i <= env.TRANSACTIONS_NUMBER; ++i) promises.push(prepareWallet(i));

    await Promise.all(promises);

    logger.info('Wallets prepared');
  };

  const refreshWallets = async () => {
    for (const testWallet of testWallets)
      testWallet.coins = (await firstValueFrom(testWallet.wallet.balance.utxo.available$)).coins;

    // Sort wallets from the one with the highest coins to the one with the lower
    testWallets.sort((a, b) => Number(b.coins - a.coins));
  };

  const fragmentWhenRequired = async (options: TestOptions) => {
    await refreshWallets();

    const toRefill: Cardano.Address[] = [];
    const { wallet } = testWallets[0];

    // Skip the last one as it is the target wallet, so it don't need coins enough
    for (let i = 0; i < env.TRANSACTIONS_NUMBER; ++i)
      if (testWallets[i].coins < 2_000_000n) toRefill.push(testWallets[i].address);

    if (toRefill.length === 0) {
      logger.info('Fragmentation tx not required');

      return;
    }

    const coins = testWallets[0].coins / BigInt(toRefill.length + 1);

    if (coins < 2_000_000n) throw new Error('Not enough coins to perform the test');

    const fragment = async () => {
      const tx = await wallet.initializeTx({
        outputs: new Set(toRefill.map((address) => ({ address, value: { coins } })))
      });

      logger.info(`Fragmentation tx: ${tx.hash}`);
      await wallet.submitTx(await wallet.finalizeTx({ tx }));
      await waitForTxInBlockchain(wallet, tx.hash);
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

    ({ rabbitmqUrl } = await container.start());

    commonArgs = [
      '--logger-min-severity',
      'debug',
      '--ogmios-url',
      env.OGMIOS_URL,
      '--rabbitmq-url',
      rabbitmqUrl.toString()
    ];

    await startServer({ directlyToOgmios: true });
    await prepareWallets();
  });

  afterAll(async () => {
    logger.info('    Test result');

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
          ? `submission   -> mempool: ${grace(timeAfterTxsInMempool - timeBeforeSubmitTxs)}`
          : `start worker -> mempool: ${grace(timeAfterTxsInMempool - timeAfterWorkerStarted)}`;

      const workerDescription = `with${withRunningWorker ? '   ' : 'out'} running ${
        parallel ? 'parallel' : 'serial  '
      } worker`;

      logger.info(
        `  ${
          directlyToOgmios ? 'directly to ogmios             ' : workerDescription
        } - ${timeReport} - mempool -> blockchain: ${grace(
          timeAfterTxsInBlockchain - timeAfterTxsInMempool
        )} - total: ${grace(timeAfterTxsInBlockchain - timeBeforeSubmitTxs)}`
      );
    }

    for (const { wallet } of testWallets) wallet.shutdown();

    // Dependencies teardown parallelization
    await Promise.all([container.stop(), stopServer()]);
  });

  afterEach(stopWorker);

  const performTest = async (options: TestOptions) => {
    const { directlyToOgmios, parallel, withRunningWorker } = options;
    const submitPromises: Promise<void>[] = [];
    const txIds: Cardano.TransactionId[] = [];
    let timeAfterWorkerStarted = 0;
    let timeBeforeSubmitTxs = 0;

    try {
      logger.info(`Starting test with options: ${JSON.stringify({ directlyToOgmios, parallel, withRunningWorker })}`);

      await fragmentWhenRequired(options);

      const startWorkerForTest = async () => {
        if (!directlyToOgmios) await startWorker(options);
        timeAfterWorkerStarted = Date.now();
      };

      const finalizeAndSubmit = async (wallet: ObservableWallet, tx: InitializeTxResult) => {
        try {
          await wallet.submitTx(await wallet.finalizeTx({ tx }));
          logger.info(`Submitted tx: ${tx.hash}`);
        } catch (error) {
          logger.error(JSONBig.stringify(tx), error);
          throw error;
        }
      };

      const submitTransactions = async () => {
        const { address } = testWallets[env.TRANSACTIONS_NUMBER];

        timeBeforeSubmitTxs = Date.now();

        for (let i = 0; i < env.TRANSACTIONS_NUMBER; ++i) {
          const { wallet } = testWallets[i];
          const coins = 1_000_000n + 1000n * BigInt(i);
          const tx = await wallet.initializeTx({ outputs: new Set([{ address, value: { coins } }]) });
          logger.info(`Initializing tx idx ${i}: ${tx.hash}`);

          submitPromises.push(finalizeAndSubmit(wallet, tx));
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

      await Promise.all(txIds.map((txId, i) => waitForTxInBlockchain(testWallets[i].wallet, txId)));

      testReports.push({
        ...options,
        timeAfterTxsInBlockchain: Date.now(),
        timeAfterTxsInMempool,
        timeAfterWorkerStarted,
        timeBeforeSubmitTxs
      });

      logger.info(`Completed test with options: ${JSON.stringify({ directlyToOgmios, parallel, withRunningWorker })}`);
    } catch (error) {
      logger.error(
        `Failed test with options: ${JSON.stringify({ directlyToOgmios, parallel, withRunningWorker })}`,
        error
      );
    }
  };

  describe('directly to ogmios', () => {
    afterAll(stopServer);

    it('without queue', async () => {
      if (env.TRANSACTIONS_NUMBER < 30) await performTest({ directlyToOgmios: true });
      else logger.info('Skipping directly to ogmios test due to transaction number > 30');
    });
  });

  describe('using queue', () => {
    beforeAll(() => startServer({}));

    it('without running serial worker', async () => await performTest({}));
    it('with running serial worker', async () => await performTest({ withRunningWorker: true }));
    it('without running parallel worker', async () => await performTest({ parallel: true }));
    it('with running parallel worker', async () => await performTest({ parallel: true, withRunningWorker: true }));
  });
});
