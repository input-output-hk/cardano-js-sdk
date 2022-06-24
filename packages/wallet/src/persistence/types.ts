import { Assets } from '../types';
import { Cardano, EpochRewards, NetworkInfo, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { GroupedAddress } from '../KeyManagement';
import { Observable } from 'rxjs';

export interface Destroyable {
  destroyed: boolean;
  /**
   * Clear all resources used by the store.
   *
   * @returns {Observable} Emits undefined and completes. Completes without emitting if store is already destroyed.
   */
  destroy(): Observable<void>;
}

export interface CollectionStore<T> extends Destroyable {
  /**
   * Get all stored documents.
   *
   * @returns {Observable}
   * - When have some documents stored: emits once and completes.
   * - When no documents are stored or the store is destroyed: completes without emitting.
   */
  getAll(): Observable<T[]>;
  /**
   * Store the full set of documents.
   * getAll() after setAll(docs) should return the same set of 'docs'.
   * Should never throw.
   *
   * @returns {Observable} Emits undefined and completes. Completes without emitting if the store is destroyed.
   */
  setAll(docs: T[]): Observable<void>;
}

export type OrderedCollectionStore<T> = CollectionStore<T>;

export interface DocumentStore<T> extends Destroyable {
  /**
   * Get the stored document.
   *
   * @returns {Observable}
   * - When have some document stored: emits once and completes.
   * - When no document is stored or the store is destroyed: completes without emitting.
   */
  get(): Observable<T>;
  /**
   * Store the document. Should never throw.
   *
   * @returns {Observable} Emits undefined and completes. Completes without emitting if the store is destroyed.
   */
  set(doc: T): Observable<void>;
}

export type KeyValueCollection<K, V> = { key: K; value: V };
// getAll is not currently used anywhere for this type of store
export interface KeyValueStore<K, V> extends Omit<CollectionStore<KeyValueCollection<K, V>>, 'getAll'> {
  /**
   * Get the stored documents by keys.
   *
   * @returns {Observable}
   * - When have all requested documents: emits once and completes.
   * - When at least one document is missing or the store is destroyed: completes without emitting.
   */
  getValues(keys: K[]): Observable<V[]>;
  /**
   * Store the document. Should never throw.
   */
  setValue(key: K, value: V): Observable<void>;
}

export interface WalletStores extends Destroyable {
  tip: DocumentStore<Cardano.Tip>;
  utxo: CollectionStore<Cardano.Utxo>;
  unspendableUtxo: CollectionStore<Cardano.Utxo>;
  transactions: OrderedCollectionStore<Cardano.TxAlonzo>;
  inFlightTransactions: DocumentStore<Cardano.NewTxAlonzo[]>;
  rewardsHistory: KeyValueStore<Cardano.RewardAccount, EpochRewards[]>;
  rewardsBalances: KeyValueStore<Cardano.RewardAccount, Cardano.Lovelace>;
  stakePools: KeyValueStore<Cardano.PoolId, Cardano.StakePool>;
  protocolParameters: DocumentStore<ProtocolParametersRequiredByWallet>;
  genesisParameters: DocumentStore<Cardano.CompactGenesis>;
  networkInfo: DocumentStore<NetworkInfo>;
  assets: DocumentStore<Assets>;
  addresses: DocumentStore<GroupedAddress[]>;
}
