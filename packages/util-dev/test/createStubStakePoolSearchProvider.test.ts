import { Cardano, StakePoolSearchProvider } from '@cardano-sdk/core';
import { createStubStakePoolSearchProvider } from '../src/createStubStakePoolSearchProvider';

describe('createStubStakePoolSearchProvider', () => {
  describe('queryStakePools', () => {
    const ID_TO_MATCH = 'id-to-match';
    let provider: StakePoolSearchProvider;
    beforeEach(() => {
      provider = createStubStakePoolSearchProvider([
        { id: ID_TO_MATCH, metadata: { name: 'pool1', ticker: 'TICKR' } },
        { id: 'other-id' }
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      ] as any);
    });
    it('matches by id', async () => {
      const stakePools = await provider.queryStakePools({
        filters: { identifier: { values: [{ id: 'd-to-matc' as unknown as Cardano.PoolId }] } }
      });
      expect(stakePools.pageResults).toHaveLength(1);
      expect(stakePools.totalResultCount).toEqual(1);
      expect(stakePools.pageResults[0].id).toBe(ID_TO_MATCH);
    });

    it('matches by name', async () => {
      const stakePools = await provider.queryStakePools({
        filters: { identifier: { values: [{ name: 'ool1' }] } }
      });
      expect(stakePools.pageResults).toHaveLength(1);
      expect(stakePools.totalResultCount).toEqual(1);
      expect(stakePools.pageResults[0].id).toBe(ID_TO_MATCH);
    });

    it('matches by ticker', async () => {
      const stakePools = await provider.queryStakePools({
        filters: { identifier: { values: [{ ticker: 'TIC' }] } }
      });
      expect(stakePools.pageResults).toHaveLength(1);
      expect(stakePools.totalResultCount).toEqual(1);
      expect(stakePools.pageResults[0].id).toBe(ID_TO_MATCH);
    });
  });
});
