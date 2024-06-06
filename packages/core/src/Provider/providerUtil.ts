import { ProviderError, ProviderFailure } from '../errors.js';
import type * as Cardano from '../Cardano/index.js';

/* eslint-disable @typescript-eslint/no-explicit-any */
export type ToProviderError = (error: unknown) => void;

export const withProviderErrors = <T extends {}>(providerImplementation: T, toProviderError: ToProviderError) =>
  Object.keys(providerImplementation).reduce((provider, key) => {
    const originalValue = (providerImplementation as any)[key];
    provider[key] =
      typeof originalValue === 'function'
        ? (...args: any[]) => originalValue(...args).catch(toProviderError)
        : originalValue;
    return provider;
  }, {} as any) as T;

const tryParseBigIntKey = (key: string) => {
  // skip converting hex values
  if (key.startsWith('0x')) return key.slice(2);
  try {
    return BigInt(key);
  } catch {
    return key;
  }
};

/**
 * Recursively maps JSON metadata to core metadata.
 * As JSON doesn't support numeric keys,
 * this function assumes that all metadata (and metadatum map) keys parseable by BigInt.parse are numeric.
 */
export const jsonToMetadatum = (obj: unknown): Cardano.Metadatum => {
  switch (typeof obj) {
    case 'number':
      return BigInt(obj);
    case 'string':
    case 'bigint':
      return obj;
    case 'object': {
      if (obj === null) break;
      if (Array.isArray(obj)) {
        return obj.map(jsonToMetadatum);
      }
      return new Map(Object.keys(obj).map((key) => [tryParseBigIntKey(key), jsonToMetadatum((obj as any)[key])]));
    }
  }
  throw new ProviderError(ProviderFailure.NotImplemented, null, `Unsupported metadatum type: ${typeof obj}`);
};
