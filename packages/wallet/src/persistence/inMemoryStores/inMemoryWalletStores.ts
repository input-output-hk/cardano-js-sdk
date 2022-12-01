import { Assets } from '../../types';
import { Cardano, EpochRewards, EraSummary } from '@cardano-sdk/core';
import { ConfirmedTx, TxInFlight } from '../../services';
import { EMPTY, combineLatest, map } from 'rxjs';
import { GroupedAddress } from '@cardano-sdk/key-management';
import { InMemoryCollectionStore } from './InMemoryCollectionStore';
import { InMemoryDocumentStore } from './InMemoryDocumentStore';
import { InMemoryKeyValueStore } from './InMemoryKeyValueStore';
import { WalletStores } from '../types';

export class InMemoryTipStore extends InMemoryDocumentStore<Cardano.Tip> {}
export class InMemoryProtocolParametersStore extends InMemoryDocumentStore<Cardano.ProtocolParameters> {}
export class InMemoryGenesisParametersStore extends InMemoryDocumentStore<Cardano.CompactGenesis> {}
export class InMemoryEraSummariesStore extends InMemoryDocumentStore<EraSummary[]> {}

export class InMemoryAssetsStore extends InMemoryDocumentStore<Assets> {}
export class InMemoryAddressesStore extends InMemoryDocumentStore<GroupedAddress[]> {}
export class InMemoryInFlightTransactionsStore extends InMemoryDocumentStore<TxInFlight[]> {}
export class InMemoryVolatileTransactionsStore extends InMemoryDocumentStore<ConfirmedTx[]> {}

export class InMemoryTransactionsStore extends InMemoryCollectionStore<Cardano.HydratedTx> {}
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
        this.eraSummaries.destroy(),
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
  eraSummaries: new InMemoryEraSummariesStore(),
  genesisParameters: new InMemoryGenesisParametersStore(),
  inFlightTransactions: new InMemoryInFlightTransactionsStore(),
  protocolParameters: new InMemoryProtocolParametersStore(),
  rewardsBalances: new InMemoryRewardsBalancesStore(),
  rewardsHistory: new InMemoryRewardsHistoryStore(),
  stakePools: new InMemoryStakePoolsStore(),
  tip: new InMemoryTipStore(),
  transactions: new InMemoryTransactionsStore(),
  unspendableUtxo: new InMemoryUnspendableUtxoStore(),
  utxo: new InMemoryUtxoStore(),
  volatileTransactions: new InMemoryVolatileTransactionsStore()
});
