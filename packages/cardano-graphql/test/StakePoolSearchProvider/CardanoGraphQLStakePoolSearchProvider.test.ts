/* eslint-disable max-len */
import { ExtendedPoolStatus, StakePoolStatus, StakePoolsByMetadataQuery, StakePoolsQuery } from '../../src/sdk';
import { InvalidStringError, ProviderError, ProviderFailure, StakePoolSearchProvider } from '@cardano-sdk/core';
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
            cost: '123',
            hexId: 'e4b1c8ec89415ce6349755a1aa44b4affbb5f1248ff29943d190c715',
            id: 'pool1ujcu3myfg9wwvdyh2ks653954lamtufy3lefjs73jrr327q53j4',
            margin: {
              denominator: 3,
              numerator: 1
            },
            metadata: {
              description: 'some pool desc',
              ext: {
                pool: {
                  country: 'LT',
                  id: 'e4b1c8ec89415ce6349755a1aa44b4affbb5f1248ff29943d190c715',
                  status: ExtendedPoolStatus.Active
                },
                serial: 123
              },
              extDataUrl: 'http://extdata',
              extSigUrl: 'http://extsig',
              extVkey: '2abc',
              homepage: 'http://homepage',
              name: 'some pool',
              ticker: 'TICKR'
            },
            metadataJson: {
              hash: '1abc',
              url: 'http://someurl'
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
            relays: [
              { __typename: 'RelayByName', hostname: 'http://relay', port: 156 },
              { __typename: 'RelayByAddress', ipv4: '0.0.0.0', ipv6: '::1', port: 567 }
            ],
            rewardAccount: '745b',
            status: StakePoolStatus.Active,
            transactions: {
              registration: ['6345b'],
              retirement: ['dawdb']
            },
            vrf: '76bc'
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
        omit: [stakePoolsQueryResponse.queryStakePool![0]!.id],
        query: 'some stake pools'
      });
      expect(typeof response[0]).toBe('object');
      expect(typeof response[0].cost).toBe('bigint');
      expect(typeof response[0].metadata).toBe('object');
      expect(typeof response[0].metadata!.ext).toBe('object');
      expect(response[0].status).toBe(StakePoolStatus.Active);
      expect(response[0].margin.numerator).toBe(1);
      expect(response[1].metadata).toBeUndefined();
    });

    it('wraps errors to ProviderError', async () => {
      sdk.StakePools.mockRejectedValueOnce(new Error('some error'));
      await expect(client.queryStakePools(['stakepool'])).rejects.toThrowError(ProviderError);

      const invalidStringError = new InvalidStringError('some error');
      sdk.StakePools.mockRejectedValueOnce(invalidStringError);
      await expect(client.queryStakePools(['stakepool'])).rejects.toThrowError(
        new ProviderError(ProviderFailure.InvalidResponse, invalidStringError)
      );
    });
  });
});
