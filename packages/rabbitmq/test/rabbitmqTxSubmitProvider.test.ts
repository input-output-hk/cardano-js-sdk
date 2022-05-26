import { BAD_CONNECTION_URL, GOOD_CONNECTION_URL } from './utils';
import { ProviderError, TxSubmitProvider } from '@cardano-sdk/core';
import { RabbitMqTxSubmitProvider } from '../src';

describe('RabbitMqTxSubmitProvider', () => {
  let provider: TxSubmitProvider;

  afterEach(() => provider?.close!());

  describe('healthCheck', () => {
    it('is not ok if cannot connect', async () => {
      provider = new RabbitMqTxSubmitProvider(BAD_CONNECTION_URL);
      const res = await provider.healthCheck();
      expect(res).toEqual({ ok: false });
    });

    it('is ok if can connect', async () => {
      provider = new RabbitMqTxSubmitProvider(GOOD_CONNECTION_URL);
      const resA = await provider.healthCheck();
      // Call again to cover the idemopotent RabbitMqTxSubmitProvider.#connectAndCreateChannel() operation
      const resB = await provider.healthCheck();
      expect(resA).toEqual({ ok: true });
      expect(resB).toEqual({ ok: true });
    });
  });

  const performSubmitTxTest = async (connectionURL: URL) => {
    try {
      provider = new RabbitMqTxSubmitProvider(connectionURL);
      const resA = await provider.submitTx(new Uint8Array());
      // Called again to cover the idemopotent RabbitMqTxSubmitProvider.#ensureQueue() operation
      const resB = await provider.submitTx(new Uint8Array());
      expect(resA).toBeUndefined();
      expect(resB).toBeUndefined();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      expect(error.innerError).toBeInstanceOf(ProviderError);
    }
  };

  describe('submitTx', () => {
    it('resolves if successful', async () => {
      expect.assertions(2);
      await performSubmitTxTest(GOOD_CONNECTION_URL);
    });

    it('rejects with errors thrown by the service', async () => {
      expect.assertions(1);
      await performSubmitTxTest(BAD_CONNECTION_URL);
    });
  });
});
