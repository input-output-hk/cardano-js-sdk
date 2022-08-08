import { Cardano, UtxoProvider } from '@cardano-sdk/core';
import { DbSyncProvider } from '../../DbSyncProvider';
import { Logger } from 'ts-log';
import { Pool } from 'pg';
import { UtxoBuilder } from './UtxoBuilder';

export class DbSyncUtxoProvider extends DbSyncProvider implements UtxoProvider {
  #logger: Logger;
  #builder: UtxoBuilder;
  constructor(db: Pool, logger: Logger) {
    super(db);
    this.#logger = logger;
    this.#builder = new UtxoBuilder(db, logger);
  }

  public async utxoByAddresses(addresses: Cardano.Address[]): Promise<Cardano.Utxo[]> {
    this.#logger.debug('About to call utxoByAddress of Utxo Query Builder');
    return this.#builder.utxoByAddresses(addresses);
  }
}
