import { ProviderError, ProviderFailure, Cardano, StakePoolSearchProvider } from '@cardano-sdk/core';
import { GraphQLClient } from 'graphql-request';
import { getSdk } from '../sdk';
import { isNotNil, replaceNullsWithUndefineds } from '../util';

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
        const byStakePoolFields = (await sdk.StakePools({ query })).queryStakePool?.filter(isNotNil);
        const byMetadataFields = await sdk.StakePoolsByMetadata({
          query,
          omit: byStakePoolFields?.length ? byStakePoolFields?.map((sp) => sp.id) : undefined
        });
        const responseStakePools = [
          ...(byStakePoolFields || []),
          ...(byMetadataFields.queryStakePoolMetadata || []).map((sp) => sp?.stakePool)
        ].filter(isNotNil);
        return responseStakePools.map((responseStakePool) => {
          const stakePool = replaceNullsWithUndefineds(responseStakePool);
          const metadata = stakePool.metadata;
          const ext = metadata?.ext;
          return {
            ...stakePool,
            pledge: BigInt(stakePool.pledge),
            metrics: {
              ...stakePool.metrics!,
              livePledge: BigInt(stakePool.metrics.livePledge),
              stake: {
                active: BigInt(stakePool.metrics.stake.active),
                live: BigInt(stakePool.metrics.stake.live)
              }
            },
            cost: BigInt(stakePool.cost),
            metadata: metadata
              ? {
                  ...metadata,
                  ext: ext
                    ? {
                        ...ext,
                        pool: {
                          ...ext.pool,
                          status: ext.pool.status as unknown as Cardano.PoolStatus
                        }
                      }
                    : undefined
                }
              : undefined
          };
        });
      } catch (error) {
        throw new ProviderError(ProviderFailure.Unknown, error);
      }
    }
  };
};
