import * as Queries from './queries.js';
import { bufferToHexString } from '@cardano-sdk/util';
import type { Cardano } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';
import type { Pool, QueryResult } from 'pg';

export class MetadataFixtureBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }

  public async getTxIds(desiredQty: number) {
    this.#logger.debug('About to query tx with metadata');
    const result: QueryResult<{ tx_id: Buffer }> = await this.#db.query(Queries.findTxWithMetadata, [desiredQty]);

    const resultsQty = result.rows.length;
    if (result.rows.length === 0) {
      throw new Error('No transactions found');
    } else if (resultsQty < desiredQty) {
      this.#logger.warn(`${desiredQty} transactions desired, only ${resultsQty} results found`);
    }

    return result.rows.map(({ tx_id }) => bufferToHexString(tx_id) as unknown as Cardano.TransactionId);
  }
}
