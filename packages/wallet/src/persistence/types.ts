import { Assets } from '../types';
import {
  Cardano,
  EpochRewards,
  NetworkInfo,
  ProtocolParametersRequiredByWallet,
  TimeSettings
} from '@cardano-sdk/core';
import { Delegatee } from '../services';
import { Observable } from 'rxjs';

export interface CollectionStore<T> {
  /**
   * Get all stored documents.
   * Either:
   * - When have some documents stored: emits once and completes.
   * - When no documents are stored: completes without emitting.
   */
  getAll(): Observable<T[]>;
  /**
   * Store the full set of documents.
   * getAll() after setAll(docs) should return the same set of 'docs'.
   * Should never throw.
   */
  setAll(docs: T[]): Observable<void>;
}

export type OrderedCollectionStore<T> = CollectionStore<T>;

export interface DocumentStore<T> {
  /**
   * Get the stored document.
   * Either:
   * - When have some document stored: emits once and completes.
   * - When no document is stored: completes without emitting.
   */
  get(): Observable<T>;
  /**
   * Store the document. Should never throw.
   */
  set(doc: T): Observable<void>;
}

export type KeyValueCollection<K, V> = { key: K; value: V };
// getAll is not currently used anywhere for this type of store
export interface KeyValueStore<K, V> extends Omit<CollectionStore<KeyValueCollection<K, V>>, 'getAll'> {
  /**
   * Get the stored documents by keys.
   * Either:
   * - When have all requested documents: emits once and completes.
   * - When at least one document is missing: completes without emitting.
   */
  getValues(keys: K[]): Observable<V[]>;
  /**
   * Store the document. Should never throw.
   */
  setValue(key: K, value: V): Observable<void>;
}

export interface RewardAccountDocument {
  rewardAccount: Cardano.RewardAccount;
  rewards: Cardano.Lovelace;
  delegatee: Delegatee;
}

export interface WalletStores {
  tip: DocumentStore<Cardano.Tip>;
  utxo: CollectionStore<Cardano.Utxo>;
  transactions: OrderedCollectionStore<Cardano.TxAlonzo>;
  rewardsHistory: KeyValueStore<Cardano.RewardAccount, EpochRewards[]>;
  rewardsBalances: KeyValueStore<Cardano.RewardAccount, Cardano.Lovelace>;
  stakePools: KeyValueStore<Cardano.PoolId, Cardano.StakePool>;
  protocolParameters: DocumentStore<ProtocolParametersRequiredByWallet>;
  genesisParameters: DocumentStore<Cardano.CompactGenesis>;
  timeSettings: DocumentStore<TimeSettings[]>;
  networkInfo: DocumentStore<NetworkInfo>;
  assets: DocumentStore<Assets>;
}
