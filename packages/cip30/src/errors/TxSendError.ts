import { CustomError } from 'ts-custom-error';

/**
 * - Refused - Wallet refuses to send the tx (could be rate limiting)
 * - Failure - Wallet could not send the tx
 */
export enum TxSendErrorCode {
  Refused = 1,
  Failure = 2
}
export class TxSendError extends CustomError {
  code: TxSendErrorCode;
  info: string;

  public constructor(code: TxSendErrorCode, info: string) {
    super();
    this.code = code;
    this.info = info;
  }
}
