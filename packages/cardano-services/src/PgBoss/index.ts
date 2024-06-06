import {
  POOL_DELIST_SCHEDULE,
  STAKE_POOL_METADATA_QUEUE,
  STAKE_POOL_METRICS_UPDATE,
  STAKE_POOL_REWARDS
} from '@cardano-sdk/projection-typeorm';
import { stakePoolBatchDelistHandlerFactory } from './stakePoolBatchDelistHandler.js';
import { stakePoolMetadataHandlerFactory } from './stakePoolMetadataHandler.js';
import { stakePoolMetricsHandlerFactory } from './stakePoolMetricsHandler.js';
import { stakePoolRewardsHandlerFactory } from './stakePoolRewardsHandler.js';
import type { PgBossQueue, WorkerHandlerFactory } from './types.js';

export * from './types.js';
export * from './util.js';

/** Defines the _handler_ for each **pg-boss** queue. */
export const queueHandlers: Record<PgBossQueue, WorkerHandlerFactory> = {
  [POOL_DELIST_SCHEDULE]: stakePoolBatchDelistHandlerFactory,
  [STAKE_POOL_METADATA_QUEUE]: stakePoolMetadataHandlerFactory,
  [STAKE_POOL_METRICS_UPDATE]: stakePoolMetricsHandlerFactory,
  [STAKE_POOL_REWARDS]: stakePoolRewardsHandlerFactory
};
