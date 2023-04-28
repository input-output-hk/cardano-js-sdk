import { CustomError } from 'ts-custom-error';

export class CborInvalidOperationException extends CustomError {
  public constructor(reason: string) {
    super(reason);
  }
}

export class CborContentException extends CustomError {
  public constructor(reason: string) {
    super(reason);
  }
}

export class LossOfPrecisionException extends CustomError {
  public constructor(reason: string) {
    super(reason);
  }
}
