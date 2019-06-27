import axios, { AxiosRequestConfig } from 'axios'
import { RequestHandler } from './RequestHandler'
import { RequestMethod } from './RequestMethod'
import { RequestError, NoResponse } from './errors'

export function AxiosWrapper (uri: string, isSocket: boolean): RequestHandler {
  let globalConfig = isSocket
    ? { socketPath: uri }
    : { baseURL: uri }

  return ({ method, body, path, headers }) => {
    let axiosConfig: AxiosRequestConfig = {
      method,
      url: path,
      headers,
      ...globalConfig
    }

    if (method !== RequestMethod.GET) {
      axiosConfig['data'] = body
    }

    return axios(axiosConfig)
      .then(({ data }) => data)
      .catch(error => {
        if (error.response) {
          // There is a chance stringification can fail
          let stringifiedServerError: string
          try {
            stringifiedServerError = JSON.stringify(error.response.data)
          } catch (_) {
            stringifiedServerError = 'Unknown server error. Failed to stringify the error object'
          }

          const statusCode = error.response.status
          throw new RequestError({
            path,
            requestBody: JSON.stringify(body),
            serverError: stringifiedServerError,
            statusCode,
            uri
          })
        }

        throw new NoResponse(path, uri)
      })
  }
}
