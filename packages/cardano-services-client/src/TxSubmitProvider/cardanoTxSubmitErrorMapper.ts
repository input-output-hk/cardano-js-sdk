/* eslint-disable wrap-regex */
import { TxSubmissionError, TxSubmissionErrorCode } from '@cardano-sdk/core';

export const mapCardanoTxSubmitError = (errorData: unknown): TxSubmissionError | null => {
  if (typeof errorData === 'string') {
    if (/outsideofvalidity/i.test(errorData)) {
      return new TxSubmissionError(TxSubmissionErrorCode.OutsideOfValidityInterval, null, errorData);
    }
    if (/valuenotconserved/i.test(errorData)) {
      return new TxSubmissionError(TxSubmissionErrorCode.ValueNotConserved, null, errorData);
    }
    if (/nonadacollateral/i.test(errorData)) {
      return new TxSubmissionError(TxSubmissionErrorCode.NonAdaCollateral, null, errorData);
    }
    if (/incompletewithdrawals/i.test(errorData)) {
      return new TxSubmissionError(TxSubmissionErrorCode.IncompleteWithdrawals, null, errorData);
    }
  }
  return null;
};
