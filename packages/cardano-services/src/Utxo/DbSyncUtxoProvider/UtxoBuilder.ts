import { findUtxosByAddresses } from './queries.js';
import { utxosToCore } from './mappers.js';
import type { Cardano } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';
import type { Pool, QueryResult } from 'pg';
import type { UtxoModel } from './types.js';

export class UtxoBuilder {
  #db: Pool;
  #logger: Logger;
  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }
  public async utxoByAddresses(addresses: Cardano.PaymentAddress[]): Promise<Cardano.Utxo[]> {
    this.#logger.debug('About to find utxos of addresses ', addresses);
    const result: QueryResult<UtxoModel> = await this.#db.query(findUtxosByAddresses, [addresses]);
    return result.rows.length > 0 ? utxosToCore(result.rows) : [];
  }
}
