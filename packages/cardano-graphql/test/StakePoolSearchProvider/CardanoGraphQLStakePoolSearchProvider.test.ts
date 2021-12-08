/* eslint-disable max-len */
import { ExtendedPoolStatus, Sdk, StakePoolStatus, StakePoolsByMetadataQuery, StakePoolsQuery } from '../../src/sdk';
import { InvalidStringError, ProviderError, ProviderFailure, StakePoolSearchProvider } from '@cardano-sdk/core';
import { createGraphQLStakePoolSearchProvider } from '../../src/StakePoolSearchProvider/CardanoGraphQLStakePoolSearchProvider';

describe('StakePoolSearchClient', () => {
  let client: StakePoolSearchProvider;
  const sdk = {
    StakePools: jest.fn(),
    StakePoolsByMetadata: jest.fn()
  };
  beforeEach(() => {
    client = createGraphQLStakePoolSearchProvider('http://someurl.com', undefined, () => sdk as unknown as Sdk);
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
            hexId: '52e22df52e90370f639c99f5c760f0cd67d7f871cd0d0764fae47cd9',
            id: 'pool12t3zmafwjqms7cuun86uwc8se4na07r3e5xswe86u37djr5f0lx',
            margin: {
              denominator: 3,
              numerator: 1
            },
            metadata: {
              description: 'some pool desc',
              ext: {
                pool: {
                  country: 'LT',
                  id: '52e22df52e90370f639c99f5c760f0cd67d7f871cd0d0764fae47cd9',
                  status: ExtendedPoolStatus.Active
                },
                serial: 123
              },
              extDataUrl: 'http://extdata',
              extSigUrl: 'http://extsig',
              extVkey: 'poolmd_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4stmm43m',
              homepage: 'http://homepage',
              name: 'some pool',
              ticker: 'TICKR'
            },
            metadataJson: {
              hash: '886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8',
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
            owners: ['stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27'],
            pledge: '1235',
            relays: [
              { __typename: 'RelayByName', hostname: 'http://relay', port: 156 },
              { __typename: 'RelayByAddress', ipv4: '0.0.0.0', ipv6: '::1', port: 567 }
            ],
            rewardAccount: 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27',
            status: StakePoolStatus.Active,
            transactions: {
              registration: ['4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6'],
              retirement: ['01d7366549986d83edeea262e97b68eca3430d3bb052ed1c37d2202fd5458872']
            },
            vrf: '8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0'
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
