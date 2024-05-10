/* eslint-disable func-style */
/* eslint-disable jsdoc/require-jsdoc */
/* eslint-disable max-len */
/* eslint-disable no-invalid-this */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano } from '@cardano-sdk/core';
import { DataSource, QueryRunner } from 'typeorm';
import { Logger } from 'ts-log';
import { contextLogger } from '@cardano-sdk/util';
import { v4 } from 'uuid';
import Attorney from 'pg-boss/src/attorney';
import PgBoss, { SendOptions } from 'pg-boss';

export const POOL_DELIST_SCHEDULE = 'pool-delist-schedule';
export const STAKE_POOL_METADATA_QUEUE = 'pool-metadata';
export const STAKE_POOL_METRICS_UPDATE = 'pool-metrics';
export const STAKE_POOL_REWARDS = 'pool-rewards';

export const availableQueues = [
  POOL_DELIST_SCHEDULE,
  STAKE_POOL_METADATA_QUEUE,
  STAKE_POOL_METRICS_UPDATE,
  STAKE_POOL_REWARDS
] as const;

export interface PgBossExtension {
  send: <T extends object>(
    taskName: string,
    data: T,
    options: SendOptions & { slot: Cardano.Slot }
  ) => Promise<string | null>;
}

export interface StakePoolMetricsUpdateJob {
  slot: Cardano.Slot;
  outdatedSlot?: Cardano.Slot;
}

export interface StakePoolMetadataJob {
  /** bigint */
  poolRegistrationId: string;
  poolId: Cardano.PoolId;
  metadataJson: NonNullable<Cardano.StakePool['metadataJson']>;
}

export interface StakePoolRewardsJob {
  epochNo: Cardano.EpochNo;
}

export const defaultJobOptions: SendOptions = {
  retentionDays: 365, // keep the job in a state that can be retried for one year
  retryDelay: 6 * 3600, // 6 hours
  retryLimit: 1_000_000 // retry forever
};

class BossDb {
  constructor(private queryRunner: QueryRunner | null, private logger: Logger, private dataSource?: DataSource) {}

  async executeSql(text: string, values: unknown[]) {
    this.logger.debug(text, values);

    const queryRunner = this.dataSource ? this.dataSource.createQueryRunner() : this.queryRunner;

    if (!queryRunner) throw new Error('Provide a queryRunner or a dataSource');

    const { records, affected } = await queryRunner.query(text, values, true);

    if (this.dataSource) await queryRunner.release();

    return { rowCount: affected || 0, rows: records };
  }
}

/**
 * Creates a new `PgBoss` object, listens to its error handler and sets up logging.
 *
 * The caller has the responsibility to call asynchronous methods `start()` and `stop()`
 * against the returned `PgBoss` instance.
 *
 * Use `queryRunner` when the `PgBoss` instance is required for a one shot operation and needs to use a specific
 * `QueryRunner` (ex. inside a TRANSACTION).
 *
 * Use `dataSource` for long lasting `PgBoss` instances, so they can create new `QueryRunner`s on demand.
 *
 * If `dataSource` is provided, takes precedence on `queryRunner`
 *
 * @param queryRunner the specific `QueryRunner`
 * @param logger the logger instance
 * @param dataSource the `DataSource` used to create new `QueryRunner`s on demand.
 * @returns the newly constructed pg-boss object
 */
export const createPgBoss = (queryRunner: QueryRunner | null, logger: Logger, dataSource?: DataSource) => {
  logger = contextLogger(logger, 'pg-boss');

  const pgBoss = new PgBoss({ db: new BossDb(queryRunner, logger, dataSource) });

  pgBoss.on('error', (error) => logger.error(error));

  return pgBoss;
};

