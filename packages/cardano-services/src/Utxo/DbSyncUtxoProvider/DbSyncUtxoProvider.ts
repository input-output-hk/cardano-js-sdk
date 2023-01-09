import { Cardano, UtxoByAddressesArgs, UtxoProvider } from '@cardano-sdk/core';
import { DbSyncProvider, DbSyncProviderDependencies } from '../../util/DbSyncProvider';
import { UtxoBuilder } from './UtxoBuilder';

export class DbSyncUtxoProvider extends DbSyncProvider() implements UtxoProvider {
  #builder: UtxoBuilder;
  constructor({ db, cardanoNode, logger }: DbSyncProviderDependencies) {
    super({ cardanoNode, db, logger });

    this.#builder = new UtxoBuilder(db, logger);
  }
  public async utxoByAddresses({ addresses }: UtxoByAddressesArgs): Promise<Cardano.Utxo[]> {
    this.logger.debug('About to call utxoByAddress of Utxo Query Builder');
    return this.#builder.utxoByAddresses(addresses);
  }
}
