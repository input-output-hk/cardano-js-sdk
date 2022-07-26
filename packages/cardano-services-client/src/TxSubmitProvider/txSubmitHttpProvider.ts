/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano, ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { CreateHttpProviderConfig, HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';
import { mapHealthCheckError } from '../mapHealthCheckError';

/**
 * The TxSubmitProvider endpoint paths.
 */
const paths: HttpProviderConfigPaths<TxSubmitProvider> = {
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
 * @param config The configuration object fot the TxSubmit Provider.
 * @returns {TxSubmitProvider} TxSubmitProvider
 * @throws {ProviderError} if reason === ProviderFailure.BadRequest then
 * innerError is set to either one of Cardano.TxSubmissionErrors or Cardano.UnknownTxSubmissionError
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
              throw new ProviderError(ProviderFailure.BadRequest, txSubmissionError);
            }
          }
        }
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    },
    paths
  });
