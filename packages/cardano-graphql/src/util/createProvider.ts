/* eslint-disable @typescript-eslint/no-explicit-any */
import { GraphQLClient } from 'graphql-request';
import { InvalidStringError, ProviderError, ProviderFailure, ProviderUtil } from '@cardano-sdk/core';
import { Sdk, getSdk } from '../sdk';

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
