import { CustomError } from 'ts-custom-error';
import { ServiceNames } from '../ServiceNames';

export class UnknownServiceName extends CustomError {
  public constructor(input: string) {
    super();
    this.message = `${input} is an unknown service. Try ${Object.values(ServiceNames)}`;
  }
}
