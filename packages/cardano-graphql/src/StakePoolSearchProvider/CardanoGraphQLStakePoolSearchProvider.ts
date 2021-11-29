import {
  Cardano,
  InvalidStringError,
  ProviderError,
  ProviderFailure,
  StakePoolSearchProvider,
  util
} from '@cardano-sdk/core';
import { GraphQLClient } from 'graphql-request';
import { getSdk } from '../sdk';

export type GraphQLClien = GraphQLClient['options'];

type Awaited<T> = T extends PromiseLike<infer U> ? U : T;
type GraphqlStakePool = NonNullable<
  NonNullable<Awaited<ReturnType<ReturnType<typeof getSdk>['StakePoolsByMetadata']>>['queryStakePoolMetadata']>[0]
>['stakePool'];

const toCoreStakePool = (responseStakePool: GraphqlStakePool) => {
  const stakePool = util.replaceNullsWithUndefineds(responseStakePool);
  return {
    ...stakePool,
    cost: BigInt(stakePool.cost),
    hexId: Cardano.PoolIdHex(stakePool.hexId),
    id: Cardano.PoolId(stakePool.id),
    metadata: stakePool.metadata
      ? {
          ...stakePool.metadata,
          ext: stakePool.metadata.ext
            ? {
                ...stakePool.metadata.ext,
                pool: {
                  ...stakePool.metadata.ext.pool,
                  id: Cardano.PoolIdHex(stakePool.metadata.ext.pool.id)
                }
              }
            : undefined,
          extVkey: stakePool.metadata.extVkey ? Cardano.VrfVkBech32(stakePool.metadata.extVkey) : undefined
        }
      : undefined,
    metadataJson: stakePool.metadataJson
      ? {
          ...stakePool.metadataJson,
          hash: Cardano.Hash32ByteBase16(stakePool.metadataJson.hash)
        }
      : undefined,
    metrics: {
      ...stakePool.metrics!,
      livePledge: BigInt(stakePool.metrics.livePledge),
      stake: {
        active: BigInt(stakePool.metrics.stake.active),
        live: BigInt(stakePool.metrics.stake.live)
      }
    },
    owners: stakePool.owners.map(Cardano.RewardAccount),
    pledge: BigInt(stakePool.pledge),
    rewardAccount: Cardano.RewardAccount(stakePool.rewardAccount),
    transactions: {
      registration: stakePool.transactions.registration.map(Cardano.TransactionId),
      retirement: stakePool.transactions.retirement.map(Cardano.TransactionId)
    },
    vrf: Cardano.VrfKeyHash(stakePool.vrf)
  };
};

export const createGraphQLStakePoolSearchProvider = (
  url: string,
  options?: RequestInit,
  initSdk = getSdk
): StakePoolSearchProvider => {
  const graphQLClient = new GraphQLClient(url, options);
  const sdk = initSdk(graphQLClient);
  return {
    async queryStakePools(fragments: string[]): Promise<Cardano.StakePool[]> {
      const query = fragments.join(' ');
      try {
        const byStakePoolFields = (await sdk.StakePools({ query })).queryStakePool?.filter(util.isNotNil);
        const byMetadataFields = await sdk.StakePoolsByMetadata({
          omit: byStakePoolFields?.length ? byStakePoolFields?.map((sp) => sp.id) : undefined,
          query
        });
        const responseStakePools = [
          ...(byStakePoolFields || []),
          ...(byMetadataFields.queryStakePoolMetadata || []).map((sp) => sp?.stakePool)
        ].filter(util.isNotNil);
        return responseStakePools.map(toCoreStakePool);
      } catch (error) {
        const failure = error instanceof InvalidStringError ? ProviderFailure.InvalidResponse : ProviderFailure.Unknown;
        throw new ProviderError(failure, error);
      }
    }
  };
};
