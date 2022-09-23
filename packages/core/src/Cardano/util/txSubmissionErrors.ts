import { TxSubmissionError, TxSubmissionErrors } from '../types/TxSubmissionErrors';

/**
 * Tests the provided error for an instanceof match in the TxSubmissionErrors object
 *
 * @param {TxSubmissionError} error the error under test
 */
export const isTxSubmissionError = (error: unknown): error is TxSubmissionError =>
  Object.values(TxSubmissionErrors).some((TxSubmitError) => error instanceof TxSubmitError);

/**
 * Attempts to convert the provided error or array of errors into TxSubmissionError object
 *
 * @param {any} error the error or array of errors under test
 */
export const asTxSubmissionError = (error: unknown): TxSubmissionError | null => {
  if (Array.isArray(error)) {
    for (const err of error) {
      if (isTxSubmissionError(err)) {
        return err;
      }
    }
    return null;
  }
  return isTxSubmissionError(error) ? error : null;
};
