/* eslint-disable @typescript-eslint/no-explicit-any */
import { Logger } from 'ts-log';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { fromSerializableObject, isConnectionError, toSerializableObject } from '@cardano-sdk/util';
import axios, { AxiosAdapter, AxiosRequestConfig } from 'axios';

const isEmptyResponse = (response: any) => response === '';

export type HttpProviderConfigPaths<T> = { [methodName in keyof T]: string };

export interface HttpProviderConfig<T> {
  /**
   * Example: "http://localhost:3000"
   */
  baseUrl: string;
  /**
   * A mapping between provider method names and url paths.
   * Paths have to use /leadingSlash
   */
  paths: HttpProviderConfigPaths<T>;
  /**
   * Additional request options passed to axios
   */
  axiosOptions?: AxiosRequestConfig;
  /**
   * Custom error handling: Either:
   * - interpret error as valid response by mapping it to response type and returning it
   * - map error to a new Error type by throwing it
   *
   * @param error response body parsed as JSON
   * @param method provider method name
   */
  mapError?: (error: unknown, method: keyof T) => unknown;

  /**
   * This adapter that allows to you to modify the way Axios make requests.
   */
  adapter?: AxiosAdapter;

  /**
   * Logger strategy.
   */
  logger: Logger;
}

/**
 * The subset of parameters from HttpProviderConfig that must be set by the
 * client code.
 */
export type CreateHttpProviderConfig<T> = Pick<HttpProviderConfig<T>, 'baseUrl' | 'adapter' | 'logger'>;

/**
 * Creates a HTTP client for specified provider type, following some conventions:
 * - All methods use POST requests
 * - Arguments are serialized using core toSerializableObject and sent as JSON {args: unknown[]} in request body
 * - Server is expected to use the following core utils:
 *   - fromSerializableObject after deserializing args
 *   - toSerializableObject before serializing response body
 *
 * @returns provider that fetches data over http
 */
export const createHttpProvider = <T extends object>({
  baseUrl,
  axiosOptions,
  mapError,
  paths,
  adapter,
  logger
}: HttpProviderConfig<T>): T =>
  new Proxy<T>({} as T, {
    // eslint-disable-next-line sonarjs/cognitive-complexity
    get(_, prop) {
      if (prop === 'then') return;
      const method = prop as keyof T;
      const path = paths[method];
      if (!path)
        throw new ProviderError(ProviderFailure.NotImplemented, `HttpProvider missing path for '${prop.toString()}'`);
      return async (...args: any[]) => {
        try {
          const req: AxiosRequestConfig = {
            ...axiosOptions,
            adapter,
            baseURL: baseUrl,
            data: { ...args[0] },
            method: 'post',
            responseType: 'json',
            url: path
          };
          logger.debug(`Sending ${req.method} request to ${req.baseURL}${req.url} with data:`);
          logger.debug(req.data);

          const axiosInstance = axios.create(req);

          axiosInstance.interceptors.request.use((value) => {
            if (value.data) value.data = toSerializableObject(value.data);
            return value;
          });
          axiosInstance.interceptors.response.use((value) => ({
            ...value,
            data: fromSerializableObject(value.data, { getErrorPrototype: () => ProviderError.prototype })
          }));
          const response = (await axiosInstance.request(req)).data;
          return !isEmptyResponse(response) ? response : undefined;
        } catch (error) {
          logger.error(error);
          if (axios.isAxiosError(error)) {
            if (error.response) {
              const typedError = fromSerializableObject(error.response.data, {
                getErrorPrototype: () => ProviderError.prototype
              });
              if (mapError) return mapError(typedError, method);
              throw new ProviderError(ProviderFailure.Unknown, typedError);
            }
            if (mapError) return mapError(null, method);
            if (isConnectionError(error)) {
              throw new ProviderError(ProviderFailure.ConnectionFailure, error, error.code);
            }
          }
          throw new ProviderError(ProviderFailure.Unknown, error);
        }
      };
    }
  });
