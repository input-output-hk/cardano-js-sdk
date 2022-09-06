import { CustomError } from 'ts-custom-error';
import { ProgramOptionDescriptions } from '../Options';
import { ServiceNames } from '../ServiceNames';

export class MissingProgramOption extends CustomError {
  public constructor(service: ServiceNames, option: ProgramOptionDescriptions | ProgramOptionDescriptions[]) {
    super();
    this.message = `${service} requires the ${
      typeof option === 'string' ? option : option.join(' or ')
    } program option.`;
  }
}
