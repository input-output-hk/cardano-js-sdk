/* eslint-disable wrap-regex */
import { TxSubmissionError, TxSubmissionErrorCode } from '@cardano-sdk/core';

const parseStringishError = (errorData: string) => {
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
  return null;
};

export const mapCardanoTxSubmitError = (errorData: unknown): TxSubmissionError | null => {
  if (typeof errorData === 'string') {
    return parseStringishError(errorData);
  } else if (typeof errorData === 'object' && errorData) {
    // cardano-submit-api started returning json instead of raw string.
    // For the moment, simply stringify it. In the future we may want to make use of it.
    return parseStringishError(JSON.stringify(errorData));
  }
  return null;
};
