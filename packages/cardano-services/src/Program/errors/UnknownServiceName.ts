import { CustomError } from 'ts-custom-error';

export class UnknownServiceName<ServiceNames> extends CustomError {
  public constructor(input: string, serviceNames: ServiceNames) {
    super();
    this.message = `${input} is an unknown service. Try ${serviceNames}`;
  }
}
