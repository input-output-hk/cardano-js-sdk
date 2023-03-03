import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Pool, QueryResult } from 'pg';
import { UtxoModel } from './types';
import { findUtxosByAddresses } from './queries';
import { utxosToCore } from './mappers';

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
