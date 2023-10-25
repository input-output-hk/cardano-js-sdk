import { Cardano, StakePoolProvider } from '@cardano-sdk/core';
import { CurrentPoolMetricsEntity, StakePoolEntity } from '@cardano-sdk/projection-typeorm';
import { DataSource } from 'typeorm';
import { Percent } from '@cardano-sdk/util';
import { Repository } from 'typeorm/repository/Repository';
import { getPoolIdsToUpdate, savePoolMetrics } from '../../src/PgBoss/stakePoolMetricsHandler';
import { initHandlerTest, poolId } from './util';
import { logger } from '@cardano-sdk/util-dev';

describe('stakePoolMetricsHandler', () => {
  let dataSource: DataSource;
  let metricsRepos: Repository<CurrentPoolMetricsEntity>;
  const metrics: Cardano.StakePoolMetrics = {
    blocksCreated: 23,
    delegators: 15,
    livePledge: 23_000_000n,
    saturation: Percent(0.002),
    size: { active: Percent(0.0005), live: Percent(0.0005) },
    stake: { active: 42_000_000n, live: 42_000_000n }
  };

  beforeAll(async () => {
    const testData = await initHandlerTest();
    ({ dataSource } = testData);

    metricsRepos = dataSource.getRepository(CurrentPoolMetricsEntity);
  });

  describe('getPoolIdsToUpdate', () => {
    const partialOptions = {
      dataSource,
      id: poolId,
      logger,
      metrics,
      provider: null as unknown as StakePoolProvider
    };

    // Pool id is fixed to 56 chars in the database
    const outdatedId = 'test_pool_outdated'.padEnd(56, ' ') as Cardano.PoolId;

    beforeAll(async () => {
      // Override the original undefined value with the one got from initHandlerTest()
      partialOptions.dataSource = dataSource;

      // database preparation

      await savePoolMetrics({
        ...partialOptions,
        slot: Cardano.Slot(1000)
      });

      const stakePoolRepository = dataSource.getRepository(StakePoolEntity);
      await stakePoolRepository.insert({ id: outdatedId, status: 'active' });

      await savePoolMetrics({
        ...partialOptions,
        id: outdatedId,
        slot: Cardano.Slot(333)
      });
    });

    it('returns only pool ids with outdated metrics', async () => {
      const pools = await getPoolIdsToUpdate(dataSource, Cardano.Slot(1000));
      const allMetrics = await metricsRepos.find();

      expect(pools.length).toEqual(1);
      expect(allMetrics.length).toEqual(2);
      expect(pools[0].id).toEqual(outdatedId);
    });

    it('returns all pool ids', async () => {
      const pools = await getPoolIdsToUpdate(dataSource);

      expect(pools.map((p) => p.id)).toEqual([poolId, outdatedId]);
    });
  });

  describe('savePoolMetrics', () => {
    const partialExpectedRecord = {
      activeSize: 0.0005,
      activeStake: 42_000_000n,
      apy: 0,
      livePledge: 23_000_000n,
      liveSaturation: 0.002,
      liveSize: 0.0005,
      liveStake: 42_000_000n,
      stakePoolId: 'test_pool                                               '
    };

    const partialOptions = {
      dataSource,
      id: poolId,
      logger,
      metrics,
      provider: null as unknown as StakePoolProvider
    };

    beforeAll(() => {
      // Override the original undefined value with the one got from initHandlerTest()
      partialOptions.dataSource = dataSource;
    });
    beforeEach(async () => {
      await metricsRepos.clear();
    });

    it('inserts and updates the record', async () => {
      const where = { stakePool: { id: poolId } };

      // Insert
      await savePoolMetrics({ ...partialOptions, slot: Cardano.Slot(123) });

      // One record was inserted
      const insertResult = await metricsRepos.find({ where });
      expect(insertResult).toEqual([{ ...partialExpectedRecord, liveDelegators: 15, mintedBlocks: 23, slot: 123 }]);

      // Update
      metrics.blocksCreated = 26;
      metrics.delegators = 16;
      await savePoolMetrics({ ...partialOptions, slot: Cardano.Slot(223) });

      // One record updated and no records inserted
      const updateResult = await metricsRepos.find({ where });
      expect(updateResult).toEqual([{ ...partialExpectedRecord, liveDelegators: 16, mintedBlocks: 26, slot: 223 }]);
    });

    it('does nothing if stake pool record does not exist', async () => {
      const stakePool = { id: 'does not exist' as Cardano.PoolId };
      const where = { stakePool };

      // Failing insert attempt
      await savePoolMetrics({ ...partialOptions, ...stakePool, slot: Cardano.Slot(123) });

      // No records was inserted
      expect(await metricsRepos.find({ where })).toEqual([]);
    });
  });
});
