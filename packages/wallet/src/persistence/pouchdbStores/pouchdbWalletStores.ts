import { Assets } from '../../types';
import {
  Cardano,
  EpochRewards,
  ProtocolParametersRequiredByWallet,
  StakeSummary,
  SupplySummary,
  TimeSettings
} from '@cardano-sdk/core';
import { EMPTY, combineLatest, map } from 'rxjs';
import { GroupedAddress } from '../../KeyManagement';
import { Logger } from 'ts-log';
import { PouchdbCollectionStore } from './PouchdbCollectionStore';
import { PouchdbDocumentStore } from './PouchdbDocumentStore';
import { PouchdbKeyValueStore } from './PouchdbKeyValueStore';
import { WalletStores } from '../types';

export class PouchdbTipStore extends PouchdbDocumentStore<Cardano.Tip> {}
export class PouchdbProtocolParametersStore extends PouchdbDocumentStore<ProtocolParametersRequiredByWallet> {}
export class PouchdbGenesisParametersStore extends PouchdbDocumentStore<Cardano.CompactGenesis> {}
export class PouchdbStakeSummaryStore extends PouchdbDocumentStore<StakeSummary> {}
export class PouchdbSupplySummaryStore extends PouchdbDocumentStore<SupplySummary> {}
export class PouchdbTimeSettingsStore extends PouchdbDocumentStore<TimeSettings[]> {}

export class PouchdbAssetsStore extends PouchdbDocumentStore<Assets> {}
export class PouchdbAddressesStore extends PouchdbDocumentStore<GroupedAddress[]> {}
export class PouchdbInFlightTransactionsStore extends PouchdbDocumentStore<Cardano.NewTxAlonzo[]> {}

export class PouchdbTransactionsStore extends PouchdbCollectionStore<Cardano.TxAlonzo> {}
export class PouchdbUtxoStore extends PouchdbCollectionStore<Cardano.Utxo> {}

export class PouchdbRewardsHistoryStore extends PouchdbKeyValueStore<Cardano.RewardAccount, EpochRewards[]> {}
export class PouchdbStakePoolsStore extends PouchdbKeyValueStore<Cardano.PoolId, Cardano.StakePool> {}
export class PouchdbRewardsBalancesStore extends PouchdbKeyValueStore<Cardano.RewardAccount, Cardano.Lovelace> {}

export interface CreatePouchdbWalletStoresDependencies {
  logger?: Logger;
}

/**
 * @param {string} walletName used to derive underlying db names
 */
export const createPouchdbWalletStores = (
  walletName: string,
  { logger }: CreatePouchdbWalletStoresDependencies = {}
): WalletStores => {
  const baseDbName = walletName.replace(/[^\da-z]/gi, '');
  const docsDbName = `${baseDbName}Docs`;
  return {
    addresses: new PouchdbAddressesStore(docsDbName, 'addresses', logger),
    assets: new PouchdbAssetsStore(docsDbName, 'assets', logger),
    destroy() {
      if (!this.destroyed) {
        // since the database of document stores is shared, destroying any document store destroys all of them
        const destroyDocumentsDb = this.tip.destroy();
        return combineLatest([
          destroyDocumentsDb,
          this.transactions.destroy(),
          this.inFlightTransactions.destroy(),
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
    genesisParameters: new PouchdbGenesisParametersStore(docsDbName, 'genesisParameters', logger),
    inFlightTransactions: new PouchdbInFlightTransactionsStore(docsDbName, 'newTransactions', logger),
    lovelaceSupply: new PouchdbSupplySummaryStore(docsDbName, 'lovelaceSupply', logger),
    protocolParameters: new PouchdbProtocolParametersStore(docsDbName, 'protocolParameters', logger),
    rewardsBalances: new PouchdbRewardsBalancesStore(`${baseDbName}RewardsBalances`, logger),
    rewardsHistory: new PouchdbRewardsHistoryStore(`${baseDbName}RewardsHistory`, logger),
    stake: new PouchdbStakeSummaryStore(docsDbName, 'stake', logger),
    stakePools: new PouchdbStakePoolsStore(`${baseDbName}StakePools`, logger),
    timeSettings: new PouchdbTimeSettingsStore(docsDbName, 'timeSettings', logger),
    tip: new PouchdbTipStore(docsDbName, 'tip', logger),
    transactions: new PouchdbTransactionsStore(
      {
        computeDocId: ({ blockHeader: { blockNo }, index }) =>
          /**
           * Multiplied by 100k to distinguish between blockNo=1,index=0 and blockNo=0,index=1
           * Assuming there can never be more >=100k transactions in a block
           */
          (blockNo * 100_000 + index).toString(),
        dbName: `${baseDbName}Transactions`
      },
      logger
    ),
    unspendableUtxo: new PouchdbUtxoStore({ dbName: `${baseDbName}UnspendableUtxo` }, logger),
    utxo: new PouchdbUtxoStore({ dbName: `${baseDbName}Utxo` }, logger)
  };
};
