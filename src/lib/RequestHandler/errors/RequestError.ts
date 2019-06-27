import { CustomError } from 'ts-custom-error'

export class RequestError extends CustomError {
  public statusCode: number
  public path: string
  public uri: string

  constructor ({ statusCode, path, uri, requestBody, serverError }: {
    statusCode: number,
    path: string,
    uri: string,
    requestBody: string,
    serverError: string
  }) {
    super()
    this.statusCode = statusCode
    this.path = path
    this.uri = uri
    this.message = `Request Error ${statusCode}. Server response: ${serverError}. Request Body: ${requestBody}`
    this.name = 'RequestError'
  }
}
