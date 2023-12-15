/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  CardanoNodeUtil,
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
  HandleOwnerChangeError,
  HttpProviderConfigPaths,
  ProviderError,
  ProviderFailure,
  TxSubmissionError,
  TxSubmissionErrorCode,
  TxSubmitProvider,
  reasonToProviderFailure
} from '@cardano-sdk/core';
import { CreateHttpProviderConfig, createHttpProvider } from '../HttpProvider';
import { apiVersion } from '../version';
import { mapHealthCheckError } from '../mapHealthCheckError';

/** The TxSubmitProvider endpoint paths. */
const paths: HttpProviderConfigPaths<TxSubmitProvider> = {
  healthCheck: '/health',
  submitTx: '/submit'
};

/**
 * Takes an unknown error param.
 * Returns an instance of TxSubmissionError or GeneralCardanoNodeError from the error if the error
 * is an object, with an undefined or valid TxSubmissionError or GeneralCardanoNodeError code, and
 * a string message.
 * Returns null otherwise.
 */
const toTxSubmissionError = (error: any): TxSubmissionError | GeneralCardanoNodeError | null => {
  if (typeof error === 'object' && error !== null && typeof error?.message === 'string') {
    if (CardanoNodeUtil.isTxSubmissionErrorCode(error.code)) {
      return new TxSubmissionError(error.code, error.data, error.message);
    }

    if (CardanoNodeUtil.isGeneralCardanoNodeErrorCode(error.code)) {
      return error instanceof GeneralCardanoNodeError
        ? error
        : new GeneralCardanoNodeError(error.code, error.data || null, error.message);
    }

    if (error.code === undefined || error.code === null) {
      return new GeneralCardanoNodeError(GeneralCardanoNodeErrorCode.Unknown, error?.data || null, error.message);
    }
  }
  return null;
};

const codeToProviderFailure = (code: GeneralCardanoNodeErrorCode | TxSubmissionErrorCode) => {
  switch (code) {
    case GeneralCardanoNodeErrorCode.Unknown:
      return ProviderFailure.Unknown;
    case GeneralCardanoNodeErrorCode.ServerNotReady:
      return ProviderFailure.ServerUnavailable;
    default:
      return ProviderFailure.BadRequest;
  }
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
    apiVersion: apiVersion.txSubmit,
    mapError: (error: any, method) => {
      switch (method) {
        case 'healthCheck': {
          return mapHealthCheckError(error);
        }
        case 'submitTx': {
          if (typeof error === 'object' && typeof error.innerError === 'object') {
            // Ogmios errors have inner error. Parse that to get the real error
            const txSubmissionError = toTxSubmissionError(error.innerError);
            if (txSubmissionError) {
              throw new ProviderError(codeToProviderFailure(txSubmissionError.code), txSubmissionError);
            }

            if (error.name === 'HandleOwnerChangeError') {
              Object.setPrototypeOf(error, HandleOwnerChangeError);
            }
          }
          // No inner error. Use the outer reason to determine the error type.
          if (error.reason && typeof error.reason === 'string') {
            throw new ProviderError(reasonToProviderFailure(error.reason), error);
          }
        }
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    },
    paths,
    serviceSlug: 'tx-submit'
  });
