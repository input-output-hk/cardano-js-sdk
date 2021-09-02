import { CustomError } from 'ts-custom-error';

/**
 * - InvalidRequest - Inputs do not conform to this spec or are otherwise invalid.
 * - InternalError - An error occurred during execution of this API call.
 * - Refused - The request was refused due to lack of access - e.g. wallet disconnects.
 */
export enum APIErrorCode {
  InvalidRequest = -1,
  InternalError = -2,
  Refused = -3
}
export class ApiError extends CustomError {
  code: APIErrorCode;
  info: string;

  public constructor(code: APIErrorCode, info: string) {
    super();
    this.code = code;
    this.info = info;
  }
}
