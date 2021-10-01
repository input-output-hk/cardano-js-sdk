import { CustomError } from 'ts-custom-error';

export class InvalidProtocolParametersError extends CustomError {
  public constructor(reason: string) {
    super(reason);
  }
}
