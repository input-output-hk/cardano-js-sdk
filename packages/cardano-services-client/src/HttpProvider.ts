/* eslint-disable @typescript-eslint/no-explicit-any */
import { ProviderError, ProviderFailure, util } from '@cardano-sdk/core';
import got, { HTTPError, Options, OptionsOfJSONResponseBody, RequestError } from 'got';

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
   * Additional request options passed to got
   */
  gotOptions?: Options;
  /**
   * Custom error handling: Either:
   * - interpret error as valid response by mapping it to response type and returning it
   * - map error to a new Error type by throwing it
   *
   * @param error response body parsed as JSON
   * @param method provider method name
   */
  mapError?: (error: unknown, method: keyof T) => unknown;
}

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
  gotOptions,
  mapError,
  paths
}: HttpProviderConfig<T>): T =>
  new Proxy<T>({} as T, {
    // eslint-disable-next-line sonarjs/cognitive-complexity
    get(_, prop) {
      const method = prop as keyof T;
      const path = paths[method];
      if (!path)
        throw new ProviderError(ProviderFailure.NotImplemented, `HttpProvider missing path for '${prop.toString()}'`);
      return async (...args: any[]) => {
        try {
          const req: OptionsOfJSONResponseBody = {
            ...gotOptions,
            isStream: false,
            json: { args },
            parseJson: (obj) => util.fromSerializableObject(JSON.parse(obj), () => ProviderError.prototype),
            resolveBodyOnly: false,
            responseType: 'json',
            stringifyJson: (obj) => JSON.stringify(util.toSerializableObject(obj)),
            url: baseUrl + path
          };
          return (await got.post(req).json()) || undefined;
        } catch (error) {
          if (error instanceof RequestError) {
            if (error instanceof HTTPError) {
              const typedError = util.fromSerializableObject(error.response.body, () => ProviderError.prototype);
              if (mapError) return mapError(typedError, method);
              throw new ProviderError(ProviderFailure.Unknown, typedError);
            }
            if (mapError) return mapError(null, method);
            if (['ENOTFOUND', 'ECONNREFUSED'].includes(error.code)) {
              throw new ProviderError(ProviderFailure.ConnectionFailure, error, error.code);
            }
          }
          throw new ProviderError(ProviderFailure.Unknown, error);
        }
      };
    }
  });
