import { CustomError } from 'ts-custom-error';

/**
 * {maxSize} is the maximum size for pagination and if the dApp tries to
 * request pages outside of this boundary this error is thrown.
 */
export class PaginateError extends CustomError {
  maxSize: number;

  public constructor(maxSize: number, message: string) {
    super();
    this.maxSize = maxSize;
    this.message = message;
  }
}
