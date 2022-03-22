import { Cardano } from '@cardano-sdk/core';
import { serializeError } from 'serialize-error';
import { txSubmitHttpProvider } from '../../src';
import got from 'got';

const url = 'http://some-hostname:3000';

describe('txSubmitHttpProvider', () => {
  describe('healthCheck', () => {
    it('is not ok if cannot connect', async () => {
      const provider = txSubmitHttpProvider({ url });
      await expect(provider.healthCheck()).resolves.toEqual({ ok: false });
    });
    describe('mocked', () => {
      beforeAll(() => {
        jest.mock('got');
      });

      afterAll(() => {
        jest.unmock('got');
      });

      it('is ok if 200 response body is { ok: true }', async () => {
        got.get = jest.fn().mockResolvedValue({ body: JSON.stringify({ ok: true }) });
        const provider = txSubmitHttpProvider({ url });
        await expect(provider.healthCheck()).resolves.toEqual({ ok: true });
      });

      it('is not ok if 200 response body is { ok: false }', async () => {
        got.get = jest.fn().mockResolvedValue({ body: JSON.stringify({ ok: false }) });
        const provider = txSubmitHttpProvider({ url });
        await expect(provider.healthCheck()).resolves.toEqual({ ok: false });
      });
    });
  });
  describe('submitTx', () => {
    it('resolves if successful', async () => {
      got.post = jest.fn().mockResolvedValue('');
      const provider = txSubmitHttpProvider({ url });
      await expect(provider.submitTx(new Uint8Array())).resolves;
    });
    it('rehydrates errors, although only as base Error class', async () => {
      const errors = [new Cardano.TxSubmissionErrors.BadInputsError({ badInputs: [] })];
      try {
        got.post = jest.fn().mockRejectedValue({
          response: {
            body: JSON.stringify(errors.map((e) => serializeError(e)))
          }
        });
        const provider = txSubmitHttpProvider({ url });
        await provider.submitTx(new Uint8Array());
        throw new Error('fail');
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } catch (error: any) {
        // https://github.com/sindresorhus/serialize-error/issues/48
        // expect(error[0]).toBeInstanceOf(Cardano.TxSubmissionErrors.BadInputsError);
        expect(error[0]).toBeInstanceOf(Error);
        expect(error[0].name).toBe('BadInputsError');
      }
    });
  });
});
