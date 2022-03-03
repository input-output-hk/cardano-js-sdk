import { Asset, Cardano, ProtocolParametersRequiredByWallet, TimeSettings } from '@cardano-sdk/core';
import { CollectionStore, DocumentStore, GetDocId, OrderedCollectionStore, RewardAccountDocument } from './types';
import { Observable, of } from 'rxjs';
import { sortedIndexBy } from 'lodash-es';

export class InMemoryCollectionStore<T> implements CollectionStore<T> {
  protected readonly docs: T[] = [];
  protected readonly getDocId: GetDocId<T>;

  constructor(getDocId: GetDocId<T>) {
    this.getDocId = getDocId;
  }

  get(): Observable<T[]> {
    return of(this.docs);
  }
  upsert(docs: T[]): Observable<void> {
    for (const newDoc of docs) {
      const newDocId = this.getDocId(newDoc);
      if (!this.docs.some(this.docIdEquals(newDocId))) {
        this.addDoc(newDoc);
      }
    }
    return of(void 0);
  }
  delete(docs: T[]): Observable<void> {
    for (const doc of docs) {
      const docId = this.getDocId(doc);
      const docIndex = this.docs.findIndex(this.docIdEquals(docId));
      if (docIndex >= 0) this.docs.splice(docIndex, 1);
    }
    return of(void 0);
  }

  protected addDoc(newDoc: T) {
    this.docs.push(newDoc);
  }

  protected docIdEquals(docId: string) {
    return (localDoc: T) => this.getDocId(localDoc) === docId;
  }
}

export class InMemoryOrderedCollectionStore<T> extends InMemoryCollectionStore<T> implements OrderedCollectionStore<T> {
  #sortBy: (t: T) => number;

  constructor(getDocId: GetDocId<T>, sortBy: (t: T) => number) {
    super(getDocId);
    this.#sortBy = sortBy;
  }

  protected addDoc(newDoc: T): void {
    this.docs.splice(sortedIndexBy(this.docs, newDoc, this.#sortBy), 0, newDoc);
  }
}

export class InMemoryDocumentStore<T> implements DocumentStore<T> {
  private doc: T | null = null;
  get(): Observable<T | null> {
    return of(this.doc);
  }
  set(doc: T): Observable<void> {
    this.doc = doc;
    return of(void 0);
  }
}

export class InMemoryUtxoStore extends InMemoryCollectionStore<Cardano.Utxo> {
  constructor() {
    super(([{ txId, index }]) => `${txId}-${index}`);
  }
}
export class InMemoryTransactionsStore extends InMemoryOrderedCollectionStore<Cardano.TxAlonzo> {
  constructor() {
    super(
      ({ id }) => id.toString(),
      // Multiplying blockNo by 10_000 in order to distinguish between:
      // - blockNo: 1, index: 1
      // - blockNo: 2, index: 0
      // That should be sufficient since there shouldn't be a block with 1kk TXes
      ({ index, blockHeader: { blockNo } }) => blockNo * 1_000_000 + index
    );
  }
}
export class InMemoryRewardAccountsStore extends InMemoryCollectionStore<RewardAccountDocument> {
  constructor() {
    super(({ rewardAccount }) => rewardAccount.toString());
  }
}
export class InMemoryAssetsStore extends InMemoryCollectionStore<Asset.AssetInfo> {
  constructor() {
    super(({ assetId }) => assetId.toString());
  }
}

export class InMemoryTipStore extends InMemoryDocumentStore<Cardano.Tip> {}
export class InMemoryProtocolParametersStore extends InMemoryDocumentStore<ProtocolParametersRequiredByWallet> {}
export class InMemoryGenesisParametersStore extends InMemoryDocumentStore<Cardano.CompactGenesis> {}
export class InMemoryTimeSettingsStore extends InMemoryDocumentStore<TimeSettings> {}
