/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Queries from './queries';
import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Pool, QueryResult } from 'pg';

export type PoolStatus = 'active' | 'activating' | 'retired' | 'retiring';

export type PoolInfo = {
  status: string;
  id: Cardano.PoolId;
  name: string;
  ticker: string;
  metadataUrl: string;
  cost: string;
  saturation: number;
  apy?: number;
};

export type PoolFixtureModel = {
  id: string;
  status: string;
  name: string;
  ticker: string;
  metadata_url: string;
  cost: string;
  live_saturation: string;
  apy?: string;
};

export class TypeormStakePoolFixtureBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }

  // eslint-disable-next-line complexity,sonarjs/cognitive-complexity
  public async getPools(desiredQty: number, statuses: PoolStatus[], withMetadata?: boolean): Promise<PoolInfo[]> {
    this.#logger.debug(`About to fetch ${desiredQty} pools`);
    const result: QueryResult<PoolFixtureModel> = await this.#db.query(Queries.findStakePools(withMetadata), [
      desiredQty,
      statuses
    ]);
    const resultsQty = result.rows.length;
    if (result.rows.length === 0) {
      this.#logger.fatal({ desiredQty, statuses, withMetadata });
      this.#logger.fatal('stake_pool dump');
      this.#logger.fatal((await this.#db.query('SELECT * FROM stake_pool')).rows);
      this.#logger.fatal('pool_registration dump');
      this.#logger.fatal((await this.#db.query('SELECT * FROM pool_registration')).rows);
      this.#logger.fatal('pool_metadata dump');
      this.#logger.fatal((await this.#db.query('SELECT * FROM pool_metadata')).rows);
      this.#logger.fatal('current_pool_metrics dump');
      this.#logger.fatal((await this.#db.query('SELECT * FROM current_pool_metrics')).rows);
      throw new Error('No pools found');
    } else if (resultsQty < desiredQty) {
      this.#logger.warn(`${desiredQty} pools desired, only ${resultsQty} results found`);
    }

    return result.rows.map(({ id, status, name, ticker, cost, apy, live_saturation, metadata_url }) => ({
      apy: typeof apy === 'string' ? Number.parseFloat(apy) : undefined,
      cost,
      id: id as unknown as Cardano.PoolId,
      metadataUrl: metadata_url,
      name,
      saturation: Number.parseFloat(live_saturation),
      status,
      ticker
    }));
  }
}
