import { CardanoNodeErrors, TxSubmissionErrorCode } from '@cardano-sdk/core';
import { mapOgmiosTxSubmitError } from '../../../src/Provider/TxSubmitProvider/errorMapper.js';

describe('mapTxSubmitError', () => {
  it('should map CollateralHasNonAdaAssetsError to TxSubmissionErrorCode.NonAdaCollateral', () => {
    const nonAdaAssetErr = new CardanoNodeErrors.TxSubmissionErrors.CollateralHasNonAdaAssetsError({
      collateralHasNonAdaAssets: { coins: 1n }
    });
    expect(mapOgmiosTxSubmitError(nonAdaAssetErr).code).toEqual(TxSubmissionErrorCode.NonAdaCollateral);
  });

  it('should map OutsideOfValidityIntervalError to TxSubmissionErrorCode.OutsideOfValidityInterval', () => {
    const outsideOfValidityErr = new CardanoNodeErrors.TxSubmissionErrors.OutsideOfValidityIntervalError({
      outsideOfValidityInterval: { currentSlot: 3, interval: { invalidBefore: 1, invalidHereafter: 2 } }
    });
    expect(mapOgmiosTxSubmitError(outsideOfValidityErr).code).toEqual(TxSubmissionErrorCode.OutsideOfValidityInterval);
  });

  it('should map ValueNotConservedError to TxSubmissionErrorCode.ValueNotConserved', () => {
    const valueNotConservedErr = new CardanoNodeErrors.TxSubmissionErrors.ValueNotConservedError({
      valueNotConserved: { consumed: 1, produced: 2 }
    });
    expect(mapOgmiosTxSubmitError(valueNotConservedErr).code).toEqual(TxSubmissionErrorCode.ValueNotConserved);
  });

  it('should map UnknownOrIncompleteWithdrawalsError to TxSubmissionErrorCode.IncompleteWithdrawals', () => {
    const unknownOrIncompleteWithdrawalsErr =
      new CardanoNodeErrors.TxSubmissionErrors.UnknownOrIncompleteWithdrawalsError({
        unknownOrIncompleteWithdrawals: { coin: 1n }
      });
    expect(mapOgmiosTxSubmitError(unknownOrIncompleteWithdrawalsErr).code).toEqual(
      TxSubmissionErrorCode.IncompleteWithdrawals
    );
  });

  it('does not map other errors', () => {
    const unknownErr = new CardanoNodeErrors.UnknownTxSubmissionError({ unknown: { unknown: 'unknown' } });
    expect(mapOgmiosTxSubmitError(unknownErr)).toEqual(unknownErr);
  });
});
