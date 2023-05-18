import { DataSource } from 'typeorm';
import { Logger } from 'ts-log';
import { STAKE_POOL_METADATA_QUEUE } from '@cardano-sdk/projection-typeorm';

export const workerQueues = [STAKE_POOL_METADATA_QUEUE] as const;

export type PgBossQueue = typeof workerQueues[number];

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type WorkerHandler = (data: any) => Promise<void>;
export type WorkerHandlerFactory = (dataSource: DataSource, logger: Logger) => WorkerHandler;
