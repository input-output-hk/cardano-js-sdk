import { CustomError } from 'ts-custom-error';

export class InvalidArgsCombination extends CustomError {
  public constructor(firstOption: string, secondOption: string) {
    super();
    this.message = `${firstOption} arg is not compatible with the ${secondOption}, please choose one of them`;
  }
}
