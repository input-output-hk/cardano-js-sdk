import { CustomError } from 'ts-custom-error';

export class MissingProgramOption<ServiceNames, OptionsType> extends CustomError {
  public constructor(service: ServiceNames, option: OptionsType | OptionsType[]) {
    super();
    this.message = `${service} requires the ${Array.isArray(option) ? option.join(' or ') : option} program option.`;
  }
}

export class InvalidProgramOption<OptionsType> extends CustomError {
  public constructor(option: OptionsType | OptionsType[]) {
    super();
    this.message = `Invalid program option: ${Array.isArray(option) ? option.join(' or ') : option}.`;
  }
}
