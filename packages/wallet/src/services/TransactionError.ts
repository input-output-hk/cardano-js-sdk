import { CustomError } from 'ts-custom-error';

export enum TransactionFailure {
  InvalidTransaction = 'INVALID_TRANSACTION',
  FailedToSubmit = 'FAILED_TO_SUBMIT',
  Unknown = 'UNKNOWN',
  CannotTrack = 'CANNOT_TRACK',
  Timeout = 'TIMEOUT'
}

const formatDetail = (detail?: string) => (detail ? ` (${detail})` : '');

export class TransactionError extends CustomError {
  constructor(public reason: TransactionFailure, public innerError?: unknown, public detail?: string) {
    super(`Transaction failed: ${reason}${formatDetail(detail)}`);
  }
}
