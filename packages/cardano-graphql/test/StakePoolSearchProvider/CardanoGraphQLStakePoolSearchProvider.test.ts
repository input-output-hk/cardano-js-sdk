/* eslint-disable max-len */
import { ProviderError, StakePoolSearchProvider } from '@cardano-sdk/core';
import { StakePoolsQuery, StakePoolsByMetadataQuery, PoolStatus } from '../../src/sdk';
import { createGraphQLStakePoolSearchProvider } from '../../src/StakePoolSearchProvider/CardanoGraphQLStakePoolSearchProvider';

describe('StakePoolSearchClient', () => {
  let client: StakePoolSearchProvider;
  const sdk = {
    StakePools: jest.fn(),
    StakePoolsByMetadata: jest.fn()
  };
  beforeEach(() => {
    client = createGraphQLStakePoolSearchProvider('http://someurl.com', undefined, () => sdk);
  });
  afterEach(() => {
    sdk.StakePools.mockReset();
    sdk.StakePoolsByMetadata.mockReset();
  });

  describe('queryStakePoolsWithMetadata', () => {
    it('makes a graphql query and coerces result to core types', async () => {
      const stakePoolsQueryResponse: StakePoolsQuery = {
        queryStakePool: [
          {
            id: 'some-pool',
            hexId: '0abc',
            cost: '123',
            margin: 0.15,
            metadataJson: {
              hash: '1abc',
              url: 'http://someurl'
            },
            metadata: {
              description: 'some pool desc',
              name: 'some pool',
              homepage: 'http://homepage',
              ticker: 'TICKR',
              extDataUrl: 'http://extdata',
              extSigUrl: 'http://extsig',
              extVkey: '2abc',
              ext: {
                serial: 123,
                pool: {
                  id: 'pool-id',
                  status: PoolStatus.Active,
                  country: 'LT'
                }
              }
            },
            metrics: {
              blocksCreated: 123,
              delegators: 234,
              livePledge: '1234',
              saturation: 0.1,
              size: {
                active: 0.2,
                live: 0.15
              },
              stake: {
                active: '12345',
                live: '12344'
              }
            },
            owners: ['5bd'],
            pledge: '1235',
            vrf: '76bc',
            rewardAccount: '745b',
            transactions: {
              registration: ['6345b'],
              retirement: ['dawdb']
            },
            relays: [
              { __typename: 'RelayByName', hostname: 'http://relay', port: 156 },
              { __typename: 'RelayByAddress', port: 567, ipv4: '0.0.0.0', ipv6: '::1' }
            ]
          }
        ]
      };
      const stakePoolsQueryByMetadataResponse: StakePoolsByMetadataQuery = {
        queryStakePoolMetadata: [
          {
            stakePool: {
              ...stakePoolsQueryResponse.queryStakePool![0]!,
              metadata: undefined
            }
          }
        ]
      };
      sdk.StakePools.mockResolvedValue(stakePoolsQueryResponse);
      sdk.StakePoolsByMetadata.mockResolvedValueOnce(stakePoolsQueryByMetadataResponse);
      const response = await client.queryStakePools(['some', 'stake', 'pools']);

      expect(response).toHaveLength(2);
      expect(sdk.StakePoolsByMetadata).toBeCalledWith({
        query: 'some stake pools',
        omit: [stakePoolsQueryResponse.queryStakePool![0]!.id]
      });
      expect(typeof response[0]).toBe('object');
      expect(typeof response[0].cost).toBe('bigint');
      expect(typeof response[0].metadata).toBe('object');
      expect(typeof response[0].metadata!.ext).toBe('object');
      expect(response[1].metadata).toBeUndefined();
    });

    it('wraps errors to ProviderError', async () => {
      sdk.StakePools.mockRejectedValueOnce(new Error('some error'));
      await expect(client.queryStakePools(['stakepool'])).rejects.toThrowError(ProviderError);
    });
  });
});
