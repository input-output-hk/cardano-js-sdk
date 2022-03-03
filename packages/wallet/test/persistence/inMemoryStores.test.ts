/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  InMemoryAssetsStore,
  InMemoryCollectionStore,
  InMemoryDocumentStore,
  InMemoryGenesisParametersStore,
  InMemoryOrderedCollectionStore,
  InMemoryProtocolParametersStore,
  InMemoryRewardAccountsStore,
  InMemoryTimeSettingsStore,
  InMemoryTipStore,
  InMemoryTransactionsStore,
  InMemoryUtxoStore
} from '../../src/persistence';
import { firstValueFrom } from 'rxjs';

describe('InMemoryStores', () => {
  describe('InMemoryDocumentStore', () => {
    it('remembers the last set document', async () => {
      const store = new InMemoryDocumentStore();
      expect(await firstValueFrom(store.get())).toBeNull();
      const doc = { a: 'b' };
      await firstValueFrom(store.set(doc));
      expect(await firstValueFrom(store.get())).toBe(doc);
    });
  });

  describe('InMemoryCollectionStore', () => {
    it('remembers all unique upserted documents', async () => {
      const doc1 = { a: 'b' };
      const doc2 = { a: 'c' };
      const doc3 = { a: 'd' };
      const store = new InMemoryCollectionStore<typeof doc1>((doc) => doc.a);
      expect(await firstValueFrom(store.get())).toEqual([]);
      await firstValueFrom(store.upsert([doc1, doc2]));
      expect(await firstValueFrom(store.get())).toEqual([doc1, doc2]);
      await firstValueFrom(store.upsert([doc2, doc3]));
      expect(await firstValueFrom(store.get())).toEqual([doc1, doc2, doc3]);
      await firstValueFrom(store.delete([doc2]));
      expect(await firstValueFrom(store.get())).toEqual([doc1, doc3]);
    });
  });

  describe('InMemoryOrderedCollectionStore', () => {
    it('remembers all unique upserted documents, sorted by result of provided fn', async () => {
      const doc1 = { a: 'b', order: 2 };
      const doc2 = { a: 'c', order: 1 };
      const doc3 = { a: 'd', order: 3 };
      const store = new InMemoryOrderedCollectionStore<typeof doc1>(
        ({ a }) => a,
        ({ order }) => order
      );
      expect(await firstValueFrom(store.get())).toEqual([]);
      await firstValueFrom(store.upsert([doc1, doc2]));
      expect(await firstValueFrom(store.get())).toEqual([doc2, doc1]);
      await firstValueFrom(store.upsert([doc2, doc3]));
      expect(await firstValueFrom(store.get())).toEqual([doc2, doc1, doc3]);
    });
  });

  describe('InMemoryUtxoStore', () => {
    const store = new InMemoryUtxoStore();
    it('is implemented using InMemoryCollectionStore', () => expect(store).toBeInstanceOf(InMemoryCollectionStore));
    it('documents are unique by tx id and index', async () => {
      const doc1: any = [{ index: 0, txId: 'tx1' }];
      const doc2: any = [{ index: 0, txId: 'tx2' }];
      const doc3: any = [{ index: 1, txId: 'tx1' }];
      await firstValueFrom(store.upsert([doc1, doc2, doc3, [{ ...doc1[0] }]]));
      expect(await firstValueFrom(store.get())).toEqual([doc1, doc2, doc3]);
    });
  });

  describe('InMemoryRewardAccountsStore ', () => {
    const store = new InMemoryRewardAccountsStore();
    it('is implemented using InMemoryCollectionStore', () => expect(store).toBeInstanceOf(InMemoryCollectionStore));
    it('documents are unique by rewardAccount', async () => {
      const doc1: any = { rewardAccount: 'acc1' };
      const doc2: any = { rewardAccount: 'acc2' };
      await firstValueFrom(store.upsert([doc1, doc2, { ...doc1 }]));
      expect(await firstValueFrom(store.get())).toEqual([doc1, doc2]);
    });
  });

  describe('InMemoryAssetsStore', () => {
    const store = new InMemoryAssetsStore();
    it('is implemented using InMemoryCollectionStore', () => expect(store).toBeInstanceOf(InMemoryCollectionStore));
    it('documents are unique by assetId', async () => {
      const doc1: any = { assetId: 'asset1' };
      const doc2: any = { assetId: 'asset2' };
      await firstValueFrom(store.upsert([doc1, doc2, { ...doc1 }]));
      expect(await firstValueFrom(store.get())).toEqual([doc1, doc2]);
    });
  });

  describe('InMemoryTransactionsStore', () => {
    const store = new InMemoryTransactionsStore();
    const doc1: any = { blockHeader: { blockNo: 2 }, id: 'tx1', index: 1 };
    const doc2: any = { blockHeader: { blockNo: 2 }, id: 'tx2', index: 0 };
    const doc3: any = { blockHeader: { blockNo: 1 }, id: 'tx3', index: 0 };

    it('is implemented using InMemoryOrderedCollectionStore', () =>
      expect(store).toBeInstanceOf(InMemoryOrderedCollectionStore));
    it('documents are unique by transaction id', async () => {
      await firstValueFrom(store.upsert([doc1, doc2, { ...doc1 }]));
      expect(await firstValueFrom(store.get())).toEqual([doc2, doc1]);
    });
    it('documents are sorted blockNo+index', async () => {
      await firstValueFrom(store.upsert([doc3]));
      expect(await firstValueFrom(store.get())).toEqual([doc3, doc2, doc1]);
    });
  });

  it('Specific document stores are implemented using InMemoryDocumentStore', () => {
    expect(new InMemoryTipStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryProtocolParametersStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryGenesisParametersStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryTimeSettingsStore()).toBeInstanceOf(InMemoryDocumentStore);
  });
});
