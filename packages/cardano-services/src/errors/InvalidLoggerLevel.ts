import { CustomError } from 'ts-custom-error';

export class InvalidLoggerLevel extends CustomError {
  public constructor(value: string) {
    super();
    this.message = `${value} is an invalid logger level`;
  }
}
