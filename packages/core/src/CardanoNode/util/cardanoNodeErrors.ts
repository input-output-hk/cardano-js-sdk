/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  ChainSyncError,
  ChainSyncErrorCode,
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
  StateQueryError,
  StateQueryErrorCode,
  TxSubmissionError,
  TxSubmissionErrorCode
} from '../types/index.js';
import { isProductionEnvironment, stripStackTrace } from '@cardano-sdk/util';
import type {
  IncompleteWithdrawalsData,
  OutsideOfValidityIntervalData,
  ValueNotConservedData
} from '../types/index.js';

type InferObjectType<T> = T extends new (...args: any[]) => infer O ? O : never;

const asSpecificCardanoNodeError =
  <ErrorClass extends new (...args: any[]) => any>(ErrorType: ErrorClass) =>
  (error: unknown): InferObjectType<ErrorClass> | null => {
    if (Array.isArray(error)) {
      for (const err of error) {
        if (err instanceof ErrorType) {
          if (isProductionEnvironment()) stripStackTrace(err);

          return err;
        }
      }
      return null;
    }

    if (error instanceof ErrorType) {
      if (isProductionEnvironment()) stripStackTrace(error);

      return error;
    }

    return null;
  };

/**
 * Attempts to cast the provided error or array of errors into TxSubmissionError object
 *
 * @param {any} error the error or array of errors under test
 */
export const asTxSubmissionError = asSpecificCardanoNodeError(TxSubmissionError);

/**
 * Attempts to cast the provided error or array of errors into ChainSyncError object
 *
 * @param {any} error the error or array of errors under test
 */
export const asChainSyncError = asSpecificCardanoNodeError(ChainSyncError);

/**
 * Attempts to cast the provided error or array of errors into StateQueryError object
 *
 * @param {any} error the error or array of errors under test
 */
export const asStateQueryError = asSpecificCardanoNodeError(StateQueryError);

/**
 * Attempts to cast the provided error or array of errors into GeneralCardanoNodeError object
 *
 * @param {any} error the error or array of errors under test
 */
export const asGeneralCardanoNodeError = asSpecificCardanoNodeError(GeneralCardanoNodeError);

/**
 * Attempts to cast the provided error or array of errors into any known CardanoNodeError subclass object.
 * If if it's not of any known subclass, creates a new GeneralCardanoError objects and wraps the original error as "data"
 *
 * @param {any} error the error or array of errors under test
 */
export const asCardanoNodeError = (error: unknown) =>
  asGeneralCardanoNodeError(error) ||
  asTxSubmissionError(error) ||
  asStateQueryError(error) ||
  asChainSyncError(error) ||
  new GeneralCardanoNodeError(GeneralCardanoNodeErrorCode.Unknown, error, 'Unknown Cardano node error, see "data"');

const stateQueryErrorCodes = new Set(Object.values(StateQueryErrorCode));
const generalCardanoNodeErrorCodes = new Set(Object.values(GeneralCardanoNodeErrorCode));
const txSubmissionErrorCodes = new Set(Object.values(TxSubmissionErrorCode));
const chainSyncErrorCodes = new Set(Object.values(ChainSyncErrorCode));

export const isChainSyncErrorCode = (code: unknown): code is ChainSyncErrorCode =>
  typeof code === 'number' && chainSyncErrorCodes.has(code);
export const isTxSubmissionErrorCode = (code: unknown): code is TxSubmissionErrorCode =>
  typeof code === 'number' && txSubmissionErrorCodes.has(code);
export const isStateQueryErrorCode = (code: unknown): code is StateQueryErrorCode =>
  typeof code === 'number' && stateQueryErrorCodes.has(code);
export const isGeneralCardanoNodeErrorCode = (code: unknown): code is GeneralCardanoNodeErrorCode =>
  typeof code === 'number' && generalCardanoNodeErrorCodes.has(code);

export const asChainSyncErrorCode = (code: unknown): ChainSyncErrorCode | null =>
  isChainSyncErrorCode(code) ? code : null;
export const asStateQueryErrorCode = (code: unknown): StateQueryErrorCode | null =>
  isStateQueryErrorCode(code) ? code : null;
export const asGeneralCardanoNodeErrorCode = (code: unknown): GeneralCardanoNodeErrorCode | null =>
  isGeneralCardanoNodeErrorCode(code) ? code : null;
export const asTxSubmissionErrorCode = (code: unknown): TxSubmissionErrorCode | null =>
  isTxSubmissionErrorCode(code) ? code : null;

export const isOutsideOfValidityIntervalError = (
  error: unknown
): error is TxSubmissionError<OutsideOfValidityIntervalData> =>
  error instanceof TxSubmissionError && error.code === TxSubmissionErrorCode.OutsideOfValidityInterval;

export const isValueNotConservedError = (error: unknown): error is TxSubmissionError<ValueNotConservedData> =>
  error instanceof TxSubmissionError && error.code === TxSubmissionErrorCode.ValueNotConserved;

export const isIncompleteWithdrawalsError = (error: unknown): error is TxSubmissionError<IncompleteWithdrawalsData> =>
  error instanceof TxSubmissionError && error.code === TxSubmissionErrorCode.IncompleteWithdrawals;
