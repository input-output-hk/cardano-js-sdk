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
import { InMemoryCollectionStore } from './InMemoryCollectionStore';
import { InMemoryDocumentStore } from './InMemoryDocumentStore';
import { InMemoryKeyValueStore } from './InMemoryKeyValueStore';
import { NewTxAlonzoWithSlot } from '../../services';
import { WalletStores } from '../types';

export class InMemoryTipStore extends InMemoryDocumentStore<Cardano.Tip> {}
export class InMemoryProtocolParametersStore extends InMemoryDocumentStore<ProtocolParametersRequiredByWallet> {}
export class InMemoryGenesisParametersStore extends InMemoryDocumentStore<Cardano.CompactGenesis> {}
export class InMemoryStakeSummaryStore extends InMemoryDocumentStore<StakeSummary> {}
export class InMemorySupplySummaryStore extends InMemoryDocumentStore<SupplySummary> {}
export class InMemoryTimeSettingsStore extends InMemoryDocumentStore<TimeSettings[]> {}

export class InMemoryAssetsStore extends InMemoryDocumentStore<Assets> {}
export class InMemoryAddressesStore extends InMemoryDocumentStore<GroupedAddress[]> {}
export class InMemoryInFlightTransactionsStore extends InMemoryDocumentStore<Cardano.NewTxAlonzo[]> {}
export class InMemoryVolatileTransactionsStore extends InMemoryDocumentStore<NewTxAlonzoWithSlot[]> {}

export class InMemoryTransactionsStore extends InMemoryCollectionStore<Cardano.TxAlonzo> {}
export class InMemoryUtxoStore extends InMemoryCollectionStore<Cardano.Utxo> {}
export class InMemoryUnspendableUtxoStore extends InMemoryCollectionStore<Cardano.Utxo> {}

export class InMemoryRewardsHistoryStore extends InMemoryKeyValueStore<Cardano.RewardAccount, EpochRewards[]> {}
export class InMemoryStakePoolsStore extends InMemoryKeyValueStore<Cardano.PoolId, Cardano.StakePool> {}
export class InMemoryRewardsBalancesStore extends InMemoryKeyValueStore<Cardano.RewardAccount, Cardano.Lovelace> {}

export const createInMemoryWalletStores = (): WalletStores => ({
  addresses: new InMemoryAddressesStore(),
  assets: new InMemoryAssetsStore(),
  destroy() {
    if (!this.destroyed) {
      this.destroyed = true;
      return combineLatest([
        this.addresses.destroy(),
        this.assets.destroy(),
        this.genesisParameters.destroy(),
        this.protocolParameters.destroy(),
        this.stake.destroy(),
        this.lovelaceSupply.destroy(),
        this.timeSettings.destroy(),
        this.unspendableUtxo.destroy(),
        this.rewardsBalances.destroy(),
        this.rewardsHistory.destroy(),
        this.stakePools.destroy(),
        this.tip.destroy(),
        this.transactions.destroy(),
        this.inFlightTransactions.destroy(),
        this.volatileTransactions.destroy(),
        this.utxo.destroy()
      ]).pipe(map(() => void 0));
    }
    return EMPTY;
  },
  destroyed: false,
  genesisParameters: new InMemoryGenesisParametersStore(),
  inFlightTransactions: new InMemoryInFlightTransactionsStore(),
  lovelaceSupply: new InMemorySupplySummaryStore(),
  protocolParameters: new InMemoryProtocolParametersStore(),
  rewardsBalances: new InMemoryRewardsBalancesStore(),
  rewardsHistory: new InMemoryRewardsHistoryStore(),
  stake: new InMemoryStakeSummaryStore(),
  stakePools: new InMemoryStakePoolsStore(),
  timeSettings: new InMemoryTimeSettingsStore(),
  tip: new InMemoryTipStore(),
  transactions: new InMemoryTransactionsStore(),
  unspendableUtxo: new InMemoryUnspendableUtxoStore(),
  utxo: new InMemoryUtxoStore(),
  volatileTransactions: new InMemoryVolatileTransactionsStore()
});
