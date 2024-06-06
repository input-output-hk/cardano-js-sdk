/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Queries from './queries.js';
import type { Cardano } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';
import type { Pool, QueryResult } from 'pg';

export enum PoolWith {
  Metadata = 'Metadata',
  NoMetadata = 'NoMetadata',
  RetiredState = 'RetiredState',
  RetiringState = 'RetiringState',
  ActiveState = 'ActiveState',
  ActivatingState = 'ActivatingState',
  PledgeMet = 'PledgeMet',
  PledgeNotMet = 'PledgeNotMet'
}

export class PoolInfo {
  name: string;
  ticker: string;
  id: Cardano.PoolId;
  hashId: number;
  updateId: number;
}

export class DbSyncStakePoolFixtureBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }

  // eslint-disable-next-line complexity,sonarjs/cognitive-complexity
  public async getPools(desiredQty: number, options?: { with?: PoolWith[] }): Promise<PoolInfo[]> {
    this.#logger.debug(`About to fetch ${desiredQty} pools`);

    let query = Queries.subQueries;

    query += options?.with?.includes(PoolWith.Metadata)
      ? Queries.beginFindPoolsWithMetadata
      : Queries.beginFindPoolsWithoutMetadata;

    if (options?.with?.includes(PoolWith.PledgeMet) || options?.with?.includes(PoolWith.PledgeNotMet)) {
      query += options?.with?.includes(PoolWith.PledgeMet) ? Queries.withPledgeMet : Queries.withPledgeNotMet;
    } else {
      query += Queries.withNoPledgeFilter;
    }

    if (options?.with?.includes(PoolWith.ActiveState)) {
      query += Queries.withPoolActive;
    } else if (options?.with?.includes(PoolWith.ActivatingState)) {
      query += Queries.withPoolActivating;
    } else if (options?.with?.includes(PoolWith.RetiredState)) {
      query += Queries.withPoolRetired;
    } else if (options?.with?.includes(PoolWith.RetiringState)) {
      query += Queries.withPoolRetiring;
    } else {
      query += Queries.withNoStateFilter;
    }

    query += Queries.endFindPools;

    const result: QueryResult<{
      pool_id: string;
      metadata: any;
      hash_id: bigint;
      update_id: bigint;
    }> = await this.#db.query(query, [desiredQty]);

    const resultsQty = result.rows.length;
    if (result.rows.length === 0) {
      throw new Error('No pools found');
    } else if (resultsQty < desiredQty) {
      this.#logger.warn(`${desiredQty} pools desired, only ${resultsQty} results found`);
    }

    return result.rows.map(({ pool_id, metadata, hash_id, update_id }) => ({
      hashId: Number(hash_id.toString()),
      id: pool_id as unknown as Cardano.PoolId,
      name: metadata?.name,
      ticker: metadata?.ticker,
      updateId: Number(update_id.toString())
    }));
  }

  public async getLasKnownEpoch(): Promise<number> {
    this.#logger.debug('About to fetch las known epoch');

    const result: QueryResult<{
      no: number;
    }> = await this.#db.query(Queries.lastKnownEpoch);

    return result.rows.map(({ no }) => no)[0];
  }

  public async getDistinctPoolIds(desiredQty: number, withMetadata: boolean): Promise<Cardano.PoolId[]> {
    this.#logger.debug('About to fetch las known epoch');

    let query = Queries.beginPoolIds;
    query += withMetadata ? Queries.withMetadata : Queries.withoutMetadata;

    const result: QueryResult<{
      pool_id: string;
    }> = await this.#db.query(query);

    const resultsQty = result.rows.length;
    if (result.rows.length === 0) {
      throw new Error('No pool ids found');
    } else if (resultsQty < desiredQty) {
      this.#logger.warn(`${desiredQty} pools desired, only ${resultsQty} results found`);
    }

    return result.rows.map(({ pool_id }) => pool_id as unknown as Cardano.PoolId);
  }
}
