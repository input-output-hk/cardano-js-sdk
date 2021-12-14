/* eslint-disable @typescript-eslint/no-explicit-any */
import { GraphQLClient } from 'graphql-request';
import { InvalidStringError, ProviderError, ProviderFailure, ProviderUtil } from '@cardano-sdk/core';
import { Sdk, getSdk } from './sdk';

export type ProviderFromSdk<T> = (sdk: Sdk) => T;

const toProviderError = (error: unknown) => {
  const failure = error instanceof InvalidStringError ? ProviderFailure.InvalidResponse : ProviderFailure.Unknown;
  throw new ProviderError(failure, error);
};

export const createProvider =
  <T>(providerFromSdk: ProviderFromSdk<T>) =>
  (url: string, options?: RequestInit, initSdk = getSdk): T => {
    const graphQLClient = new GraphQLClient(url, options);
    const sdk = initSdk(graphQLClient);
    return ProviderUtil.withProviderErrors<T>(providerFromSdk(sdk), toProviderError);
  };

export const getExactlyOneObject = <T>(objects: (T | undefined | null)[] | undefined | null, objectName: string) => {
  if (!objects || objects.length === 0) throw new ProviderError(ProviderFailure.NotFound, null, objectName);
  if (objects.length !== 1)
    throw new ProviderError(ProviderFailure.InvalidResponse, null, `Expected exactly 1 ${objectName} object`);
  const [obj] = objects;
  if (!obj) throw new ProviderError(ProviderFailure.InvalidResponse, null, objectName);
  return obj;
};
