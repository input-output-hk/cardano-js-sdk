import { CustomError } from 'ts-custom-error'

export class UnsupportedOperation extends CustomError {
  constructor (operation: string) {
    super()
    this.message = `Unsupported Operation: ${operation}`
    this.name = 'UnsupportedOperation'
  }
}
