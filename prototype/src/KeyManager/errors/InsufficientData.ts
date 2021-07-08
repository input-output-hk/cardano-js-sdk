import { CustomError } from 'ts-custom-error'

export class InsufficientData extends CustomError {
  constructor (operation: string, missingData: string) {
    super()
    this.message = `Operation ${operation} requires ${missingData} to proceed`
    this.name = 'InsufficientData'
  }
}
