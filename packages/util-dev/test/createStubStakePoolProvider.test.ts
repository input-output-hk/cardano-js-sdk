import { Cardano } from '@cardano-sdk/core';
import { createStubStakePoolProvider } from '../src/createStubStakePoolProvider.js';
import type { StakePoolProvider } from '@cardano-sdk/core';

describe('createStubStakePoolProvider', () => {
  let provider: StakePoolProvider;
  describe('queryStakePools', () => {
    const ID_TO_MATCH = 'id-to-match';
    beforeEach(() => {
      provider = createStubStakePoolProvider([
        { id: ID_TO_MATCH, metadata: { name: 'pool1', ticker: 'TICKR' } },
        { id: 'other-id' }
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      ] as any);
    });
    it('matches by id', async () => {
      const stakePools = await provider.queryStakePools({
        filters: { identifier: { values: [{ id: 'd-to-matc' as unknown as Cardano.PoolId }] } },
        pagination: { limit: 25, startAt: 0 }
      });
      expect(stakePools.pageResults).toHaveLength(1);
      expect(stakePools.totalResultCount).toEqual(1);
      expect(stakePools.pageResults[0].id).toBe(ID_TO_MATCH);
    });

    it('matches by name', async () => {
      const stakePools = await provider.queryStakePools({
        filters: { identifier: { values: [{ name: 'ool1' }] } },
        pagination: { limit: 25, startAt: 0 }
      });
      expect(stakePools.pageResults).toHaveLength(1);
      expect(stakePools.totalResultCount).toEqual(1);
      expect(stakePools.pageResults[0].id).toBe(ID_TO_MATCH);
    });

    it('matches by ticker', async () => {
      const stakePools = await provider.queryStakePools({
        filters: { identifier: { values: [{ ticker: 'TIC' }] } },
        pagination: { limit: 25, startAt: 0 }
      });
      expect(stakePools.pageResults).toHaveLength(1);
      expect(stakePools.totalResultCount).toEqual(1);
      expect(stakePools.pageResults[0].id).toBe(ID_TO_MATCH);
    });
  });
  describe('stakePoolStats', () => {
    beforeEach(() => {
      provider = createStubStakePoolProvider([
        ...Array.from({ length: 40 }, () => ({ status: Cardano.StakePoolStatus.Active })),
        ...Array.from({ length: 20 }, () => ({ status: Cardano.StakePoolStatus.Retired })),
        ...Array.from({ length: 10 }, () => ({ status: Cardano.StakePoolStatus.Retiring }))
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      ] as any);
    });

    it('returns active, retired and retiring stake pool count', async () => {
      const stats = await provider.stakePoolStats();
      expect(stats.qty.active).toEqual(40);
      expect(stats.qty.retired).toEqual(20);
      expect(stats.qty.retiring).toEqual(10);
    });
  });
});
