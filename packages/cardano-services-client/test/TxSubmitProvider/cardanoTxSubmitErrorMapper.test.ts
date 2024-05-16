import { CardanoNodeUtil, TxSubmissionErrorCode } from '@cardano-sdk/core';
import { mapCardanoTxSubmitError } from '../../src/TxSubmitProvider/cardanoTxSubmitErrorMapper';

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

  describe('json errors', () => {
    const errorData = {
      contents: {
        contents: {
          contents: {
            era: 'ShelleyBasedEraConway',
            error: [
              'ConwayUtxowFailure (UtxoFailure (AlonzoInBabbageUtxoPredFailure (ValueNotConservedUTxO (MaryValue (Coin 0) (MultiAsset (fromList []))) (MaryValue (Coin 4999969413825) (MultiAsset (fromList []))))))',
              'ConwayUtxowFailure (UtxoFailure (AlonzoInBabbageUtxoPredFailure (BadInputsUTxO (fromList [TxIn (TxId {unTxId = SafeHash "5f968400f05638454896883ae0f34491e14d748194a10df3f5a7fe2d10f52373"}) (TxIx 1)]))))'
            ],
            kind: 'ShelleyTxValidationError'
          },
          tag: 'TxValidationErrorInCardanoMode'
        },
        tag: 'TxCmdTxSubmitValidationError'
      },
      tag: 'TxSubmitFail'
    };

    it('can map ValueNotConservedError to TxSubmissionErrorCode.ValueNotConserved', () => {
      expect(CardanoNodeUtil.isValueNotConservedError(mapCardanoTxSubmitError(errorData))).toBeTruthy();
    });
  });
});
