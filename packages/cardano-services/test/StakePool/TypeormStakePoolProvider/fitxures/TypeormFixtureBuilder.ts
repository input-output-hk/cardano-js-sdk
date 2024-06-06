/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Queries from './queries.js';
import type { Cardano } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';
import type { Pool, QueryResult } from 'pg';

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
  lastRos?: number;
  ros?: number;
  pledge: string;
  blocks: number;
  stake: string;
  margin: Cardano.Fraction;
};

export type PoolFixtureModel = {
  id: string;
  status: string;
  name: string;
  ticker: string;
  metadata_url: string;
  cost: string;
  live_saturation: string;
  ros?: string;
  last_ros?: string;
  pledge: string;
  blocks: number;
  stake: string;
  margin: Cardano.Fraction;
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
      throw new Error('No pools found');
    } else if (resultsQty < desiredQty) {
      this.#logger.warn(`${desiredQty} pools desired, only ${resultsQty} results found`);
    }

    return result.rows.map(
      ({
        id,
        status,
        name,
        ticker,
        cost,
        ros,
        last_ros,
        live_saturation,
        metadata_url,
        pledge,
        blocks,
        stake,
        margin
      }) => ({
        blocks,
        cost,
        id: id as unknown as Cardano.PoolId,
        lastRos: typeof last_ros === 'string' ? Number.parseFloat(last_ros) : undefined,
        margin,
        metadataUrl: metadata_url,
        name,
        pledge,
        ros: typeof ros === 'string' ? Number.parseFloat(ros) : undefined,
        saturation: Number.parseFloat(live_saturation),
        stake,
        status,
        ticker
      })
    );
  }
}
