import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { serializeError } from 'serialize-error';
import { txSubmitHttpProvider } from '../../src';
import got, { HTTPError, Response } from 'got';

const url = 'http://some-hostname:3000';

describe('txSubmitHttpProvider', () => {
  describe('healthCheck', () => {
    it('is not ok if cannot connect', async () => {
      const provider = txSubmitHttpProvider(url);
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
        got.post = jest.fn().mockReturnValue({ json: jest.fn().mockResolvedValue({ ok: true }) });
        const provider = txSubmitHttpProvider(url);
        await expect(provider.healthCheck()).resolves.toEqual({ ok: true });
      });

      it('is not ok if 200 response body is { ok: false }', async () => {
        got.post = jest.fn().mockReturnValue({ json: jest.fn().mockResolvedValue({ ok: false }) });
        const provider = txSubmitHttpProvider(url);
        await expect(provider.healthCheck()).resolves.toEqual({ ok: false });
      });
    });
  });

  describe('submitTx', () => {
    it('resolves if successful', async () => {
      got.post = jest.fn().mockReturnValue({ json: jest.fn().mockResolvedValue('') });
      const provider = txSubmitHttpProvider(url);
      await expect(provider.submitTx(new Uint8Array())).resolves.not.toThrow();
    });

    describe('errors', () => {
      const testError = (bodyError: Error, providerErrorType: unknown) => async () => {
        const response = {
          body: serializeError(bodyError)
        } as Response;
        const httpError = new HTTPError(response);
        Object.defineProperty(httpError, 'response', { value: response });
        try {
          got.post = jest.fn().mockReturnValue({
            json: jest.fn().mockRejectedValue(httpError)
          });
          const provider = txSubmitHttpProvider(url);
          await provider.submitTx(new Uint8Array());
          throw new Error('Expected to throw');
        } catch (error) {
          if (error instanceof ProviderError) {
            expect(error.reason).toBe(ProviderFailure.BadRequest);
            const innerError = error.innerError as Cardano.TxSubmissionError;
            expect(innerError).toBeInstanceOf(providerErrorType);
          } else {
            throw new TypeError('Expected ProviderError');
          }
        }
      };

      it(
        'rehydrates errors',
        testError(
          new Cardano.TxSubmissionErrors.BadInputsError({ badInputs: [] }),
          Cardano.TxSubmissionErrors.BadInputsError
        )
      );

      it(
        'maps unrecognized errors to UnknownTxSubmissionError',
        testError(new Error('Unknown error'), Cardano.UnknownTxSubmissionError)
      );
    });
  });
});
