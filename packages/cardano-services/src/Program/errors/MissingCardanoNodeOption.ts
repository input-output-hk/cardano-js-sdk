import { CustomError } from 'ts-custom-error';
import { ProgramOptionDescriptions } from '../ProgramOptionDescriptions';

export class MissingCardanoNodeOption extends CustomError {
  public constructor(option: ProgramOptionDescriptions | ProgramOptionDescriptions[]) {
    super();
    this.message = `Cardano Node Ogmios requires the ${
      typeof option === 'string' ? option : option.join(' or ')
    } program option.`;
  }
}
