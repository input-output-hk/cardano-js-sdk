import { BAD_CONNECTION_URL, GOOD_CONNECTION_URL, enqueueFakeTx, removeAllMessagesFromQueue } from './utils';
import { TxSubmitProvider } from '@cardano-sdk/core';
import { TxSubmitWorker } from '../src';
import {
  createMockOgmiosServer,
  listenPromise,
  serverClosePromise
} from '@cardano-sdk/ogmios/test/mocks/mockOgmiosServer';
import { dummyLogger } from 'ts-log';
import { getRandomPort } from 'get-port-please';
import { ogmiosTxSubmitProvider, urlToConnectionConfig } from '@cardano-sdk/ogmios';
import { removeRabbitMQContainer, setupRabbitMQContainer } from './jest-setup/docker';
import http from 'http';

const logger = dummyLogger;

describe('TxSubmitWorker', () => {
  let txSubmitProvider: TxSubmitProvider;
  let port: number;

  beforeAll(async () => {
    port = await getRandomPort();
    txSubmitProvider = ogmiosTxSubmitProvider(urlToConnectionConfig(new URL(`http://localhost:${port}/`)));
  });

  it('is safe to call stop method on an idle worker', async () => {
    const worker = new TxSubmitWorker({ rabbitmqUrl: GOOD_CONNECTION_URL }, { logger, txSubmitProvider });

    expect(worker).toBeInstanceOf(TxSubmitWorker);
    expect(worker.getStatus()).toEqual('idle');
    expect(await worker.stop()).toBeUndefined();
    expect(worker.getStatus()).toEqual('idle');
  });

  it('rejects if the TxSubmitProvider is unhealthy on start', async () => {
    const worker = new TxSubmitWorker({ rabbitmqUrl: GOOD_CONNECTION_URL }, { logger, txSubmitProvider });

    const unhealthyMock = createMockOgmiosServer({
      healthCheck: { response: { networkSynchronization: 0.8, success: true } },
      submitTx: { response: { success: true } }
    });

    await listenPromise(unhealthyMock, port);

    try {
      const res = await worker.start();
      expect(res).toBeDefined();
    } catch (error) {
      expect(error).toBeDefined();
    }

    await serverClosePromise(unhealthyMock);
  });

  it('rejects if unable to connect to the RabbitMQ broker', async () => {
    const worker = new TxSubmitWorker({ rabbitmqUrl: BAD_CONNECTION_URL }, { logger, txSubmitProvider });
    const healthyMock = createMockOgmiosServer({
      healthCheck: { response: { networkSynchronization: 1, success: true } },
      submitTx: { response: { success: true } }
    });

    await listenPromise(healthyMock, port);

    try {
      const res = await worker.start();
      expect(res).toBeDefined();
    } catch (error) {
      expect(error).toBeDefined();
    }

    await serverClosePromise(healthyMock);
  });

  describe('RabbitMQ connection failure while running', () => {
    const CONTAINER_NAME = 'cardano-rabbitmq-local-test';

    const performTest = async (options: { parallel: boolean }) => {
      const healthyMock = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 1, success: true } },
        submitTx: { response: { success: true } }
      });

      await listenPromise(healthyMock, port);

      // Set up a new RabbitMQ container to test TxSubmitWorker on RabbitMQ server shut down
      const rabbitmqPort = await getRandomPort();
      await setupRabbitMQContainer(CONTAINER_NAME, rabbitmqPort);

      // Actually create the TxSubmitWorker
      const worker = new TxSubmitWorker(
        { rabbitmqUrl: new URL(`amqp://localhost:${rabbitmqPort}`), ...options },
        { logger, txSubmitProvider }
      );
      const startPromise = worker.start();

      // Wait until the worker is connected to the RabbitMQ server
      await new Promise<void>(async (resolve) => {
        // eslint-disable-next-line @typescript-eslint/no-shadow
        while (worker.getStatus() === 'connecting') await new Promise((resolve) => setTimeout(resolve, 50));
        resolve();
      });

      // Stop the RabbitMQ container while the TxSubmitWorker is connected
      const removeContainerPromise = removeRabbitMQContainer(CONTAINER_NAME);
      const innerMessage = "CONNECTION_FORCED - broker forced connection closure with reason 'shutdown'";
      const fullMessage = `Connection closed: 320 (CONNECTION-FORCED) with message "${innerMessage}"`;

      // Test the TxSubmitWorker actually exits with error
      await expect(startPromise).rejects.toThrow(new Error(fullMessage));

      // Test teardown
      await serverClosePromise(healthyMock);
      await removeContainerPromise;
    };

    it('rejects when configured to process jobs serially', async () => await performTest({ parallel: false }), 20_000);
    it(
      'rejects when configured to process jobs in parallel',
      async () => await performTest({ parallel: true }),
      20_000
    );
  });

  describe('tx submission is retried until success', () => {
    // First of all we need to remove from the queue every message sent by previous tests/suites
    beforeAll(removeAllMessagesFromQueue);

    // eslint-disable-next-line unicorn/consistent-function-scoping
    const performTest = async (options: { parallel: boolean }) => {
      const spy = jest.fn();
      let hookAlreadyCalled = false;
      let successMockListenPromise = Promise.resolve<http.Server>(new http.Server());
      let stopPromise = Promise.resolve();
      // eslint-disable-next-line prefer-const
      let worker: TxSubmitWorker;

      const successMock = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 1, success: true } },
        submitTx: { response: { success: true } },
        submitTxHook: () => {
          spy();
          // Once the transaction is submitted with success we can stop the worker
          // We wait half a second to be ensure the tx is submitted only once
          setTimeout(() => (stopPromise = worker.stop()), 500);
        }
      });

      const failMock = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 1, success: true } },
        submitTx: { response: { failWith: { type: 'eraMismatch' }, success: false } },
        submitTxHook: () => {
          // eslint-disable-next-line @typescript-eslint/no-floating-promises
          (async () => {
            if (hookAlreadyCalled) return;

            // This hook may be called multple times... ensure the core is executed only once
            hookAlreadyCalled = true;

            // Stop the failing mock and start the succes one
            await serverClosePromise(failMock);
            successMockListenPromise = listenPromise(successMock, port);
          })();
        }
      });

      // Start a failing ogmios server
      await listenPromise(failMock, port);

      // Enqueue a tx
      const providerClosePromise = enqueueFakeTx();

      // Actually create the TxSubmitWorker
      worker = new TxSubmitWorker({ rabbitmqUrl: GOOD_CONNECTION_URL, ...options }, { logger, txSubmitProvider });
      const startPromise = worker.start();

      await expect(startPromise).resolves.toEqual(undefined);
      await serverClosePromise(successMock);
      // All these Promises are the return value of async functions called in a not async context,
      // we need to await for them to perform a correct test teardown
      await Promise.all([stopPromise, successMockListenPromise, providerClosePromise]);
      expect(spy).toBeCalledTimes(1);
    };

    it('when configured to process jobs serially', async () => performTest({ parallel: false }));
    it('when configured to process jobs in parallel', async () => performTest({ parallel: true }));
  });

  it('submission is parallelized up to parallelTx Tx simultaneously', async () => {
    // First of all we need to remove from the queue every message sent by previous tests/suites
    await removeAllMessagesFromQueue();

    let stopPromise = Promise.resolve();

    const loggedMessages: unknown[][] = [];
    const testLogger = {
      debug: (...args: unknown[]) => loggedMessages.push(args),
      error: jest.fn(),
      info: jest.fn(),
      trace: jest.fn(),
      warn: jest.fn()
    };

    const worker = new TxSubmitWorker(
      { parallel: true, parallelTxs: 4, rabbitmqUrl: GOOD_CONNECTION_URL },
      { logger: testLogger, txSubmitProvider }
    );

    const mock = createMockOgmiosServer({
      healthCheck: { response: { networkSynchronization: 1, success: true } },
      submitTx: { response: { success: true } },
      submitTxHook: async (data) => {
        // Wait 100ms * the first byte of the Tx before sending the result
        await new Promise((resolve) => setTimeout(resolve, 100 * data![0]));
        // Exit condition: a Tx with length === 2
        if (data?.length === 2) stopPromise = worker.stop();
      }
    });

    await listenPromise(mock, port);

    /*
     * Tx submission plan, time sample: 100ms
     * 11111
     * 226666
     * 3555
     * 4447777
     */
    await enqueueFakeTx([5]);
    await enqueueFakeTx([2]);
    await enqueueFakeTx([1]);
    await enqueueFakeTx([3]);
    await enqueueFakeTx([3]);
    await enqueueFakeTx([4]);
    await enqueueFakeTx([4, 0]);

    await expect(worker.start()).resolves.toEqual(undefined);
    await Promise.all([stopPromise, serverClosePromise(mock)]);

    // We check only the relevant messages
    expect(loggedMessages.filter(([_]) => typeof _ === 'string' && _.match(/(tx \d dump)|ACKing RabbitMQ/))).toEqual([
      ['TxSubmitWorker: tx 1 dump:', '05'],
      ['TxSubmitWorker: tx 2 dump:', '02'],
      ['TxSubmitWorker: tx 3 dump:', '01'],
      ['TxSubmitWorker: tx 4 dump:', '03'],
      ['TxSubmitWorker: ACKing RabbitMQ message 3'],
      ['TxSubmitWorker: tx 5 dump:', '03'],
      ['TxSubmitWorker: ACKing RabbitMQ message 2'],
      ['TxSubmitWorker: tx 6 dump:', '04'],
      ['TxSubmitWorker: ACKing RabbitMQ message 4'],
      ['TxSubmitWorker: tx 7 dump:', '0400'],
      ['TxSubmitWorker: ACKing RabbitMQ message 5'],
      ['TxSubmitWorker: ACKing RabbitMQ message 1'],
      ['TxSubmitWorker: ACKing RabbitMQ message 6'],
      ['TxSubmitWorker: ACKing RabbitMQ message 7']
    ]);
  });
});
