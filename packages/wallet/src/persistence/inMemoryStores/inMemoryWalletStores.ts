import { Assets } from '../../types';
import { Cardano, EraSummary, Reward } from '@cardano-sdk/core';
import { EMPTY, combineLatest, map } from 'rxjs';
import { GroupedAddress, WitnessedTx } from '@cardano-sdk/key-management';
import { InMemoryCollectionStore } from './InMemoryCollectionStore';
import { InMemoryDocumentStore } from './InMemoryDocumentStore';
import { InMemoryKeyValueStore } from './InMemoryKeyValueStore';
import { OutgoingOnChainTx, TxInFlight } from '../../services';
import { WalletStores } from '../types';

export class InMemoryTipStore extends InMemoryDocumentStore<Cardano.Tip> {}
export class InMemoryPolicyIdsStore extends InMemoryDocumentStore<Cardano.PolicyId[]> {}
export class InMemoryProtocolParametersStore extends InMemoryDocumentStore<Cardano.ProtocolParameters> {}
export class InMemoryGenesisParametersStore extends InMemoryDocumentStore<Cardano.CompactGenesis> {}
export class InMemoryEraSummariesStore extends InMemoryDocumentStore<EraSummary[]> {}
export class InMemoryDelegationPortfolioStore extends InMemoryDocumentStore<Cardano.Cip17DelegationPortfolio> {}

export class InMemoryAssetsStore extends InMemoryDocumentStore<Assets> {}
export class InMemoryAddressesStore extends InMemoryDocumentStore<GroupedAddress[]> {}
export class InMemoryInFlightTransactionsStore extends InMemoryDocumentStore<TxInFlight[]> {}
export class InMemoryVolatileTransactionsStore extends InMemoryDocumentStore<OutgoingOnChainTx[]> {}
export class InMemorySignedTransactionsStore extends InMemoryDocumentStore<WitnessedTx[]> {}

export class InMemoryTransactionsStore extends InMemoryCollectionStore<Cardano.HydratedTx> {}
export class InMemoryUtxoStore extends InMemoryCollectionStore<Cardano.Utxo> {}
export class InMemoryUnspendableUtxoStore extends InMemoryCollectionStore<Cardano.Utxo> {}

export class InMemoryRewardsHistoryStore extends InMemoryKeyValueStore<Cardano.RewardAccount, Reward[]> {}

export class InMemoryRewardAccountInfoStore extends InMemoryKeyValueStore<
  Cardano.RewardAccount,
  Cardano.RewardAccountInfo
> {}
export class InMemoryStakePoolsStore extends InMemoryKeyValueStore<Cardano.PoolId, Cardano.StakePool> {}

export const createInMemoryWalletStores = (): WalletStores => ({
  addresses: new InMemoryAddressesStore(),
  assets: new InMemoryAssetsStore(),
  delegationPortfolio: new InMemoryDelegationPortfolioStore(),
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
        this.rewardsHistory.destroy(),
        this.rewardAccountInfo.destroy(),
        this.stakePools.destroy(),
        this.tip.destroy(),
        this.transactions.destroy(),
        this.inFlightTransactions.destroy(),
        this.volatileTransactions.destroy(),
        this.utxo.destroy(),
        this.policyIds.destroy()
      ]).pipe(map(() => void 0));
    }
    return EMPTY;
  },
  destroyed: false,
  eraSummaries: new InMemoryEraSummariesStore(),
  genesisParameters: new InMemoryGenesisParametersStore(),
  inFlightTransactions: new InMemoryInFlightTransactionsStore(),
  policyIds: new InMemoryPolicyIdsStore(),
  protocolParameters: new InMemoryProtocolParametersStore(),
  rewardAccountInfo: new InMemoryRewardAccountInfoStore(),
  rewardsHistory: new InMemoryRewardsHistoryStore(),
  signedTransactions: new InMemorySignedTransactionsStore(),
  stakePools: new InMemoryStakePoolsStore(),
  tip: new InMemoryTipStore(),
  transactions: new InMemoryTransactionsStore(),
  unspendableUtxo: new InMemoryUnspendableUtxoStore(),
  utxo: new InMemoryUtxoStore(),
  volatileTransactions: new InMemoryVolatileTransactionsStore()
});
