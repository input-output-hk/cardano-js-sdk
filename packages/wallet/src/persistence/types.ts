import { Asset, Cardano, ProtocolParametersRequiredByWallet, TimeSettings } from '@cardano-sdk/core';
import { Delegatee } from '../services';
import { Observable } from 'rxjs';

export interface CollectionStore<T> {
  get(): Observable<T[]>;
  /**
   * Store the documents.
   * Note: caller is allowed to do `upsert(x);upsert(x);`, expecting to have only 1 x stored.
   *
   * @param docs documents to store
   */
  upsert(docs: T[]): Observable<void>;
  delete(docs: T[]): Observable<void>;
}

export type OrderedCollectionStore<T> = CollectionStore<T>;

export interface DocumentStore<T> {
  get(): Observable<T | null>;
  set(doc: T): Observable<void>;
}

export interface RewardAccountDocument {
  rewardAccount: Cardano.RewardAccount;
  rewards: Cardano.Lovelace;
  delegatee: Delegatee;
}

export interface AssetDocument {
  assetId: Cardano.AssetId;
  info: Asset.AssetInfo;
}

export interface WalletStores {
  tip: DocumentStore<Cardano.Tip>;
  utxo: CollectionStore<Cardano.Utxo>;
  transactions: OrderedCollectionStore<Cardano.TxAlonzo>;
  rewardAccounts: CollectionStore<RewardAccountDocument>;
  protocolParameters: DocumentStore<ProtocolParametersRequiredByWallet>;
  genesisParameters: DocumentStore<Cardano.CompactGenesis>;
  timeSettings: DocumentStore<TimeSettings>;
  assets: CollectionStore<AssetDocument>;
}

export type GetDocId<T> = (doc: T) => string;
