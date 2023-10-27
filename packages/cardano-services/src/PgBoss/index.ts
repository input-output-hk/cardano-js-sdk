import {
  POOL_DELIST_SCHEDULE,
  STAKE_POOL_METADATA_QUEUE,
  STAKE_POOL_METRICS_UPDATE,
  STAKE_POOL_REWARDS
} from '@cardano-sdk/projection-typeorm';
import { PgBossQueue, WorkerHandlerFactory } from './types';
import { stakePoolBatchDelistHandlerFactory } from './stakePoolBatchDelistHandler';
import { stakePoolMetadataHandlerFactory } from './stakePoolMetadataHandler';
import { stakePoolMetricsHandlerFactory } from './stakePoolMetricsHandler';
import { stakePoolRewardsHandlerFactory } from './stakePoolRewardsHandler';

export * from './types';
export * from './util';

/** Defines the _handler_ for each **pg-boss** queue. */
export const queueHandlers: Record<PgBossQueue, WorkerHandlerFactory> = {
  [POOL_DELIST_SCHEDULE]: stakePoolBatchDelistHandlerFactory,
  [STAKE_POOL_METADATA_QUEUE]: stakePoolMetadataHandlerFactory,
  [STAKE_POOL_METRICS_UPDATE]: stakePoolMetricsHandlerFactory,
  [STAKE_POOL_REWARDS]: stakePoolRewardsHandlerFactory
};
