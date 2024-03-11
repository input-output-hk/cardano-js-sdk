import { Assets } from '../types';
import { Cardano, EraSummary, Reward, StakeSummary, SupplySummary } from '@cardano-sdk/core';
import { GroupedAddress } from '@cardano-sdk/key-management';
import { Observable } from 'rxjs';
import { OutgoingOnChainTx, TxInFlight } from '../services';
import { SignedTx } from '@cardano-sdk/tx-construction';

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
   * Similar to getAll, but does not complete. Instead, emits every time the collection is updated (via this store object).
   * Emits empty array when no documents are stored.
   */
  observeAll(): Observable<T[]>;
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
export interface KeyValueStore<K, V> extends Omit<CollectionStore<KeyValueCollection<K, V>>, 'getAll' | 'observeAll'> {
  /**
   * Get the stored documents by keys.
   *
   * @returns {Observable}
   * - When have all requested documents: emits once and completes.
   * - When at least one document is missing or the store is destroyed: completes without emitting.
   */
  getValues(keys: K[]): Observable<V[]>;
  /** Store the document. Should never throw. */
  setValue(key: K, value: V): Observable<void>;
}

export interface WalletStores extends Destroyable {
  tip: DocumentStore<Cardano.Tip>;
  utxo: CollectionStore<Cardano.Utxo>;
  unspendableUtxo: CollectionStore<Cardano.Utxo>;
  transactions: OrderedCollectionStore<Cardano.HydratedTx>;
  inFlightTransactions: DocumentStore<TxInFlight[]>;
  volatileTransactions: DocumentStore<OutgoingOnChainTx[]>;
  rewardsHistory: KeyValueStore<Cardano.RewardAccount, Reward[]>;
  rewardsBalances: KeyValueStore<Cardano.RewardAccount, Cardano.Lovelace>;
  stakePools: KeyValueStore<Cardano.PoolId, Cardano.StakePool>;
  protocolParameters: DocumentStore<Cardano.ProtocolParameters>;
  genesisParameters: DocumentStore<Cardano.CompactGenesis>;
  eraSummaries: DocumentStore<EraSummary[]>;
  assets: DocumentStore<Assets>;
  addresses: DocumentStore<GroupedAddress[]>;
  policyIds: DocumentStore<Cardano.PolicyId[]>;
  signedTransactions: DocumentStore<SignedTx[]>;
}

export interface SupplyDistributionStores extends Destroyable {
  stake: DocumentStore<StakeSummary>;
  lovelaceSupply: DocumentStore<SupplySummary>;
}
