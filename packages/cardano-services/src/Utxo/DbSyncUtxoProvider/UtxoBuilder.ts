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
  public async utxoByAddresses(addresses: Cardano.Address[]): Promise<Cardano.Utxo[]> {
    const mappedAddresses = addresses.map((a) => a.toString());
    this.#logger.debug('About to find utxos of addresses ', mappedAddresses);
    const result: QueryResult<UtxoModel> = await this.#db.query(findUtxosByAddresses, [mappedAddresses]);
    return result.rows.length > 0 ? utxosToCore(result.rows) : [];
  }
}
