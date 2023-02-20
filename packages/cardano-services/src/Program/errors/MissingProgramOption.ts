import { CustomError } from 'ts-custom-error';
import { ServiceNames } from '../ServiceNames';

export class MissingProgramOption<OptionsType> extends CustomError {
  public constructor(service: ServiceNames, option: OptionsType | OptionsType[]) {
    super();
    this.message = `${service} requires the ${Array.isArray(option) ? option.join(' or ') : option} program option.`;
  }
}
