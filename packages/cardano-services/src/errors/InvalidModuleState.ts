import { CustomError } from 'ts-custom-error';

export class InvalidModuleState<ModuleState> extends CustomError {
  public constructor(moduleName: string, methodName: string, requiredState: ModuleState) {
    super();
    this.message = `${methodName} cannot be called unless ${moduleName} is ${requiredState}`;
  }
}
