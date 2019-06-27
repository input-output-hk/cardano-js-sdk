import { CustomError } from 'ts-custom-error'

export class NoResponse extends CustomError {
  public statusCode: number
  public path: string
  public uri: string

  constructor (path: string, uri: string) {
    super()
    this.statusCode = 1
    this.path = path
    this.uri = uri
    this.message = `No response from server at: ${uri}/${path}`
    this.name = 'NoResponse'
  }
}
