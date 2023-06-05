import { Cardano, StakePoolProvider } from '@cardano-sdk/core';
import { CurrentPoolMetricsEntity, StakePoolEntity, StakePoolMetricsUpdateJob } from '@cardano-sdk/projection-typeorm';
import { DataSource } from 'typeorm';
import { Logger } from 'ts-log';
import { WorkerHandlerFactory } from './types';
import { isErrorWithConstraint } from './util';
import { stakePoolHttpProvider } from '@cardano-sdk/cardano-services-client';

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
    apy: metrics.apy || 0,
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

export const stakePoolMetricsHandlerFactory: WorkerHandlerFactory = (options) => {
  const { dataSource, logger, stakePoolProviderUrl } = options;
  const provider = stakePoolHttpProvider({ baseUrl: stakePoolProviderUrl, logger });

  return async (data: StakePoolMetricsUpdateJob) => {
    const { slot } = data;

    logger.info('Starting stake pools metrics job');

    const pools = await dataSource.getRepository(StakePoolEntity).find({ select: { id: true } });

    for (const { id } of pools) await refreshPoolMetrics({ dataSource, id: id!, logger, provider, slot });
  };
};
