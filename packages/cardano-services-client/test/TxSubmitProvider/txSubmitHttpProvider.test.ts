import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { axiosError } from '../util';
import { bufferToHexString } from '@cardano-sdk/util';
import { logger } from '@cardano-sdk/util-dev';
import { txSubmitHttpProvider } from '../../src';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

const config = { baseUrl: 'http://some-hostname:3000/tx-submit', logger };

const emptyUintArrayAsHexString = bufferToHexString(Buffer.from(new Uint8Array()));

describe('txSubmitHttpProvider', () => {
  describe('healthCheck', () => {
    it('is not ok if cannot connect', async () => {
      const provider = txSubmitHttpProvider(config);
      await expect(provider.healthCheck()).resolves.toEqual({ ok: false });
    });
  });
  describe('mocked', () => {
    let axiosMock: MockAdapter;
    beforeAll(() => {
      axiosMock = new MockAdapter(axios);
    });

    afterEach(() => {
      axiosMock.reset();
    });

    afterAll(() => {
      axiosMock.restore();
    });

    describe('healthCheck', () => {
      it('is ok if 200 response body is { ok: true }', async () => {
        axiosMock.onPost().replyOnce(200, { ok: true });
        const provider = txSubmitHttpProvider(config);
        await expect(provider.healthCheck()).resolves.toEqual({ ok: true });
      });

      it('is not ok if 200 response body is { ok: false }', async () => {
        axiosMock.onPost().replyOnce(200, { ok: false });
        const provider = txSubmitHttpProvider(config);
        await expect(provider.healthCheck()).resolves.toEqual({ ok: false });
      });
    });

    describe('submitTx', () => {
      it('resolves if successful', async () => {
        axiosMock.onPost().replyOnce(200, '');
        const provider = txSubmitHttpProvider(config);
        await expect(provider.submitTx({ signedTransaction: emptyUintArrayAsHexString })).resolves.not.toThrow();
      });

      describe('errors', () => {
        const testError = (bodyError: Error, providerErrorType: unknown) => async () => {
          try {
            axiosMock.onPost().replyOnce(() => {
              throw axiosError(bodyError);
            });
            const provider = txSubmitHttpProvider(config);
            await provider.submitTx({ signedTransaction: emptyUintArrayAsHexString });
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

  describe('standard behavior', () => {
    it('txSubmitHttpProvider can be the return value of async functions', async () => {
      const provider = txSubmitHttpProvider(config);
      const getProvider = async () => provider;

      await expect(getProvider()).resolves.toBe(provider);
    });
  });
});
