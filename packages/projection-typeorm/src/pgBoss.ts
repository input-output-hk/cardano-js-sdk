/* eslint-disable func-style */
/* eslint-disable jsdoc/require-jsdoc */
/* eslint-disable max-len */
/* eslint-disable no-invalid-this */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano } from '@cardano-sdk/core';
import { QueryRunner } from 'typeorm';
import { v4 } from 'uuid';
import Attorney from 'pg-boss/src/attorney';
import EventEmitter from 'events';
import PgBoss, { SendOptions } from 'pg-boss';

export const STAKE_POOL_METADATA_QUEUE = 'STAKE_POOL_METADATA';

export interface PgBossExtension {
  send: <T extends object>(taskName: string, data: T, options: { slot: Cardano.Slot }) => Promise<string | null>;
}

export interface StakePoolMetadataJob {
  /**
   * bigint
   */
  poolRegistrationId: string;
  poolId: Cardano.PoolId;
  metadataJson: NonNullable<Cardano.StakePool['metadataJson']>;
}

export class BossDb extends EventEmitter {
  opened = true;
  #queryRunner: QueryRunner;

  constructor(queryRunner: QueryRunner) {
    super();
    this.#queryRunner = queryRunner;
  }

  async executeSql(text: string, values: unknown[]) {
    return this.#queryRunner
      .query(text, values, true)
      .then(({ records, affected }) => ({ rowCount: affected || 0, rows: records }));
  }
}

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

export const createPgBossExtension = (queryRunner: QueryRunner): PgBossExtension => {
  const boss = new PgBoss({ db: new BossDb(queryRunner) });
  (boss as any).insertJobCommand = insertJob('pgboss');
  (boss as any).send = send;
  (boss as any).createJob = createJob;
  return {
    send(taskName, data, options) {
      return boss.send(taskName, data, options as PgBoss.SendOptions);
    }
  };
};
