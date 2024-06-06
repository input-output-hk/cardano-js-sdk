import { CardanoNodeErrors } from '../../../src/CardanoNode/index.js';
import { util } from '../../../src/Cardano/index.js';

const badInputsError = new CardanoNodeErrors.TxSubmissionErrors.BadInputsError({ badInputs: [] });
const addressAttributesTooLargeError = new CardanoNodeErrors.TxSubmissionErrors.AddressAttributesTooLargeError({
  addressAttributesTooLarge: []
});
const someOtherError = new Error('some other error') as unknown as CardanoNodeErrors.TxSubmissionError;
const someString = 'some string' as unknown as CardanoNodeErrors.TxSubmissionError;

describe('txSubmissionErrors', () => {
  describe('isTxSubmissionError', () => {
    it('is true if the value is a tx submission error', () => {
      expect(util.isTxSubmissionError(badInputsError)).toBe(true);
    });

    it('is false if a single generic error is not a tx submission error', () => {
      expect(util.isTxSubmissionError(someOtherError)).toBe(false);
    });

    it('is false if a non-error value is passed', () => {
      expect(util.isTxSubmissionError(someString)).toBe(false);
    });
  });

  describe('asTxSubmissionError', () => {
    it('is true if the value is a tx submission error', () => {
      expect(util.asTxSubmissionError(badInputsError)).toBeTruthy();
    });

    it('is false if a single generic error is not a tx submission error', () => {
      expect(util.asTxSubmissionError(someOtherError)).toBe(null);
    });

    it('is false if a non-error value is passed', () => {
      expect(util.asTxSubmissionError(someString)).toBe(null);
    });

    it('is true if all values in an array are tx submission error', () => {
      expect(util.asTxSubmissionError([badInputsError, addressAttributesTooLargeError])).toBeTruthy();
    });

    it('is true if at least one value in an array is a tx submission error', () => {
      expect(util.asTxSubmissionError([badInputsError, someOtherError])).toBeTruthy();
    });
  });
});
