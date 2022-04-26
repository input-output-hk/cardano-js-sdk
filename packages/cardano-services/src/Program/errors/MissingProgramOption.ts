import { CustomError } from 'ts-custom-error';
import { ProgramOptionDescriptions } from '../ProgramOptionDescriptions';
import { ServiceNames } from '../ServiceNames';

export class MissingProgramOption extends CustomError {
  public constructor(service: ServiceNames, option: ProgramOptionDescriptions) {
    super();
    this.message = `${service} requires the ${option} program option`;
  }
}
