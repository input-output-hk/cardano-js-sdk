import { ProviderError, ProviderFailure } from '@cardano-sdk/core';

export const getExactlyOneObject = <T>(objects: (T | undefined | null)[] | undefined | null, objectName: string) => {
  if (!objects || objects.length === 0) throw new ProviderError(ProviderFailure.NotFound, null, objectName);
  if (objects.length !== 1)
    throw new ProviderError(ProviderFailure.InvalidResponse, null, `Expected exactly 1 ${objectName} object`);
  const [obj] = objects;
  if (!obj) throw new ProviderError(ProviderFailure.InvalidResponse, null, objectName);
  return obj;
};

export type GetExactlyOneObject = typeof getExactlyOneObject;
