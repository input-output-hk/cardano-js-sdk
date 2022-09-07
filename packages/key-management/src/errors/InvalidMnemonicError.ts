import { CustomError } from 'ts-custom-error';

export class InvalidMnemonicError extends CustomError {
  constructor() {
    super();
    this.message = 'Invalid Mnemonic';
    this.name = 'InvalidMnemonicError';
  }
}