async function createJob(
  this: any,
  name: string,
  data: any,
  options: SendOptions & { expireIn: any; keepUntil: any; slot: Cardano.Slot },
  singletonOffset = 0
) {
  const {
    db: wrapper,
    expireIn,
    priority,
    startAfter,
    keepUntil,
    singletonKey = null,
    singletonSeconds,
    retryBackoff,
    retryLimit,
    retryDelay,
    onComplete,
    // ADDED
    slot
  } = options;

  const id = v4();

  const values = [
    id, // 1
    name, // 2
    priority, // 3
    retryLimit, // 4
    startAfter, // 5
    expireIn, // 6
    data, // 7
    singletonKey, // 8
    singletonSeconds, // 9
    singletonOffset, // 10
    retryDelay, // 11
    retryBackoff, // 12
    keepUntil, // 13
    onComplete, // 14
    // ADDED
    slot // 15
  ];
  const db = wrapper || this.manager.db;
  const result = await db.executeSql(this.insertJobCommand, values);

  if (result && result.rowCount === 1) {
    return result.rows[0].id;
  }

  // eslint-disable-next-line unicorn/consistent-destructuring
  if (!options.singletonNextSlot) {
    return null;
  }

  // delay starting by the offset to honor throttling config
  options.startAfter = this.manager.getDebounceStartAfter(singletonSeconds, this.manager.timekeeper.clockSkew);

  // toggle off next slot config for round 2
  options.singletonNextSlot = false;

  singletonOffset = singletonSeconds!;

  return await this.createJob(name, data, options, singletonOffset);
}

const states = {
  active: 'active',
  cancelled: 'cancelled',
  completed: 'completed',
  created: 'created',
  expired: 'expired',
  failed: 'failed',
  retry: 'retry'
};

// ADDED 'block_slot' column ($15)
const insertJob = (schema: string) => `
    INSERT INTO ${schema}.job (
      id,
      name,
      priority,
      state,
      retryLimit,
      startAfter,
      expireIn,
      data,
      singletonKey,
      singletonOn,
      retryDelay,
      retryBackoff,
      keepUntil,
      on_complete,
      block_slot
    )
    SELECT
      id,
      name,
      priority,
      state,
      retryLimit,
      startAfter,
      expireIn,
      data,
      singletonKey,
      singletonOn,
      retryDelay,
      retryBackoff,
      keepUntil,
      on_complete,
      block_slot
    FROM
    ( SELECT *,
        CASE
          WHEN right(keepUntilValue, 1) = 'Z' THEN CAST(keepUntilValue as timestamp with time zone)
          ELSE startAfter + CAST(COALESCE(keepUntilValue,'0') as interval)
          END as keepUntil
      FROM
      ( SELECT *,
          CASE
            WHEN right(startAfterValue, 1) = 'Z' THEN CAST(startAfterValue as timestamp with time zone)
            ELSE now() + CAST(COALESCE(startAfterValue,'0') as interval)
            END as startAfter
        FROM
        ( SELECT
            $1::uuid as id,
            $2::text as name,
            $3::int as priority,
            '${states.created}'::${schema}.job_state as state,
            $4::int as retryLimit,
            $5::text as startAfterValue,
            CAST($6 as interval) as expireIn,
            $7::jsonb as data,
            $8::text as singletonKey,
            CASE
              WHEN $9::integer IS NOT NULL THEN 'epoch'::timestamp + '1 second'::interval * ($9 * floor((date_part('epoch', now()) + $10) / $9))
              ELSE NULL
              END as singletonOn,
            $11::int as retryDelay,
            $12::bool as retryBackoff,
            $13::text as keepUntilValue,
            $14::boolean as on_complete,
            $15::int as block_slot
        ) j1
      ) j2
    ) j3
    ON CONFLICT DO NOTHING
    RETURNING id
  `;

async function send(this: any, ...args: any[]) {
  const { name, data, options } = Attorney.checkSendArgs(args, this.manager.config);
  return await this.createJob(name, data, options);
}

export const createPgBossExtension = (queryRunner: QueryRunner, logger: Logger): PgBossExtension => {
  const boss = createPgBoss(queryRunner, logger);
  (boss as any).insertJobCommand = insertJob('pgboss');
  (boss as any).send = send;
  (boss as any).createJob = createJob;
  return {
    send(taskName, data, options) {
      return boss.send(taskName, data, options as PgBoss.SendOptions);
    }
  };
};
