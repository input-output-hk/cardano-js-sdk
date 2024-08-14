import {
  CardanoNodeUtil,
  ChainSyncError,
  ChainSyncErrorCode,
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
  OutsideOfValidityIntervalData,
  StateQueryError,
  StateQueryErrorCode,
  TxSubmissionError,
  TxSubmissionErrorCode
} from '../../../src';
const unknownCardanoNodeError = (message: string) =>
  new GeneralCardanoNodeError(GeneralCardanoNodeErrorCode.Unknown, message, 'Unknown Cardano node error, see "data"');
const stateQueryError = new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, 'Query unavailable');
const generalError = new GeneralCardanoNodeError(GeneralCardanoNodeErrorCode.ConnectionFailure, null, 'Refused');
const chainSyncError = new ChainSyncError(ChainSyncErrorCode.IntersectionNotFound, null, 'Intersection not found');
const txSubmissionError = new TxSubmissionError(
  TxSubmissionErrorCode.OutsideOfValidityInterval,
  { currentSlot: 123, validityInterval: { invalidHereafter: 122 } } as OutsideOfValidityIntervalData,
  'Outside of validity interval'
);
const someOtherError = new Error('some other error');
const someString = 'some string';

describe('util/cardanoNodeErrors', () => {
  describe('casting utils', () => {
    it('returns error if value is instanceof expected type', () => {
      expect(CardanoNodeUtil.asCardanoNodeError(stateQueryError)).toBe(stateQueryError);
      expect(CardanoNodeUtil.asStateQueryError(stateQueryError)).toBe(stateQueryError);
    });
    it('returns null if value is not instanceof expected type', () => {
      expect(CardanoNodeUtil.asStateQueryError(someOtherError)).toBeNull();
      expect(CardanoNodeUtil.asStateQueryError(chainSyncError)).toBeNull();
      expect(CardanoNodeUtil.asStateQueryError(txSubmissionError)).toBeNull();
      expect(CardanoNodeUtil.asStateQueryError(generalError)).toBeNull();
    });
    it('is false if a non-error value is passed', () => {
      expect(CardanoNodeUtil.asStateQueryError(someString)).toBeNull();
    });
    it('wraps original error in GeneralCardanoError if it is not a known CardanoNodeError', () => {
      expect(CardanoNodeUtil.asCardanoNodeError(someOtherError)).toEqual(
        unknownCardanoNodeError(someOtherError.message)
      );
      expect(CardanoNodeUtil.asCardanoNodeError(someString)).toEqual(unknownCardanoNodeError(someString));
    });
  });

  describe('error code utils', () => {
    it('returns true if code is one of the options for the error type', () => {
      expect(CardanoNodeUtil.isChainSyncErrorCode(ChainSyncErrorCode.IntersectionInterleaved)).toBe(true);
      expect(CardanoNodeUtil.isGeneralCardanoNodeErrorCode(GeneralCardanoNodeErrorCode.ConnectionFailure)).toBe(true);
      expect(CardanoNodeUtil.isStateQueryErrorCode(StateQueryErrorCode.EraMismatch)).toBe(true);
      expect(CardanoNodeUtil.isTxSubmissionErrorCode(TxSubmissionErrorCode.ExecutionUnitsTooLarge)).toBe(true);
    });
    it('returns false if code is not one of the options for the error type', () => {
      expect(CardanoNodeUtil.isChainSyncErrorCode(GeneralCardanoNodeErrorCode.ConnectionFailure)).toBe(false);
      expect(CardanoNodeUtil.isGeneralCardanoNodeErrorCode(StateQueryErrorCode.EraMismatch)).toBe(false);
      expect(CardanoNodeUtil.isStateQueryErrorCode(TxSubmissionErrorCode.ExecutionUnitsTooLarge)).toBe(false);
      expect(CardanoNodeUtil.isTxSubmissionErrorCode(StateQueryErrorCode.EraMismatch)).toBe(false);
    });
  });

  describe('specific error typeguard utils', () => {
    it('returns true if error type and code matches', () => {
      expect(
        CardanoNodeUtil.isValueNotConservedError(
          new TxSubmissionError(TxSubmissionErrorCode.ValueNotConserved, null, '')
        )
      ).toBe(true);
      expect(
        CardanoNodeUtil.isIncompleteWithdrawalsError(
          new TxSubmissionError(TxSubmissionErrorCode.IncompleteWithdrawals, null, '')
        )
      ).toBe(true);
      expect(
        CardanoNodeUtil.isOutsideOfValidityIntervalError(
          new TxSubmissionError(TxSubmissionErrorCode.OutsideOfValidityInterval, null, '')
        )
      ).toBe(true);
      expect(
        CardanoNodeUtil.isCredentialAlreadyRegistered(
          new TxSubmissionError(TxSubmissionErrorCode.CredentialAlreadyRegistered, null, '')
        )
      ).toBe(true);
      expect(
        CardanoNodeUtil.isDrepAlreadyRegistered(
          new TxSubmissionError(TxSubmissionErrorCode.DRepAlreadyRegistered, null, '')
        )
      ).toBe(true);
    });
    it('returns false if error type or code does not match', () => {
      expect(CardanoNodeUtil.isValueNotConservedError(generalError)).toBe(false);
      expect(CardanoNodeUtil.isIncompleteWithdrawalsError(someOtherError)).toBe(false);
      expect(CardanoNodeUtil.isOutsideOfValidityIntervalError(someString)).toBe(false);
      expect(
        CardanoNodeUtil.isValueNotConservedError(
          new TxSubmissionError(TxSubmissionErrorCode.IncompleteWithdrawals, null, '')
        )
      ).toBe(false);
      expect(
        CardanoNodeUtil.isIncompleteWithdrawalsError(
          new TxSubmissionError(TxSubmissionErrorCode.OutsideOfValidityInterval, null, '')
        )
      ).toBe(false);
      expect(
        CardanoNodeUtil.isOutsideOfValidityIntervalError(
          new TxSubmissionError(TxSubmissionErrorCode.IncompleteWithdrawals, null, '')
        )
      ).toBe(false);
      expect(
        CardanoNodeUtil.isCredentialAlreadyRegistered(
          new TxSubmissionError(TxSubmissionErrorCode.IncompleteWithdrawals, null, '')
        )
      ).toBe(false);
      expect(
        CardanoNodeUtil.isDrepAlreadyRegistered(
          new TxSubmissionError(TxSubmissionErrorCode.IncompleteWithdrawals, null, '')
        )
      ).toBe(false);
    });
  });
});
