import { CustomError } from 'ts-custom-error'

export class MaximumTransactionInputsExceeded extends CustomError {
  constructor (maxInputs: number, inputsAccumulated: number) {
    super()
    this.message = `The maximum number of inputs on a transaction is ${maxInputs}. ${inputsAccumulated} were selected.`
    this.name = 'MaximumTransactionInputsExceeded'
  }
}
