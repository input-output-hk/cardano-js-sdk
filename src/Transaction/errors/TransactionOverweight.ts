import { CustomError } from 'ts-custom-error'

export class TransactionOverweight extends CustomError {
  constructor () {
    super()
    this.message = `Transaction outputs outweigh inputs`
    this.name = 'TransactionOverweight'
  }
}
