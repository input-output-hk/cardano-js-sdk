import { BAD_CONNECTION_URL, txsPromise } from './utils';
import { Cardano, ProviderError } from '@cardano-sdk/core';
import { OgmiosTxSubmitProvider, urlToConnectionConfig } from '@cardano-sdk/ogmios';
import { RabbitMQContainer } from './docker';
import { RabbitMqTxSubmitProvider, TxSubmitWorker } from '../../../src';
import { TestLogger, createLogger } from '@cardano-sdk/util-dev';
import {
  createMockOgmiosServer,
  listenPromise,
  serverClosePromise
} from '../../../../ogmios/test/mocks/mockOgmiosServer';
import { getRandomPort } from 'get-port-please';
import http from 'http';

describe('TxSubmitWorker', () => {
  const container = new RabbitMQContainer();

  let logger: TestLogger;
  let mock: http.Server | undefined;
  let port: number;
  let rabbitmqUrl: URL;
  let txSubmitProvider: OgmiosTxSubmitProvider;
  let worker: TxSubmitWorker | undefined;

  beforeAll(async () => {
    ({ rabbitmqUrl } = await container.load());
    port = await getRandomPort();
  });

  beforeEach(async () => {
    await container.removeQueues();
    logger = createLogger({ record: true });
    txSubmitProvider = new OgmiosTxSubmitProvider(urlToConnectionConfig(new URL(`http://localhost:${port}/`)), logger);
  });

  afterEach(async () => {
    if (worker) {
      await worker.shutdown();
      worker = undefined;
    }

    if (mock) {
      await serverClosePromise(mock);
      mock = undefined;
    }

    // Uncomment this to have evidence of all the log messages
    // console.log(logger.messages);
  });

  it('is safe to call stop method on an idle worker', async () => {
    worker = new TxSubmitWorker({ rabbitmqUrl }, { logger, txSubmitProvider });

    expect(worker).toBeInstanceOf(TxSubmitWorker);
    expect(worker.getStatus()).toEqual('idle');
    expect(await worker.shutdown()).toBeUndefined();
    expect(worker.getStatus()).toEqual('idle');
  });

  it('rejects if the TxSubmitProvider is unhealthy on start', async () => {
    mock = createMockOgmiosServer({
      healthCheck: { response: { networkSynchronization: 0.8, success: true } },
      submitTx: { response: { success: true } }
    });

    await listenPromise(mock, port);
    worker = new TxSubmitWorker({ rabbitmqUrl }, { logger, txSubmitProvider });
    await expect(worker.start()).rejects.toBeInstanceOf(ProviderError);
  });

  it('resolves and emits a connection error event if unable to connect to the RabbitMQ broker', async () => {
    expect.assertions(2);
    mock = createMockOgmiosServer({
      healthCheck: { response: { networkSynchronization: 1, success: true } },
      submitTx: { response: { success: true } }
    });

    await listenPromise(mock, port);

    worker = new TxSubmitWorker({ rabbitmqUrl: BAD_CONNECTION_URL }, { logger, txSubmitProvider });
    const emitEventSpy = jest.spyOn(worker, 'emitEvent');

    await expect(worker.start()).resolves.toBeUndefined();
    expect(emitEventSpy).toHaveBeenCalledTimes(1);
  });

  describe('error while tx submission', () => {
    describe('tx submission is retried if the error is retryable', () => {
      // eslint-disable-next-line unicorn/consistent-function-scoping
      const performTest = async (options: { parallel: boolean }) => {
        const spy = jest.fn();

        // We mock ogmios server to fail at the first call, then to answer with success at second
        mock = createMockOgmiosServer({
          healthCheck: { response: { networkSynchronization: 1, success: true } },
          submitTx: { response: [{ failWith: { type: 'beforeValidityInterval' }, success: false }, { success: true }] },
          submitTxHook: () => {
            spy();
          }
        });

        // Start a failing ogmios server
        await listenPromise(mock, port);

        // Actually create the TxSubmitWorker
        worker = new TxSubmitWorker({ rabbitmqUrl, ...options }, { logger, txSubmitProvider });
        await worker.start();

        // Enqueue a tx
        await container.enqueueTx(logger);

        // We assert that tx submission is invoked two times if the error is retryable
        expect(spy).toBeCalledTimes(2);
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
        worker = new TxSubmitWorker({ pollingCycle: 50, rabbitmqUrl, ...options }, { logger, txSubmitProvider });
        await worker.start();

        // Tx submission by RabbitMqTxSubmitProvider must reject with the same error got by TxSubmitWorker
        await expect(container.enqueueTx(logger, 0)).rejects.toBeInstanceOf(
          Cardano.TxSubmissionErrors.EraMismatchError
        );
      };

      it('when configured to process jobs serially', async () => performTest({ parallel: false }));
      it('when configured to process jobs in parallel', async () => performTest({ parallel: true }));
    });
  });

  // This test is failing with "Long running" Ogmios client connection.
  it('submission is parallelized up to parallelTx Tx simultaneously', async () => {
    const txs = await txsPromise;
    const delays = [5, 2, 1, 3, 3, 4, 4];
    let resolveSubmissionDelay: (value: unknown) => void;

    mock = createMockOgmiosServer({
      healthCheck: { response: { networkSynchronization: 1, success: true } },
      submitTx: { response: { success: true } },
      submitTxHook: async (data) => {
        // To be sure the transactions are enqueued in the right order,
        // immediately resolve the submission delay promise
        resolveSubmissionDelay(null);

        const txBody = Buffer.from(data!).toString('hex');
        const txIdx = (() => {
          for (let i = 0; i < txs.length; ++i) if (txBody === txs[i].txBodyHex) return i;
        })();

        // To respect the submission plan,
        // wait the scheduled interval (time unit: 100ms) before sending the result
        // eslint-disable-next-line @typescript-eslint/no-shadow
        await new Promise((resolve) => setTimeout(resolve, 100 * delays[txIdx!]));
      }
    });

    await listenPromise(mock, port);

    worker = new TxSubmitWorker({ parallel: true, parallelTxs: 4, rabbitmqUrl }, { logger, txSubmitProvider });
    await worker.start();

    const rabbitMqTxSubmitProvider = new RabbitMqTxSubmitProvider({ rabbitmqUrl }, { logger });

    /*
     * Tx submission plan, time sample: 100ms
     * 11111
     * 226666
     * 3555
     * 4447777
     */

    const promises: Promise<void>[] = [];
    const result = [undefined, undefined, undefined, undefined, undefined, undefined, undefined];
    let res: unknown = null;

    for (let i = 0; i < 7; ++i) {
      // To be sure resolveSubmissionDelay is correctly set when the mock runs,
      // create the promise before the submission
      // eslint-disable-next-line no-loop-func
      const submissionDelay = new Promise((resolve) => (resolveSubmissionDelay = resolve));

      promises.push(rabbitMqTxSubmitProvider.submitTx({ signedTransaction: txs[i].txBodyHex }));

      // To be sure the transactions are enqueued in the right order,
      // wait until the tx is accepted by the mock before proceeding with the next submission
      // eslint-disable-next-line no-loop-func
      await submissionDelay;
    }

    try {
      res = await Promise.all(promises);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      expect(error.innerError).toBeUndefined();
      expect(error).toBeUndefined();
    }

    expect(res).toEqual(result);

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
