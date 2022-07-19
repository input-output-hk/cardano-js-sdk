/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  BAD_CONNECTION_URL,
  GOOD_CONNECTION_URL,
  enqueueFakeTx,
  removeAllQueues,
  testLogger,
  txsPromise
} from './utils';
import { CONNECTION_ERROR_EVENT, RabbitMqTxSubmitProvider, TxSubmitWorker } from '../src';
import { Cardano, ProviderError, TxSubmitProvider } from '@cardano-sdk/core';
import { createMockOgmiosServer, listenPromise, serverClosePromise } from '../../ogmios/test/mocks/mockOgmiosServer';
import { getRandomPort } from 'get-port-please';
import { ogmiosTxSubmitProvider, urlToConnectionConfig } from '@cardano-sdk/ogmios';
import http from 'http';

describe('TxSubmitWorker', () => {
  let logger: ReturnType<typeof testLogger>;
  let mock: http.Server | undefined;
  let port: number;
  let txSubmitProvider: TxSubmitProvider;
  let worker: TxSubmitWorker | undefined;

  beforeAll(async () => {
    port = await getRandomPort();
    txSubmitProvider = ogmiosTxSubmitProvider(urlToConnectionConfig(new URL(`http://localhost:${port}/`)));
  });

  beforeEach(async () => {
    await removeAllQueues();
    logger = testLogger();
  });

  afterEach(async () => {
    if (mock) {
      await serverClosePromise(mock);
      mock = undefined;
    }

    if (worker) {
      await worker.stop();
      worker = undefined;
    }

    // Uncomment this to have evidence of all the log messages
    // console.log(logger.messages);
  });

  it('is safe to call stop method on an idle worker', async () => {
    worker = new TxSubmitWorker({ rabbitmqUrl: GOOD_CONNECTION_URL }, { logger, txSubmitProvider });

    expect(worker).toBeInstanceOf(TxSubmitWorker);
    expect(worker.getStatus()).toEqual('idle');
    expect(await worker.stop()).toBeUndefined();
    expect(worker.getStatus()).toEqual('idle');
  });

  it('rejects if the TxSubmitProvider is unhealthy on start', async () => {
    mock = createMockOgmiosServer({
      healthCheck: { response: { networkSynchronization: 0.8, success: true } },
      submitTx: { response: { success: true } }
    });

    await listenPromise(mock, port);

    worker = new TxSubmitWorker({ rabbitmqUrl: GOOD_CONNECTION_URL }, { logger, txSubmitProvider });

    await expect(worker.start()).rejects.toBeInstanceOf(ProviderError);
  });

  it('rejects if unable to connect to the RabbitMQ broker', async () => {
    mock = createMockOgmiosServer({
      healthCheck: { response: { networkSynchronization: 1, success: true } },
      submitTx: { response: { success: true } }
    });

    await listenPromise(mock, port);

    worker = new TxSubmitWorker({ rabbitmqUrl: BAD_CONNECTION_URL }, { logger, txSubmitProvider });

    await expect(worker.start()).rejects.toBeInstanceOf(ProviderError);
  });

  it('emits event if unable to connect to the RabbitMQ broker', async () => {
    expect.assertions(1);
    mock = createMockOgmiosServer({
      healthCheck: { response: { networkSynchronization: 1, success: true } },
      submitTx: { response: { success: true } }
    });

    await listenPromise(mock, port);

    worker = new TxSubmitWorker({ rabbitmqUrl: BAD_CONNECTION_URL }, { logger, txSubmitProvider });
    const emitEventSpy = jest.spyOn(worker, 'emitEvent');

    try {
      await worker.start();
    } catch (error: any) {
      expect(emitEventSpy).toHaveBeenCalledWith(CONNECTION_ERROR_EVENT, error.innerError);
    }
  });

  describe('error while tx submission', () => {
    describe('tx submission is retried if the error is retiable', () => {
      // eslint-disable-next-line unicorn/consistent-function-scoping
      const performTest = async (options: { parallel: boolean }) => {
        const spy = jest.fn();
        let hookAlreadyCalled = false;
        let successMockListenPromise = Promise.resolve<http.Server>(new http.Server());
        let successMock = new http.Server();

        const failMock = createMockOgmiosServer({
          healthCheck: { response: { networkSynchronization: 1, success: true } },
          submitTx: { response: { failWith: { type: 'beforeValidityInterval' }, success: false } },
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
        await worker.start();

        await new Promise<void>((resolve) => {
          successMock = createMockOgmiosServer({
            healthCheck: { response: { networkSynchronization: 1, success: true } },
            submitTx: { response: { success: true } },
            submitTxHook: () => {
              spy();
              // Once the transaction is submitted with success we can stop the worker
              // We wait half a second to be sure the tx is submitted only once
              setTimeout(() => {
                resolve();
              }, 500);
            }
          });
        });

        // All these Promises are the return value of async functions called in a not async context,
        // we need to await for them to perform a correct test teardown
        await Promise.all([successMockListenPromise, providerClosePromise, serverClosePromise(successMock)]);
        expect(spy).toBeCalledTimes(1);
      };

      it('when configured to process jobs serially', async () => performTest({ parallel: false }));
      it('when configured to process jobs in parallel', async () => performTest({ parallel: true }));
    });

    describe('the error is propagated to RabbitMqTxSubmitProvider', () => {
      // eslint-disable-next-line unicorn/consistent-function-scoping
      const performTest = async (options: { parallel: boolean }) => {
        mock = createMockOgmiosServer({
          healthCheck: { response: { networkSynchronization: 1, success: true } },
          submitTx: { response: { failWith: { type: 'eraMismatch' }, success: false } }
        });

        // Start the mock
        await listenPromise(mock, port);

        // Actually create the TxSubmitWorker
        worker = new TxSubmitWorker(
          { pollingCycle: 50, rabbitmqUrl: GOOD_CONNECTION_URL, ...options },
          { logger, txSubmitProvider }
        );
        await worker.start();

        // Tx submission by RabbitMqTxSubmitProvider must reject with the same error got by TxSubmitWorker
        await expect(enqueueFakeTx(0, logger)).rejects.toBeInstanceOf(Cardano.TxSubmissionErrors.EraMismatchError);
      };

      it('when configured to process jobs serially', async () => performTest({ parallel: false }));
      it('when configured to process jobs in parallel', async () => performTest({ parallel: true }));
    });
  });

  it('submission is parallelized up to parallelTx Tx simultaneously', async () => {
    const txs = await txsPromise;
    const delays = [5, 2, 1, 3, 3, 4, 4];

    mock = createMockOgmiosServer({
      healthCheck: { response: { networkSynchronization: 1, success: true } },
      submitTx: { response: { success: true } },
      submitTxHook: async (data) => {
        const txBody = Buffer.from(data!).toString('hex');
        const txIdx = (() => {
          for (let i = 0; i < txs.length; ++i) if (txBody === txs[i].txBodyHex) return i;
        })();

        // Wait 100ms * the first byte of the Tx before sending the result
        // eslint-disable-next-line @typescript-eslint/no-shadow
        await new Promise((resolve) => setTimeout(resolve, 100 * delays[txIdx!]));
      }
    });

    await listenPromise(mock, port);

    worker = new TxSubmitWorker(
      { parallel: true, parallelTxs: 4, rabbitmqUrl: GOOD_CONNECTION_URL },
      { logger, txSubmitProvider }
    );
    await worker.start();

    const rabbitMqTxSubmitProvider = new RabbitMqTxSubmitProvider({ rabbitmqUrl: GOOD_CONNECTION_URL });

    /*
     * Tx submission plan, time sample: 100ms
     * 11111
     * 226666
     * 3555
     * 4447777
     */

    const promises: Promise<void>[] = [];
    const result = [undefined, undefined, undefined, undefined, undefined, undefined, undefined];

    for (let i = 0; i < 7; ++i) {
      promises.push(rabbitMqTxSubmitProvider.submitTx(txs[i].txBodyUint8Array));
      // Wait 10ms to be sure the transactions are enqueued in the right order
      await new Promise((resolve) => setTimeout(resolve, 10));
    }

    await expect(Promise.all(promises)).resolves.toEqual(result);

    await rabbitMqTxSubmitProvider.close();

    // We check only the relevant messages
    expect(
      logger.messages
        .filter(({ level }) => level === 'debug')
        .filter(({ message }) => typeof message[0] === 'string' && message[0].match(/(tx #\d dump)|ACKing RabbitMQ/))
        .map(({ message }) => message)
        .map((message) => (message.length === 2 ? [message[0]] : message))
    ).toEqual([
      ['TxSubmitWorker: tx #1 dump:'],
      ['TxSubmitWorker: tx #2 dump:'],
      ['TxSubmitWorker: tx #3 dump:'],
      ['TxSubmitWorker: tx #4 dump:'],
      ['TxSubmitWorker: ACKing RabbitMQ message #3'],
      ['TxSubmitWorker: tx #5 dump:'],
      ['TxSubmitWorker: ACKing RabbitMQ message #2'],
      ['TxSubmitWorker: tx #6 dump:'],
      ['TxSubmitWorker: ACKing RabbitMQ message #4'],
      ['TxSubmitWorker: tx #7 dump:'],
      ['TxSubmitWorker: ACKing RabbitMQ message #5'],
      ['TxSubmitWorker: ACKing RabbitMQ message #1'],
      ['TxSubmitWorker: ACKing RabbitMQ message #6'],
      ['TxSubmitWorker: ACKing RabbitMQ message #7']
    ]);
  });
});
