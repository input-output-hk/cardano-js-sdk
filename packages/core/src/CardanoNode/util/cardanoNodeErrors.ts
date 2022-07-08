import { CardanoClientErrors, CardanoNodeError } from '../types/CardanoNodeErrors';

/**
 * Tests the provided error for an instanceof match in the CardanoErrors object
 *
 * @param {any} error the error under test
 */
export const isCardanoNodeError = (error: unknown): error is CardanoNodeError =>
  Object.values(CardanoClientErrors).some((NodeError) => error instanceof NodeError);

/**
 * Attempts to convert the provided error or array of errors into CardanoNodeError object
 *
 * @param {any} error the error or array of errors under test
 */
export const asCardanoNodeError = (error: unknown): CardanoNodeError | null => {
  if (Array.isArray(error)) {
    for (const err of error) {
      if (isCardanoNodeError(err)) {
        return err;
      }
    }
    return null;
  }
  return isCardanoNodeError(error) ? error : null;
};
