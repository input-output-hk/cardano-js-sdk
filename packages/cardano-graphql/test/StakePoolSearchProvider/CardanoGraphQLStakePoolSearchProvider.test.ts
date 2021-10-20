/* eslint-disable max-len */
import { ProviderError, StakePoolSearchProvider } from '@cardano-sdk/core';
import { GraphQLClient } from 'graphql-request';
import { StakePoolsByFragmentsQuery } from '../../src/sdk';
import { createGraphQLStakePoolSearchProvider } from '../../src/StakePoolSearchProvider/CardanoGraphQLStakePoolSearchProvider';
const mockRequest = (GraphQLClient.prototype.request = jest.fn());

describe('StakePoolSearchClient', () => {
  let client: StakePoolSearchProvider;
  beforeEach(() => {
    client = createGraphQLStakePoolSearchProvider(new GraphQLClient('http://someurl.com'));
  });

  describe('queryStakePoolsWithMetadata', () => {
    it('makes a graphql query and coerces result to core types', async () => {
      const mockedResponse: StakePoolsByFragmentsQuery = {
        stakePoolsByFragments: [
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
                  status: 'active',
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
      mockRequest.mockResolvedValueOnce(mockedResponse);
      const response = await client.queryStakePools(['some', 'stake', 'pools']);

      expect(typeof response[0]).toBe('object');
      expect(typeof response[0].cost).toBe('bigint');
      expect(typeof response[0].metadata).toBe('object');
      expect(typeof response[0].metadata!.ext).toBe('object');
    });

    it('wraps errors to ProviderError', async () => {
      mockRequest.mockRejectedValueOnce(new Error('some error'));
      await expect(client.queryStakePools(['stakepool'])).rejects.toThrowError(ProviderError);
    });
  });
});
