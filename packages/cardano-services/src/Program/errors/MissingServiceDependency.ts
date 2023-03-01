import { CustomError } from 'ts-custom-error';

export enum RunnableDependencies {
  CardanoNode = 'Ogmios Cardano Node'
}

export class MissingServiceDependency<ServiceNames> extends CustomError {
  public constructor(serviceName: ServiceNames, dependencyName: string) {
    super();
    this.message = `Service ${serviceName} has missing dependency of ${dependencyName}`;
  }
}
