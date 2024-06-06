import { CustomError } from 'ts-custom-error';
import type { Programs } from '../programs/index.js';

export class WrongOption extends CustomError {
  public constructor(program: Programs, option: string, expected: string[]) {
    super();
    this.message = `${program} requires a valid ${option} program option. Expected: ${expected.join(', ')}`;
  }
}
