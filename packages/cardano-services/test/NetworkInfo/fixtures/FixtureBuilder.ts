import * as Queries from './queries.js';
import type { Logger } from 'ts-log';
import type { Pool, QueryResult } from 'pg';

export class NetworkInfoFixtureBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }

  public async getMaxSupply() {
    this.#logger.debug('About to query max supply');
    const result: QueryResult<{ max_supply: number }> = await this.#db.query(Queries.getMaxSupply);

    if (result.rows.length === 0) throw new Error('Unexpected error querying max supply');

    return result.rows.map(({ max_supply }) => BigInt(max_supply))[0];
  }

  public async getLasKnownEpoch(): Promise<number> {
    this.#logger.debug('About to fetch last known epoch');

    const result: QueryResult<{
      no: number;
    }> = await this.#db.query(Queries.lastKnownEpoch);

    return result.rows.map(({ no }) => no)[0];
  }
}
