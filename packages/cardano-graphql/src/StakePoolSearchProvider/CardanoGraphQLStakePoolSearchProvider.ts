import { ProviderError, ProviderFailure, Cardano, StakePoolSearchProvider } from '@cardano-sdk/core';
import { GraphQLClient } from 'graphql-request';
import { getSdk } from '../sdk';
import { replaceNullsWithUndefineds } from '../util';

export const createGraphQLStakePoolSearchProvider = (graphQLClient: GraphQLClient): StakePoolSearchProvider => {
  const sdk = getSdk(graphQLClient);
  return {
    async queryStakePools(fragments: string[]): Promise<Cardano.StakePool[]> {
      try {
        const response = await sdk.StakePoolsByFragments({ fragments });
        return response.stakePoolsByFragments.map((responseStakePool) => {
          const stakePool = replaceNullsWithUndefineds(responseStakePool);
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
            cost: BigInt(stakePool.cost)
          };
        });
      } catch (error) {
        throw new ProviderError(ProviderFailure.Unknown, error);
      }
    }
  };
};
