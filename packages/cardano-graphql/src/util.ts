/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano, InvalidStringError, ProviderError, ProviderFailure, ProviderUtil, util } from '@cardano-sdk/core';
import { GraphQLClient } from 'graphql-request';
import { Sdk, StakePoolsQuery, getSdk } from './sdk';

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

export type GetExactlyOneObject = typeof getExactlyOneObject;

export type GraphqlStakePool = NonNullable<NonNullable<StakePoolsQuery['queryStakePool']>[0]>;
type ResponsePoolParameters = NonNullable<GraphqlStakePool['poolParameters'][0]>;
export const toCorePoolParameters = (
  poolParameters: ResponsePoolParameters,
  poolId: string
): Cardano.PoolParameters => ({
  cost: BigInt(poolParameters.cost),
  id: Cardano.PoolId(poolId),
  margin: poolParameters.margin,
  metadataJson: poolParameters.metadataJson
    ? {
        ...poolParameters.metadataJson,
        hash: Cardano.Hash32ByteBase16(poolParameters.metadataJson.hash)
      }
    : undefined,
  owners: poolParameters.owners.map(({ address }) => Cardano.RewardAccount(address)),
  pledge: BigInt(poolParameters.pledge),
  relays: util.replaceNullsWithUndefineds(poolParameters.relays),
  rewardAccount: Cardano.RewardAccount(poolParameters.rewardAccount.address),
  vrf: Cardano.VrfVkHex(poolParameters.vrf)
});
