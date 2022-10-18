import { Cardano, CardanoNode, UtxoByAddressesArgs, UtxoProvider } from '@cardano-sdk/core';
import { DbSyncProvider } from '../../util/DbSyncProvider';
import { Logger } from 'ts-log';
import { Pool } from 'pg';
import { UtxoBuilder } from './UtxoBuilder';

export interface UtxoProviderDependencies {
  db: Pool;
  logger: Logger;
  cardanoNode: CardanoNode;
}

export class DbSyncUtxoProvider extends DbSyncProvider() implements UtxoProvider {
  #logger: Logger;
  #builder: UtxoBuilder;
  constructor({ db, cardanoNode, logger }: UtxoProviderDependencies) {
    super(db, cardanoNode);
    this.#logger = logger;
    this.#builder = new UtxoBuilder(db, logger);
  }
  public async utxoByAddresses({ addresses }: UtxoByAddressesArgs): Promise<Cardano.Utxo[]> {
    this.#logger.debug('About to call utxoByAddress of Utxo Query Builder');
    return this.#builder.utxoByAddresses(addresses);
  }
}
