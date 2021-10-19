import { ProviderError, ProviderFailure, Cardano, StakePoolSearchProvider } from '@cardano-sdk/core';
import { gql, GraphQLClient } from 'graphql-request';
import { StakePoolsQueryResponse } from './types';

export const createGraphQLStakePoolSearchProvider = (graphQLClient: GraphQLClient): StakePoolSearchProvider => ({
  async queryStakePools(fragments: string[]): Promise<Cardano.StakePool[]> {
    const query = gql`
      stakePools($partialIdsNamesOrTickers) {
        id
        hexId
        owners
        cost
        margin
        vrf
        relays {
          __typename
          ... on StakePoolRelayByName {
            hostname
            port
          }
          ... on StakePoolRelayByAddress {
            ipv4
            ipv6
            port
          }
        }
        rewardAccount
        pledge
        metrics {
          blocksCreated
          livePledge
          stake {
            live
            active
          }
          size {
            live
            active
          }
          saturation
          delegators
        }
        transactions {
          registration
          retirement
        }
        metadataJson {
          hash
          url
        }
        metadata {
          ticker
          name
          description
          homepage
          extDataUrl
          extSigUrl
          extVkey
        }
      }
    `;

    try {
      const response = await graphQLClient.request<StakePoolsQueryResponse>(query, {
        partialIdsNamesOrTickers: fragments
      });
      return response.stakePools.map((stakePool) => ({
        ...stakePool,
        pledge: BigInt(stakePool.pledge),
        metrics: {
          ...stakePool.metrics,
          livePledge: BigInt(stakePool.metrics.livePledge),
          stake: {
            active: BigInt(stakePool.metrics.stake.active),
            live: BigInt(stakePool.metrics.stake.live)
          }
        },
        metadata: {
          ...stakePool.metadata,
          extDataUrl: stakePool.metadata.extDataUrl || undefined,
          extSigUrl: stakePool.metadata.extSigUrl || undefined,
          extVkey: stakePool.metadata.extVkey || undefined
        },
        cost: BigInt(stakePool.cost)
      }));
    } catch (error) {
      throw new ProviderError(ProviderFailure.Unknown, error);
    }
  }
});
