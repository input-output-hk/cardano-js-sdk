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
        return responseStakePools.map((responseStakePool) => {
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
                    : undefined
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
            pledge: BigInt(stakePool.pledge)
          };
        });
      } catch (error) {
        const failure = error instanceof InvalidStringError ? ProviderFailure.InvalidResponse : ProviderFailure.Unknown;
        throw new ProviderError(failure, error);
      }
    }
  };
};
