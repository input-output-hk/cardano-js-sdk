import { CustomError } from 'ts-custom-error'

export class InvalidTransactionConstruction extends CustomError {
  constructor () {
    super()
    this.message = `A Transaction requires both inputs and outputs`
    this.name = 'InvalidTransactionConstruction'
  }
}
