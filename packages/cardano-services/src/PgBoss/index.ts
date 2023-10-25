import { PgBossQueue, WorkerHandlerFactory } from './types';
import { STAKE_POOL_METADATA_QUEUE, STAKE_POOL_METRICS_UPDATE } from '@cardano-sdk/projection-typeorm';
import { stakePoolMetadataHandlerFactory } from './stakePoolMetadataHandler';
import { stakePoolMetricsHandlerFactory } from './stakePoolMetricsHandler';

export * from './types';
export * from './util';

/** Defines the handler for each pg-boss queue */
export const queueHandlers: Record<PgBossQueue, WorkerHandlerFactory> = {
  [STAKE_POOL_METADATA_QUEUE]: stakePoolMetadataHandlerFactory,
  [STAKE_POOL_METRICS_UPDATE]: stakePoolMetricsHandlerFactory
};
