import { PgBossQueue, WorkerHandlerFactory, workerQueues } from './types';
import { STAKE_POOL_METADATA_QUEUE } from '@cardano-sdk/projection-typeorm';
import { stakePoolMetadataHandlerFactory } from './stakePoolMetadataHandler';

export const isValidQueue = (queue: string): queue is PgBossQueue => workerQueues.includes(queue as PgBossQueue);

/**
 * Defines the handler for each pg-boss queue
 */
export const queueHandlers: Record<PgBossQueue, WorkerHandlerFactory> = {
  [STAKE_POOL_METADATA_QUEUE]: stakePoolMetadataHandlerFactory
};
