import { Cardano, StakePoolProvider } from '@cardano-sdk/core';
import { CurrentPoolMetricsEntity } from '@cardano-sdk/projection-typeorm';
import { DataSource } from 'typeorm';
import { Percent } from '@cardano-sdk/util';
import { initHandlerTest, poolId } from './util';
import { logger } from '@cardano-sdk/util-dev';
import { savePoolMetrics } from '../../src/PgBoss';

describe('stakePoolMetricsHandler', () => {
  let dataSource: DataSource;

  beforeAll(async () => {
    const testData = await initHandlerTest();

    ({ dataSource } = testData);
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

    const metrics: Cardano.StakePoolMetrics = {
      blocksCreated: 23,
      delegators: 15,
      livePledge: 23_000_000n,
      saturation: Percent(0.002),
      size: { active: Percent(0.0005), live: Percent(0.0005) },
      stake: { active: 42_000_000n, live: 42_000_000n }
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

    it('inserts and updates the record', async () => {
      const metricsRepos = dataSource.getRepository(CurrentPoolMetricsEntity);
      const where = { stakePool: { id: poolId } };

      // No records before insert
      expect(await metricsRepos.find({ where })).toEqual([]);

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
      const metricsRepos = dataSource.getRepository(CurrentPoolMetricsEntity);
      const stakePool = { id: 'does not exist' as Cardano.PoolId };
      const where = { stakePool };

      // No records before insert attempt
      expect(await metricsRepos.find({ where })).toEqual([]);

      // Failing insert attempt
      await savePoolMetrics({ ...partialOptions, ...stakePool, slot: Cardano.Slot(123) });

      // No records was inserted
      expect(await metricsRepos.find({ where })).toEqual([]);
    });
  });
});
