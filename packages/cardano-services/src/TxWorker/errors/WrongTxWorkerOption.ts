import { CustomError } from 'ts-custom-error';
import { ServiceNames } from '../../Program';
import { TxWorkerOptionDescriptions } from '../TxWorkerOptionDescriptions';

export class WrongProgramOption extends CustomError {
  public constructor(service: ServiceNames, option: TxWorkerOptionDescriptions, expected: string[]) {
    super();
    this.message = `${service} requires a valid ${option} program option. Expected: ${expected.join(', ')}`;
  }
}
