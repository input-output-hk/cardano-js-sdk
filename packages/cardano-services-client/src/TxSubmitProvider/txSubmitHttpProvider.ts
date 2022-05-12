/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano, ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';
import { mapHealthCheckError } from '../mapHealthCheckError';

export const defaultTxSubmitProviderPaths: HttpProviderConfigPaths<TxSubmitProvider> = {
  healthCheck: '/health',
  submitTx: '/submit'
};

const toTxSubmissionError = (error: any): Cardano.TxSubmissionError | null => {
  if (typeof error === 'object' && typeof error?.name === 'string' && typeof error?.message === 'string') {
    const rawError = error as Cardano.TxSubmissionError;
    const txSubmissionErrorName = rawError.name as keyof typeof Cardano.TxSubmissionErrors;
    const ErrorClass = Cardano.TxSubmissionErrors[txSubmissionErrorName];
    if (ErrorClass) {
      Object.setPrototypeOf(error, ErrorClass.prototype);
      return error;
    }
    return new Cardano.UnknownTxSubmissionError(error);
  }
  return null;
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param {string} baseUrl server root url, w/o trailing /
 * @returns {TxSubmitProvider} TxSubmitProvider
 * @throws {ProviderError} if reason === ProviderFailure.BadRequest then
 * innerError is set to either one of Cardano.TxSubmissionErrors or Cardano.UnknownTxSubmissionError
 */
export const txSubmitHttpProvider = (baseUrl: string, paths = defaultTxSubmitProviderPaths): TxSubmitProvider =>
  createHttpProvider<TxSubmitProvider>({
    baseUrl,
    mapError: (error: any, method) => {
      switch (method) {
        case 'healthCheck': {
          return mapHealthCheckError(error);
        }
        case 'submitTx': {
          if (typeof error === 'object' && typeof error.innerError === 'object') {
            const txSubmissionError = toTxSubmissionError(error.innerError);
            if (txSubmissionError) {
              throw new ProviderError(ProviderFailure.BadRequest, txSubmissionError);
            }
          }
        }
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    },
    paths
  });
