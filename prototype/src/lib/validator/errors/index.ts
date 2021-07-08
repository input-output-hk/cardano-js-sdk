import { CustomError } from 'ts-custom-error'

export class EmptyArray extends CustomError {
  constructor () {
    super()
    this.message = `An empty array is an invalid decoding target`
    this.name = 'EmptyArray'
  }
}
