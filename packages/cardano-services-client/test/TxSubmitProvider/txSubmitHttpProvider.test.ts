import { CardanoNodeErrors, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { axiosError, healthCheckResponseWithState } from '../util';
import { bufferToHexString } from '@cardano-sdk/util';
import { logger } from '@cardano-sdk/util-dev';
import { txSubmitHttpProvider, version } from '../../src';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

const config = { baseUrl: 'http://some-hostname:3000/tx-submit', logger, version };

const emptyUintArrayAsHexString = bufferToHexString(Buffer.from(new Uint8Array()));

describe('txSubmitHttpProvider', () => {
  describe('healthCheck', () => {
    it('is not ok if cannot connect', async () => {
      const provider = txSubmitHttpProvider(config);
      await expect(() => provider.healthCheck()).rejects.toThrow();
    });
  });
  // eslint-disable-next-line sonarjs/cognitive-complexity
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
      it('is ok if 200 response body is { ok: true, localNode }', async () => {
        axiosMock.onPost().replyOnce(200, healthCheckResponseWithState);
        const provider = txSubmitHttpProvider(config);
        await expect(provider.healthCheck()).resolves.toEqual(healthCheckResponseWithState);
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
        const testError =
          (bodyError: Error, providerFailure: ProviderFailure, providerErrorType: unknown) => async () => {
            try {
              axiosMock.onPost().replyOnce(() => {
                throw axiosError(bodyError);
              });
              const provider = txSubmitHttpProvider(config);
              await provider.submitTx({ signedTransaction: emptyUintArrayAsHexString });
              throw new Error('Expected to throw');
            } catch (error) {
              if (error instanceof ProviderError) {
                expect(error.reason).toBe(providerFailure);
                const innerError = error.innerError as CardanoNodeErrors.TxSubmissionError;
                expect(innerError).toBeInstanceOf(providerErrorType);
              } else {
                throw new TypeError('Expected ProviderError');
              }
            }
          };

        it(
          'rehydrates errors',
          testError(
            new CardanoNodeErrors.TxSubmissionErrors.BadInputsError({ badInputs: [] }),
            ProviderFailure.BadRequest,
            CardanoNodeErrors.TxSubmissionErrors.BadInputsError
          )
        );

        it(
          'maps unrecognized errors to UnknownTxSubmissionError',
          testError(new Error('Unknown error'), ProviderFailure.Unknown, CardanoNodeErrors.UnknownTxSubmissionError)
        );

        it('does not re-wrap UnknownTxSubmissionError', async () => {
          expect.assertions(3);
          axiosMock.onPost().replyOnce(() => {
            throw axiosError(new CardanoNodeErrors.UnknownTxSubmissionError('Unknown error'));
          });
          const provider = txSubmitHttpProvider(config);
          try {
            await provider.submitTx({ signedTransaction: emptyUintArrayAsHexString });
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
          } catch (error: any) {
            expect(error).toBeInstanceOf(ProviderError);
            expect(error.innerError).toBeInstanceOf(CardanoNodeErrors.UnknownTxSubmissionError);
            expect(error.innerError.innerError.name).not.toBe(CardanoNodeErrors.UnknownTxSubmissionError.name);
          }
        });
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
