import { ProviderError, ProviderFailure } from '@cardano-sdk/core';

export const ORIGIN = 'Origin';
export const CONTENT_TYPE = 'Content-Type';
export const APPLICATION_JSON = 'application/json';

export const getListen = (url: URL) => ({ host: url.hostname, port: Number.parseInt(url.port) });

type StaticOrigin = boolean | string | RegExp | (boolean | string | RegExp)[];

export const corsOptions = (allowedOrigins: Set<string>) => ({
  origin(requestOrigin: string | undefined, callback: (err: Error | null, options?: StaticOrigin) => void) {
    if (requestOrigin && allowedOrigins.has(requestOrigin)) {
      callback(null, requestOrigin);
    } else {
      callback(new ProviderError(ProviderFailure.Forbidden, null, `Origin ${requestOrigin} not allowed by CORS`));
    }
  }
});
