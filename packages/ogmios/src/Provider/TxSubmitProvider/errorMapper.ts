import { CardanoNodeErrors, TxSubmissionError, TxSubmissionErrorCode } from '@cardano-sdk/core';

export const mapOgmiosTxSubmitError = (error: CardanoNodeErrors.TxSubmissionError): TxSubmissionError => {
  if (error instanceof CardanoNodeErrors.TxSubmissionErrors.CollateralHasNonAdaAssetsError) {
    return new TxSubmissionError(TxSubmissionErrorCode.NonAdaCollateral, error.stack, error.message);
  }
  if (error instanceof CardanoNodeErrors.TxSubmissionErrors.OutsideOfValidityIntervalError) {
    return new TxSubmissionError(TxSubmissionErrorCode.OutsideOfValidityInterval, error.stack, error.message);
  }
  if (error instanceof CardanoNodeErrors.TxSubmissionErrors.ValueNotConservedError) {
    return new TxSubmissionError(TxSubmissionErrorCode.ValueNotConserved, error.stack, error.message);
  }
  if (error instanceof CardanoNodeErrors.TxSubmissionErrors.UnknownOrIncompleteWithdrawalsError) {
    return new TxSubmissionError(TxSubmissionErrorCode.IncompleteWithdrawals, error.stack, error.message);
  }
  return error as TxSubmissionError;
};
