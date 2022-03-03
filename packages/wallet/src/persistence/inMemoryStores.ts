/* eslint-disable brace-style */
import { Assets } from '../types';
import {
  Cardano,
  EpochRewards,
  NetworkInfo,
  ProtocolParametersRequiredByWallet,
  TimeSettings
} from '@cardano-sdk/core';
import {
  CollectionStore,
  DocumentStore,
  KeyValueCollection,
  KeyValueStore,
  RewardAccountDocument,
  WalletStores
} from './types';
import { EMPTY, Observable, of } from 'rxjs';

export class InMemoryCollectionStore<T> implements CollectionStore<T> {
  protected docs: T[] = [];

  getAll(): Observable<T[]> {
    if (this.docs.length === 0) return EMPTY;
    return of(this.docs);
  }

  setAll(docs: T[]): Observable<void> {
    this.docs = docs;
    return of(void 0);
  }
}

export class InMemoryKeyValueStore<K, V>
  extends InMemoryCollectionStore<KeyValueCollection<K, V>>
  implements KeyValueStore<K, V>
{
  getValues(keys: K[]): Observable<V[]> {
    const result: V[] = [];
    for (const key of keys) {
      const value = this.docs.find((doc) => doc.key === key)?.value;
      if (!value) return EMPTY;
      result.push(value);
    }
    return of(result);
  }
  setValue(key: K, value: V): Observable<void> {
    const storedDocIndex = this.docs.findIndex((doc) => doc.key === key);
    if (storedDocIndex >= 0) {
      this.docs.splice(storedDocIndex, 1);
    }
    this.docs.push({ key, value });
    return of(void 0);
  }
}

export class InMemoryDocumentStore<T> implements DocumentStore<T> {
  private doc: T | null = null;
  get(): Observable<T> {
    if (!this.doc) return EMPTY;
    return of(this.doc);
  }
  set(doc: T): Observable<void> {
    this.doc = doc;
    return of(void 0);
  }
}

export class InMemoryTipStore extends InMemoryDocumentStore<Cardano.Tip> {}
export class InMemoryProtocolParametersStore extends InMemoryDocumentStore<ProtocolParametersRequiredByWallet> {}
export class InMemoryGenesisParametersStore extends InMemoryDocumentStore<Cardano.CompactGenesis> {}
export class InMemoryTimeSettingsStore extends InMemoryDocumentStore<TimeSettings[]> {}
export class InMemoryNetworkInfoStore extends InMemoryDocumentStore<NetworkInfo> {}
export class InMemoryAssetsStore extends InMemoryDocumentStore<Assets> {}

export class InMemoryRewardAccountsStore extends InMemoryCollectionStore<RewardAccountDocument> {}
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
