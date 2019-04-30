import { CustomError } from 'ts-custom-error'

export class TransactionUnderweight extends CustomError {
  constructor () {
    super()
    this.message = `Transaction inputs outweigh outputs`
    this.name = 'TransactionUnderweight'
  }
}
