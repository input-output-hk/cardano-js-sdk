import { CurrentPoolMetricsEntity, STAKE_POOL_METRICS_UPDATE, StakePoolEntity } from '@cardano-sdk/projection-typeorm';
import { LessThan } from 'typeorm';
import { ServiceNames } from '../Program/programs/types.js';
import { isErrorWithConstraint } from './util.js';
import { missingProviderUrlOption } from '../Program/options/index.js';
import { stakePoolHttpProvider } from '@cardano-sdk/cardano-services-client';
import type { Cardano, StakePoolProvider } from '@cardano-sdk/core';
import type { DataSource } from 'typeorm';
import type { Logger } from 'ts-log';
import type { StakePoolMetricsUpdateJob } from '@cardano-sdk/projection-typeorm';
import type { WorkerHandlerFactory } from './types.js';

interface RefreshPoolMetricsOptions {
  dataSource: DataSource;
  id: Cardano.PoolId;
  logger: Logger;
  provider: StakePoolProvider;
  slot: Cardano.Slot;
}

export const savePoolMetrics = async (options: RefreshPoolMetricsOptions & { metrics: Cardano.StakePoolMetrics }) => {
  const { dataSource, id, metrics, slot } = options;
  const repos = dataSource.getRepository(CurrentPoolMetricsEntity);
  const entity = {
    activeSize: metrics.size.active,
    activeStake: metrics.stake.active,
    id,
    liveDelegators: metrics.delegators,
    livePledge: metrics.livePledge,
    liveSaturation: metrics.saturation,
    liveSize: metrics.size.live,
    liveStake: metrics.stake.live,
    mintedBlocks: metrics.blocksCreated,
    slot,
    stakePool: { id }
  };

  try {
    await repos.upsert(entity, ['stakePool']);
  } catch (error) {
    // If no poolRegistration record is present, it was rolled back: do nothing
    if (isErrorWithConstraint(error) && error.constraint === 'FK_current_pool_metrics_stake_pool_id') return;

    throw error;
  }
};

export const refreshPoolMetrics = async (options: RefreshPoolMetricsOptions) => {
  const { id, logger, provider } = options;

  logger.info(`Refreshing metrics for stake pool ${id}`);

  try {
    const { pageResults, totalResultCount } = await provider.queryStakePools({
      filters: { identifier: { values: [{ id }] } },
      pagination: { limit: 1, startAt: 0 }
    });

    if (totalResultCount === 0) return logger.warn(`No data fetched for stake pool ${id}`);

    const { metrics } = pageResults[0];

    if (!metrics) return logger.warn(`No metrics found for stake pool ${id}`);

    await savePoolMetrics({ ...options, metrics });
  } catch (error) {
    logger.error(`Error while refreshing metrics for stake pool ${id}`, error);
  }
};

export const getPoolIdsToUpdate = async (dataSource: DataSource, outdatedSlot?: Cardano.Slot) =>
  outdatedSlot
    ? await dataSource.getRepository(StakePoolEntity).find({
        select: { id: true },
        where: [{ metrics: { slot: LessThan(outdatedSlot) } }, { metrics: undefined }]
      })
    : await dataSource.getRepository(StakePoolEntity).find({ select: { id: true } });

export const stakePoolMetricsHandlerFactory: WorkerHandlerFactory = (options) => {
  const { dataSource, logger, stakePoolProviderUrl } = options;

  if (!stakePoolProviderUrl) throw missingProviderUrlOption(STAKE_POOL_METRICS_UPDATE, ServiceNames.StakePool);

  const provider = stakePoolHttpProvider({ baseUrl: stakePoolProviderUrl, logger });

  return async (data: StakePoolMetricsUpdateJob) => {
    const { slot, outdatedSlot } = data;

    logger.info(
      `Starting stake pools metrics job for slot ${slot}, updating ${outdatedSlot ? 'only outdated' : 'all'}`
    );
    const pools = await getPoolIdsToUpdate(dataSource, outdatedSlot);
    for (const { id } of pools) await refreshPoolMetrics({ dataSource, id: id!, logger, provider, slot });
  };
};
