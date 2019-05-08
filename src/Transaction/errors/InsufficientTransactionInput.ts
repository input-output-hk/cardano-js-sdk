import { CustomError } from 'ts-custom-error'

export class InsufficientTransactionInput extends CustomError {
  constructor () {
    super()
    this.message = `Transaction inputs do not have enough balance to reach the estimated network fee and transaction outputs`
    this.name = 'InsufficientTransactionInput'
  }
}
