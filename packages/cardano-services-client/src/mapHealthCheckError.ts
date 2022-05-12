import { ProviderError, ProviderFailure } from '@cardano-sdk/core';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const mapHealthCheckError = (error: any) => {
  if (!error) {
    return { ok: false };
  }
  throw new ProviderError(ProviderFailure.Unknown, error);
};
