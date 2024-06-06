import type { Cardano } from '@cardano-sdk/core';
import type { DataSource } from 'typeorm';
import type { Logger } from 'ts-log';
import type { PgBossWorkerArgs } from '../Program/services/pgboss.js';
import type { Pool } from 'pg';
import type { PoolRegistrationEntity, PoolRewardsEntity, availableQueues } from '@cardano-sdk/projection-typeorm';

export type PgBossQueue = (typeof availableQueues)[number];

export type WorkerHandlerFactoryOptions = {
  dataSource: DataSource;
  db: Pool;
  logger: Logger;
} & PgBossWorkerArgs;

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type WorkerHandler = (data: any) => Promise<void>;
export type WorkerHandlerFactory = (options: WorkerHandlerFactoryOptions) => WorkerHandler;

/**
 * The context in which the _stake pool rewards computation process_ runs, for a given stake pool, in a given epoch.
 *
 * It extends `PoolRewardsEntity`, other properties are input parameters or intermediate input parameter
 * for the _computation process_.
 *
 * Each function taking part to the _computation process_ adds its result to the context so it can be
 * used as input data for next functions or can compete to the composition of the final
 * `PoolRewardsEntity` which will be saved to the DB.
 */
export type RewardsComputeContext = {
  dataSource: DataSource;
  db: Pool;
  delegatorsIds?: string[];
  idx: number;
  lastSlot: Cardano.Slot;
  lastRosEpochs: number;
  logger: Logger;
  membersIds?: string[];
  ownersIds?: string[];
  poolHashId?: string;
  registration?: PoolRegistrationEntity;
  totalStakePools: number;
} & PoolRewardsEntity &
  Required<Pick<PoolRewardsEntity, 'epochNo' | 'stakePool'>>;

/** The input parameters to `computeROS`. */
export type RosComputeParams = Pick<RewardsComputeContext, 'dataSource' | 'logger' | 'stakePool'> & {
  epochs?: number;
};
