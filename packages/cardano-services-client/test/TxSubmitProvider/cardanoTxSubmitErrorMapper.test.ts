import { CardanoNodeUtil, TxSubmissionErrorCode } from '@cardano-sdk/core';
import { mapCardanoTxSubmitError } from '../../src/TxSubmitProvider/cardanoTxSubmitErrorMapper.js';

describe('mapCardanoTxSubmitError', () => {
  describe('stringish errors', () => {
    it('can map OutsideOfValidityIntervalError to TxSubmissionErrorCode.OutsideOfValidityInterval', () => {
      const errorData = 'blah blah OutsideOfValidity blah blah';
      expect(CardanoNodeUtil.isOutsideOfValidityIntervalError(mapCardanoTxSubmitError(errorData))).toBeTruthy();
    });

    it('can map ValueNotConservedError to TxSubmissionErrorCode.ValueNotConserved', () => {
      const errorData = 'blah blah ValueNotConserved blah blah';
      expect(CardanoNodeUtil.isValueNotConservedError(mapCardanoTxSubmitError(errorData))).toBeTruthy();
    });

    it('can map NonAdaCollateralError to TxSubmissionErrorCode.NonAdaCollateral', () => {
      const errorData = 'blah blah NonAdaCollateral blah blah';
      expect(mapCardanoTxSubmitError(errorData)?.code).toEqual(TxSubmissionErrorCode.NonAdaCollateral);
    });

    it('can map IncompleteWithdrawalsError to TxSubmissionErrorCode.IncompleteWithdrawals', () => {
      const errorData = 'blah blah IncompleteWithdrawals blah blah';
      expect(CardanoNodeUtil.isIncompleteWithdrawalsError(mapCardanoTxSubmitError(errorData))).toBeTruthy();
    });

    it('returns null for unknown errors', () => {
      const errorData = 'blah blah unknown blah blah';
      expect(mapCardanoTxSubmitError(errorData)).toBeNull();
    });
  });
});
