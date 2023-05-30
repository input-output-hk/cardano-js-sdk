import { DataSource } from 'typeorm';
import { Logger } from 'ts-log';
import { Pool } from 'pg';
import { STAKE_POOL_METADATA_QUEUE, STAKE_POOL_METRICS_UPDATE } from '@cardano-sdk/projection-typeorm';

export const workerQueues = [STAKE_POOL_METADATA_QUEUE, STAKE_POOL_METRICS_UPDATE] as const;

export type PgBossQueue = typeof workerQueues[number];

export interface WorkerHandlerFactoryOptions {
  dataSource: DataSource;
  db: Pool;
  logger: Logger;
  stakePoolProviderUrl: string;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type WorkerHandler = (data: any) => Promise<void>;
export type WorkerHandlerFactory = (options: WorkerHandlerFactoryOptions) => WorkerHandler;
