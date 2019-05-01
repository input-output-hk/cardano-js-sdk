import { CustomError } from 'ts-custom-error'

export class InvalidKeyType extends CustomError {
  constructor () {
    super()
    this.message = `Invalid Key Type`
    this.name = 'InvalidKeyType'
  }
}
