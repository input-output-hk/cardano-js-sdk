import { Assets } from '../../types';
import { Cardano, EpochRewards, EraSummary } from '@cardano-sdk/core';
import { ConfirmedTx, TxInFlight } from '../../services';
import { CreatePouchDbStoresDependencies } from './types';
import { EMPTY, combineLatest, map } from 'rxjs';
import { GroupedAddress } from '@cardano-sdk/key-management';
import { PouchDbCollectionStore } from './PouchDbCollectionStore';
import { PouchDbDocumentStore } from './PouchDbDocumentStore';
import { PouchDbKeyValueStore } from './PouchDbKeyValueStore';
import { WalletStores } from '../types';

export class PouchDbTipStore extends PouchDbDocumentStore<Cardano.Tip> {}
export class PouchDbProtocolParametersStore extends PouchDbDocumentStore<Cardano.ProtocolParameters> {}
export class PouchDbGenesisParametersStore extends PouchDbDocumentStore<Cardano.CompactGenesis> {}
export class PouchDbEraSummariesStore extends PouchDbDocumentStore<EraSummary[]> {}

export class PouchDbAssetsStore extends PouchDbDocumentStore<Assets> {}
export class PouchDbAddressesStore extends PouchDbDocumentStore<GroupedAddress[]> {}
export class PouchDbInFlightTransactionsStore extends PouchDbDocumentStore<TxInFlight[]> {}
export class PouchDbVolatileTransactionsStore extends PouchDbDocumentStore<ConfirmedTx[]> {}

export class PouchDbTransactionsStore extends PouchDbCollectionStore<Cardano.HydratedTx> {}
export class PouchDbUtxoStore extends PouchDbCollectionStore<Cardano.Utxo> {}

export class PouchDbRewardsHistoryStore extends PouchDbKeyValueStore<Cardano.RewardAccount, EpochRewards[]> {}
export class PouchDbStakePoolsStore extends PouchDbKeyValueStore<Cardano.PoolId, Cardano.StakePool> {}
export class PouchDbRewardsBalancesStore extends PouchDbKeyValueStore<Cardano.RewardAccount, Cardano.Lovelace> {}

/**
 * @param {string} walletName used to derive underlying db names
 */
export const createPouchDbWalletStores = (
  walletName: string,
  { logger }: CreatePouchDbStoresDependencies
): WalletStores => {
  const baseDbName = walletName.replace(/[^\da-z]/gi, '');
  const docsDbName = `${baseDbName}Docs`;
  return {
    addresses: new PouchDbAddressesStore(docsDbName, 'addresses', logger),
    assets: new PouchDbAssetsStore(docsDbName, 'assets', logger),
    destroy() {
      if (!this.destroyed) {
        // since the database of document stores is shared, destroying any document store destroys all of them
        this.destroyed = true;
        logger.debug('Destroying PouchDb WalletStores...');
        const destroyDocumentsDb = this.tip.destroy();
        return combineLatest([
          destroyDocumentsDb,
          this.transactions.destroy(),
          this.utxo.destroy(),
          this.unspendableUtxo.destroy(),
          this.rewardsHistory.destroy(),
          this.stakePools.destroy(),
          this.rewardsBalances.destroy()
        ]).pipe(map(() => void 0));
      }
      return EMPTY;
    },
    destroyed: false,
    eraSummaries: new PouchDbEraSummariesStore(docsDbName, 'EraSummaries', logger),
    genesisParameters: new PouchDbGenesisParametersStore(docsDbName, 'genesisParameters', logger),
    inFlightTransactions: new PouchDbInFlightTransactionsStore(docsDbName, 'transactionsInFlight', logger),
    protocolParameters: new PouchDbProtocolParametersStore(docsDbName, 'protocolParameters', logger),
    rewardsBalances: new PouchDbRewardsBalancesStore(`${baseDbName}RewardsBalances`, logger),
    rewardsHistory: new PouchDbRewardsHistoryStore(`${baseDbName}RewardsHistory`, logger),
    stakePools: new PouchDbStakePoolsStore(`${baseDbName}StakePools`, logger),
    tip: new PouchDbTipStore(docsDbName, 'tip', logger),
    transactions: new PouchDbTransactionsStore(
      {
        computeDocId: ({ blockHeader: { blockNo }, index }) =>
          /**
           * Multiplied by 100k to distinguish between blockNo=1,index=0 and blockNo=0,index=1
           * Assuming there can never be more >=100k transactions in a block
           */
          (blockNo.valueOf() * 100_000 + index).toString(),
        dbName: `${baseDbName}Transactions`
      },
      logger
    ),
    unspendableUtxo: new PouchDbUtxoStore({ dbName: `${baseDbName}UnspendableUtxo` }, logger),
    utxo: new PouchDbUtxoStore({ dbName: `${baseDbName}Utxo` }, logger),
    volatileTransactions: new PouchDbVolatileTransactionsStore(docsDbName, 'volatileTransactions', logger)
  };
};
