/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  CardanoNodeErrors,
  HttpProviderConfigPaths,
  ProviderError,
  ProviderFailure,
  TxSubmitProvider
} from '@cardano-sdk/core';
import { CreateHttpProviderConfig, createHttpProvider } from '../HttpProvider';
import { mapHealthCheckError } from '../mapHealthCheckError';

/**
 * The TxSubmitProvider endpoint paths.
 */
const paths: HttpProviderConfigPaths<TxSubmitProvider> = {
  healthCheck: '/health',
  submitTx: '/submit'
};

const toTxSubmissionError = (error: any): CardanoNodeErrors.TxSubmissionError | null => {
  if (typeof error === 'object' && typeof error?.name === 'string' && typeof error?.message === 'string') {
    const rawError = error as CardanoNodeErrors.TxSubmissionError;

    const txSubmissionErrorName = rawError.name as keyof typeof CardanoNodeErrors.TxSubmissionErrors;
    const ErrorClass = CardanoNodeErrors.TxSubmissionErrors[txSubmissionErrorName];
    if (ErrorClass) {
      Object.setPrototypeOf(error, ErrorClass.prototype);
      return error;
    }
    if (rawError.name === CardanoNodeErrors.UnknownTxSubmissionError.name) {
      Object.setPrototypeOf(error, CardanoNodeErrors.UnknownTxSubmissionError.prototype);
      return error;
    }
    return new CardanoNodeErrors.UnknownTxSubmissionError(error);
  }
  return null;
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param config The configuration object fot the TxSubmit Provider.
 * @returns {TxSubmitProvider} TxSubmitProvider
 * @throws {ProviderError} if reason === ProviderFailure.BadRequest then
 * innerError is set to either one of CardanoNodeErrors.TxSubmissionErrors or Cardano.UnknownTxSubmissionError
 */
export const txSubmitHttpProvider = (config: CreateHttpProviderConfig<TxSubmitProvider>): TxSubmitProvider =>
  createHttpProvider<TxSubmitProvider>({
    ...config,
    mapError: (error: any, method) => {
      switch (method) {
        case 'healthCheck': {
          return mapHealthCheckError(error);
        }
        case 'submitTx': {
          if (typeof error === 'object' && typeof error.innerError === 'object') {
            const txSubmissionError = toTxSubmissionError(error.innerError);
            if (txSubmissionError) {
              const failure =
                txSubmissionError instanceof CardanoNodeErrors.UnknownTxSubmissionError
                  ? ProviderFailure.Unknown
                  : ProviderFailure.BadRequest;
              throw new ProviderError(failure, txSubmissionError);
            }
          }
        }
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    },
    paths
  });
