import { Assets } from '../../types';
import {
  Cardano,
  EpochRewards,
  NetworkInfo,
  ProtocolParametersRequiredByWallet,
  TimeSettings
} from '@cardano-sdk/core';
import { InMemoryCollectionStore } from './InMemoryCollectionStore';
import { InMemoryDocumentStore } from './InMemoryDocumentStore';
import { InMemoryKeyValueStore } from './InMemoryKeyValueStore';
import { WalletStores } from '../types';

export class InMemoryTipStore extends InMemoryDocumentStore<Cardano.Tip> {}
export class InMemoryProtocolParametersStore extends InMemoryDocumentStore<ProtocolParametersRequiredByWallet> {}
export class InMemoryGenesisParametersStore extends InMemoryDocumentStore<Cardano.CompactGenesis> {}
export class InMemoryTimeSettingsStore extends InMemoryDocumentStore<TimeSettings[]> {}
export class InMemoryNetworkInfoStore extends InMemoryDocumentStore<NetworkInfo> {}
export class InMemoryAssetsStore extends InMemoryDocumentStore<Assets> {}

export class InMemoryTransactionsStore extends InMemoryCollectionStore<Cardano.TxAlonzo> {}
export class InMemoryUtxoStore extends InMemoryCollectionStore<Cardano.Utxo> {}

export class InMemoryRewardsHistoryStore extends InMemoryKeyValueStore<Cardano.RewardAccount, EpochRewards[]> {}
export class InMemoryStakePoolsStore extends InMemoryKeyValueStore<Cardano.PoolId, Cardano.StakePool> {}
export class InMemoryRewardsBalancesStore extends InMemoryKeyValueStore<Cardano.RewardAccount, Cardano.Lovelace> {}

export const createInMemoryWalletStores = (): WalletStores => ({
  assets: new InMemoryAssetsStore(),
  genesisParameters: new InMemoryGenesisParametersStore(),
  networkInfo: new InMemoryNetworkInfoStore(),
  protocolParameters: new InMemoryProtocolParametersStore(),
  rewardsBalances: new InMemoryRewardsBalancesStore(),
  rewardsHistory: new InMemoryRewardsHistoryStore(),
  stakePools: new InMemoryStakePoolsStore(),
  timeSettings: new InMemoryTimeSettingsStore(),
  tip: new InMemoryTipStore(),
  transactions: new InMemoryTransactionsStore(),
  utxo: new InMemoryUtxoStore()
});
