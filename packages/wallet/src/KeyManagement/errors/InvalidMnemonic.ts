import { CustomError } from 'ts-custom-error';

export class InvalidMnemonic extends CustomError {
  constructor() {
    super();
    this.message = 'Invalid Mnemonic';
    this.name = 'InvalidMnemonic';
  }
}
