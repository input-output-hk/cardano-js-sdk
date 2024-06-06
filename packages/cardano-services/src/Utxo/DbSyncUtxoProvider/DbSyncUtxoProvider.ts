import { DbSyncProvider } from '../../util/DbSyncProvider/index.js';
import { UtxoBuilder } from './UtxoBuilder.js';
import type { Cardano, UtxoByAddressesArgs, UtxoProvider } from '@cardano-sdk/core';
import type { DbSyncProviderDependencies } from '../../util/DbSyncProvider/index.js';

export class DbSyncUtxoProvider extends DbSyncProvider() implements UtxoProvider {
  #builder: UtxoBuilder;
  constructor({ cache, dbPools, cardanoNode, logger }: DbSyncProviderDependencies) {
    super({ cache, cardanoNode, dbPools, logger });

    this.#builder = new UtxoBuilder(dbPools.main, logger);
  }
  public async utxoByAddresses({ addresses }: UtxoByAddressesArgs): Promise<Cardano.Utxo[]> {
    this.logger.debug('About to call utxoByAddress of Utxo Query Builder');
    return this.#builder.utxoByAddresses(addresses);
  }
}
