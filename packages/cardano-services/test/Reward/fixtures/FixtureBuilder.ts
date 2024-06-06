import * as Queries from './queries.js';
import type { Cardano } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';
import type { Pool, QueryResult } from 'pg';

export class RewardsFixtureBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }

  public async getRewardAccounts(desiredQty: number): Promise<Cardano.RewardAccount[]> {
    this.#logger.debug(`About to fetch up to the last ${desiredQty} reward accounts`);
    const result: QueryResult<{ address: string }> = await this.#db.query(Queries.stakeAddress, [desiredQty]);
    const resultsQty = result.rows.length;
    if (result.rows.length === 0) {
      throw new Error('No accounts found');
    } else if (resultsQty < desiredQty) {
      this.#logger.warn(`${desiredQty} reward accounts desired, only ${resultsQty} results found`);
    }
    return result.rows.map(({ address }) => address as unknown as Cardano.RewardAccount);
  }
}
