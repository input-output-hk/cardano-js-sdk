import { Assets } from '../../types';
import { Cardano, EpochRewards, NetworkInfo, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { EMPTY, combineLatest, map } from 'rxjs';
import { InMemoryCollectionStore } from './InMemoryCollectionStore';
import { InMemoryDocumentStore } from './InMemoryDocumentStore';
import { InMemoryKeyValueStore } from './InMemoryKeyValueStore';
import { WalletStores } from '../types';

export class InMemoryTipStore extends InMemoryDocumentStore<Cardano.Tip> {}
export class InMemoryProtocolParametersStore extends InMemoryDocumentStore<ProtocolParametersRequiredByWallet> {}
export class InMemoryGenesisParametersStore extends InMemoryDocumentStore<Cardano.CompactGenesis> {}
export class InMemoryNetworkInfoStore extends InMemoryDocumentStore<NetworkInfo> {}
export class InMemoryAssetsStore extends InMemoryDocumentStore<Assets> {}

export class InMemoryTransactionsStore extends InMemoryCollectionStore<Cardano.TxAlonzo> {}
export class InMemoryUtxoStore extends InMemoryCollectionStore<Cardano.Utxo> {}

export class InMemoryRewardsHistoryStore extends InMemoryKeyValueStore<Cardano.RewardAccount, EpochRewards[]> {}
export class InMemoryStakePoolsStore extends InMemoryKeyValueStore<Cardano.PoolId, Cardano.StakePool> {}
export class InMemoryRewardsBalancesStore extends InMemoryKeyValueStore<Cardano.RewardAccount, Cardano.Lovelace> {}

export const createInMemoryWalletStores = (): WalletStores => ({
  assets: new InMemoryAssetsStore(),
  destroy() {
    if (!this.destroyed) {
      this.destroyed = true;
      return combineLatest([
        this.assets.destroy(),
        this.genesisParameters.destroy(),
        this.networkInfo.destroy(),
        this.protocolParameters.destroy(),
        this.rewardsBalances.destroy(),
        this.rewardsHistory.destroy(),
        this.stakePools.destroy(),
        this.tip.destroy(),
        this.transactions.destroy(),
        this.utxo.destroy()
      ]).pipe(map(() => void 0));
    }
    return EMPTY;
  },
  destroyed: false,
  genesisParameters: new InMemoryGenesisParametersStore(),
  networkInfo: new InMemoryNetworkInfoStore(),
  protocolParameters: new InMemoryProtocolParametersStore(),
  rewardsBalances: new InMemoryRewardsBalancesStore(),
  rewardsHistory: new InMemoryRewardsHistoryStore(),
  stakePools: new InMemoryStakePoolsStore(),
  tip: new InMemoryTipStore(),
  transactions: new InMemoryTransactionsStore(),
  utxo: new InMemoryUtxoStore()
});
