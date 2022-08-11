import { BAD_CONNECTION_URL, txsPromise } from './utils';
import { ProviderError, TxSubmitProvider } from '@cardano-sdk/core';
import { RabbitMQContainer } from './docker';
import { RabbitMqTxSubmitProvider, TxSubmitWorker } from '../src';
import { logger } from '@cardano-sdk/util-dev';

describe('RabbitMqTxSubmitProvider', () => {
  const container = new RabbitMQContainer();

  let provider: TxSubmitProvider | undefined;
  let rabbitmqUrl: URL;

  beforeAll(async () => {
    ({ rabbitmqUrl } = await container.load());
  });

  beforeEach(async () => {
    await container.removeQueues();
  });

  afterEach(async () => {
    if (provider) {
      await provider.close!();
      provider = undefined;
    }
  });

  describe('healthCheck', () => {
    it('is not ok if cannot connect', async () => {
      provider = new RabbitMqTxSubmitProvider({ rabbitmqUrl: BAD_CONNECTION_URL }, { logger });
      const res = await provider.healthCheck();
      expect(res).toEqual({ ok: false });
    });

    it('is ok if can connect', async () => {
      provider = new RabbitMqTxSubmitProvider({ rabbitmqUrl }, { logger });
      const resA = await provider.healthCheck();
      // Call again to cover the idempotent RabbitMqTxSubmitProvider.#connectAndCreateChannel() operation
      const resB = await provider.healthCheck();
      expect(resA).toEqual({ ok: true });
      expect(resB).toEqual({ ok: true });
    });
  });

  describe('submitTx', () => {
    // eslint-disable-next-line unicorn/consistent-function-scoping
    const performTest = async (url: URL) => {
      try {
        const txs = await txsPromise;
        provider = new RabbitMqTxSubmitProvider({ rabbitmqUrl: url }, { logger });
        const resA = await provider.submitTx(txs[0].txBodyUint8Array);
        // Called again to cover the idempotent RabbitMqTxSubmitProvider.#ensureQueue() operation
        const resB = await provider.submitTx(txs[1].txBodyUint8Array);
        expect(resA).toBeUndefined();
        expect(resB).toBeUndefined();
      } catch (error) {
        expect((error as ProviderError).innerError).toBeInstanceOf(ProviderError);
      }
    };

    it('resolves if successful', async () => {
      const worker = new TxSubmitWorker(
        { parallel: true, rabbitmqUrl },
        { logger, txSubmitProvider: { healthCheck: async () => ({ ok: true }), submitTx: () => Promise.resolve() } }
      );

      expect.assertions(2);
      await worker.start();
      await performTest(rabbitmqUrl);
      await worker.stop();
    });

    it('rejects with errors thrown by the service', async () => {
      expect.assertions(1);
      await performTest(BAD_CONNECTION_URL);
    });
  });
});
