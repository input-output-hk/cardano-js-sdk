import { CardanoGraphQLStakePoolSearchProvider } from '../src/CardanoGraphQLStakePoolSearchProvider';

jest.mock('../src/fetchExtendedMetadata');
jest.mock('../src/queryStakePoolsWithMetadata');

const { fetchExtendedMetadata } = jest.requireMock('../src/fetchExtendedMetadata');
const { queryStakePoolsWithMetadata } = jest.requireMock('../src/queryStakePoolsWithMetadata');

describe('CardanoGraphQLStakePoolSearchProvider', () => {
  const fragments = ['some', 'stake', 'pools'];
  let provider: CardanoGraphQLStakePoolSearchProvider;

  beforeEach(() => {
    provider = new CardanoGraphQLStakePoolSearchProvider();
  });

  afterEach(() => {
    queryStakePoolsWithMetadata.mockReset();
    fetchExtendedMetadata.mockReset();
  });

  describe('queryStakePools', () => {
    const stakePools = [{}, { metadata: { extDataUrl: 'some-url' } }, { metadata: {} }];
    beforeEach(() => {
      queryStakePoolsWithMetadata.mockResolvedValueOnce(stakePools);
    });
    describe('[fetchExt = false]', () => {
      it('queries and returns stake pools without fetching extended metadata', async () => {
        expect(await provider.queryStakePools(fragments)).toBe(stakePools);
        expect(queryStakePoolsWithMetadata).toBeCalledWith(fragments);
        expect(fetchExtendedMetadata).not.toBeCalled();
      });
    });
    describe('[fetchExt = true]', () => {
      it('queries stake pools and fetches ext metadata for pools with extDataUrl specified', async () => {
        queryStakePoolsWithMetadata.mockResolvedValueOnce(stakePools);
        const ext = {
          doesnt: 'matter'
        };
        fetchExtendedMetadata.mockResolvedValueOnce(ext);
        expect(await provider.queryStakePools(fragments, true)).toEqual([
          {},
          { metadata: { extDataUrl: 'some-url', ext } },
          { metadata: {} }
        ]);
        expect(fetchExtendedMetadata).toBeCalledTimes(1);
      });
    });
  });
});
