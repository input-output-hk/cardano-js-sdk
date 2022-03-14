import { Assets } from '../../types';
import {
  Cardano,
  EpochRewards,
  NetworkInfo,
  ProtocolParametersRequiredByWallet,
  TimeSettings
} from '@cardano-sdk/core';
import { PouchdbCollectionStore } from './PouchdbCollectionStore';
import { PouchdbDocumentStore } from './PouchdbDocumentStore';
import { PouchdbKeyValueStore } from './PouchdbKeyValueStore';
import { WalletStores } from '../types';

export class PouchdbTipStore extends PouchdbDocumentStore<Cardano.Tip> {}
export class PouchdbProtocolParametersStore extends PouchdbDocumentStore<ProtocolParametersRequiredByWallet> {}
export class PouchdbGenesisParametersStore extends PouchdbDocumentStore<Cardano.CompactGenesis> {}
export class PouchdbTimeSettingsStore extends PouchdbDocumentStore<TimeSettings[]> {}
export class PouchdbNetworkInfoStore extends PouchdbDocumentStore<NetworkInfo> {}
export class PouchdbAssetsStore extends PouchdbDocumentStore<Assets> {}

export class PouchdbTransactionsStore extends PouchdbCollectionStore<Cardano.TxAlonzo> {}
export class PouchdbUtxoStore extends PouchdbCollectionStore<Cardano.Utxo> {}

export class PouchdbRewardsHistoryStore extends PouchdbKeyValueStore<Cardano.RewardAccount, EpochRewards[]> {}
export class PouchdbStakePoolsStore extends PouchdbKeyValueStore<Cardano.PoolId, Cardano.StakePool> {}
export class PouchdbRewardsBalancesStore extends PouchdbKeyValueStore<Cardano.RewardAccount, Cardano.Lovelace> {}

/**
 * @param {string} walletName used to derive underlying db names
 */
export const createPouchdbWalletStores = (walletName: string): WalletStores => {
  const baseDbName = walletName.replace(/[^\da-z]/gi, '');
  const docsDbName = `${baseDbName}Docs`;
  return {
    assets: new PouchdbAssetsStore(docsDbName, 'assets'),
    genesisParameters: new PouchdbGenesisParametersStore(docsDbName, 'genesisParameters'),
    networkInfo: new PouchdbNetworkInfoStore(docsDbName, 'networkInfo'),
    protocolParameters: new PouchdbProtocolParametersStore(docsDbName, 'protocolParameters'),
    rewardsBalances: new PouchdbRewardsBalancesStore(`${baseDbName}RewardsBalances`),
    rewardsHistory: new PouchdbRewardsHistoryStore(`${baseDbName}RewardsHistory`),
    stakePools: new PouchdbStakePoolsStore(`${baseDbName}StakePools`),
    timeSettings: new PouchdbTimeSettingsStore(docsDbName, 'timeSettings'),
    tip: new PouchdbTipStore(baseDbName, 'tip'),
    transactions: new PouchdbTransactionsStore(`${baseDbName}Transactions`, ({ blockHeader: { blockNo }, index }) =>
      /**
       * Multiplied by 100k to distinguish between blockNo=1,index=0 and blockNo=0,index=1
       * Assuming there can never be more >=100k transactions in a block
       */
      (blockNo * 100_000 + index).toString()
    ),
    utxo: new PouchdbUtxoStore(`${baseDbName}Utxo`)
  };
};
