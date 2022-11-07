import { CardanoNodeErrors } from '../../CardanoNode';

/**
 * Tests the provided error for an instanceof match in the TxSubmissionErrors object
 *
 * @param {CardanoNodeErrors.TxSubmissionError} error the error under test
 */
export const isTxSubmissionError = (error: unknown): error is CardanoNodeErrors.TxSubmissionError =>
  Object.values(CardanoNodeErrors.TxSubmissionErrors).some((TxSubmitError) => error instanceof TxSubmitError);

/**
 * Attempts to convert the provided error or array of errors into TxSubmissionError object
 *
 * @param {any} error the error or array of errors under test
 */
export const asTxSubmissionError = (error: unknown): CardanoNodeErrors.TxSubmissionError | null => {
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
