/* eslint-disable @typescript-eslint/no-explicit-any */
export type ToProviderError = (error: unknown) => void;

export const withProviderErrors = <T>(providerImplementation: T, toProviderError: ToProviderError) =>
  Object.keys(providerImplementation).reduce((provider, key) => {
    const originalValue = (providerImplementation as any)[key];
    provider[key] =
      typeof originalValue === 'function'
        ? (...args: any[]) => originalValue(...args).catch(toProviderError)
        : originalValue;
    return provider;
  }, {} as any) as T;
