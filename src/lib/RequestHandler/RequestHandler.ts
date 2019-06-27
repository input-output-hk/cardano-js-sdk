import { RequestMethod } from './RequestMethod'
import { NoResponse, RequestError } from './errors'

export interface RequestArgs {
  path: string
  method: RequestMethod
  body?: any
  headers?: { [key: string]: string }
}

export type Response = any
export type RequestHandler = (requestArgs: RequestArgs) => Promise<Response | RequestError | NoResponse>
