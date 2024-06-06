import {
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
  ProviderError,
  ProviderFailure,
  TxCBOR,
  TxSubmissionError,
  TxSubmissionErrorCode
} from '@cardano-sdk/core';
import { bufferToHexString } from '@cardano-sdk/util';
import { config } from '../util.js';
import { handleProviderMocks } from '@cardano-sdk/util-dev';
import { txSubmitHttpProvider } from '../../src/index.js';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

const emptyUintArrayAsHexString = TxCBOR(bufferToHexString(Buffer.from(new Uint8Array())));

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
        axiosMock.onPost().replyOnce(200, handleProviderMocks.healthCheckResponseWithState);
        const provider = txSubmitHttpProvider(config);
        await expect(provider.healthCheck()).resolves.toEqual(handleProviderMocks.healthCheckResponseWithState);
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
          (
            bodyError: Error | null,
            providerFailure: ProviderFailure,
            providerErrorType: unknown,
            reason?: ProviderFailure
          ) =>
          async () => {
            try {
              axiosMock.onPost().replyOnce(() => {
                throw handleProviderMocks.axiosError(bodyError, reason);
              });
              const provider = txSubmitHttpProvider(config);
              await provider.submitTx({ signedTransaction: emptyUintArrayAsHexString });
              throw new Error('Expected to throw');
            } catch (error) {
              if (error instanceof ProviderError) {
                expect(error.reason).toBe(providerFailure);
                expect(error.innerError).toBeInstanceOf(providerErrorType);
              } else {
                throw new TypeError('Expected ProviderError');
              }
            }
          };

        it(
          'rehydrates errors',
          testError(
            new TxSubmissionError(TxSubmissionErrorCode.EmptyInputSet, null, ''),
            ProviderFailure.BadRequest,
            TxSubmissionError
          )
        );

        it(
          'maps unrecognized errors to UnknownTxSubmissionError',
          testError(new Error('Unknown error'), ProviderFailure.Unknown, GeneralCardanoNodeError)
        );

        it(
          'uses reason to determine ProviderFailure type when innerError is missing',
          testError(null, ProviderFailure.BadRequest, ProviderError)
        );

        it(
          'non-providerError reason is mapped to ProviderFailure.Unknown when innerError is missing',
          testError(null, ProviderFailure.Unknown, ProviderError, 'invalidReason' as ProviderFailure)
        );

        it('does not re-wrap UnknownTxSubmissionError', async () => {
          expect.assertions(3);
          axiosMock.onPost().replyOnce(() => {
            throw handleProviderMocks.axiosError(
              new GeneralCardanoNodeError(GeneralCardanoNodeErrorCode.Unknown, null, '')
            );
          });
          const provider = txSubmitHttpProvider(config);
          try {
            await provider.submitTx({ signedTransaction: emptyUintArrayAsHexString });
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
          } catch (error: any) {
            expect(error).toBeInstanceOf(ProviderError);
            expect(error.innerError).toBeInstanceOf(GeneralCardanoNodeError);
            expect(error.innerError.innerError).toBeUndefined();
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
