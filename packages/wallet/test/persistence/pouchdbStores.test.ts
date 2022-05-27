/* eslint-disable unicorn/consistent-function-scoping */
import { PouchdbCollectionStore, PouchdbDocumentStore, PouchdbKeyValueStore } from '../../src/persistence';
import { assertCompletesWithoutEmitting } from './util';
import { firstValueFrom } from 'rxjs';
import PouchDB from 'pouchdb';

describe('pouchdbStores', () => {
  const dbName = 'DbTestWallet';
  const doc1 = { __unsupportedKey: '1', bigint: 1n, map: new Map([[1, 2]]) };
  const doc2 = { __unsupportedKey: '2', bigint: 2n, map: new Map([[3, 4]]) };
  type DocType = typeof doc1;

  afterAll(async () => {
    // delete files from the filesystem
    await new PouchDB(dbName).destroy();
  });

  describe('PouchdbDocumentStore', () => {
    it('stores and restores a document', async () => {
      const store1 = new PouchdbDocumentStore<DocType>(dbName, 'docId');
      await store1.clearDB();
      await assertCompletesWithoutEmitting(store1.get());
      await firstValueFrom(store1.set(doc1));

      const store2 = new PouchdbDocumentStore<DocType>(dbName, 'docId');
      expect(await firstValueFrom(store2.get())).toEqual(doc1);
    });

    // eslint-disable-next-line sonarjs/no-duplicate-string
    it('destroy() disables store functions', async () => {
      const store = new PouchdbDocumentStore<DocType>(dbName, 'docId');
      await firstValueFrom(store.set(doc1));
      await firstValueFrom(store.destroy());
      await assertCompletesWithoutEmitting(store.get());
      await assertCompletesWithoutEmitting(store.set(doc2));
    });

    it.todo('set() completes without emitting on any pouchdb error');
  });

  describe('PouchdbCollectionStore', () => {
    const createStore = () => new PouchdbCollectionStore<DocType>(dbName, ({ __unsupportedKey }) => __unsupportedKey);
    let store1: PouchdbCollectionStore<DocType>;

    beforeEach(async () => {
      store1 = createStore();
      await store1.clearDB();
    });

    it('stores and restores a collection, ordered by result of computeDocId', async () => {
      await assertCompletesWithoutEmitting(store1.getAll());
      await firstValueFrom(store1.setAll([doc2, doc1]));

      const store2 = createStore();
      expect(await firstValueFrom(store2.getAll())).toEqual([doc1, doc2]);
    });

    it('setAll overwrites the entire collection', async () => {
      await firstValueFrom(store1.setAll([doc2, doc1]));
      await firstValueFrom(store1.setAll([doc2]));
      expect(await firstValueFrom(store1.getAll())).toEqual([doc2]);
    });

    it('destroy() disables store functions', async () => {
      await firstValueFrom(store1.setAll([doc1]));
      await firstValueFrom(store1.destroy());
      await assertCompletesWithoutEmitting(store1.getAll());
      await assertCompletesWithoutEmitting(store1.setAll([doc2]));
    });

    it.todo('setAll completes without emitting on any pouchdb error');
  });

  describe('PouchdbKeyValueStore', () => {
    const createStore = () => new PouchdbKeyValueStore<string, DocType>(dbName);
    let store1: PouchdbKeyValueStore<string, DocType>;
    const key1 = 'key1';
    const key2 = 'key2';
    const key3 = 'key3';

    beforeEach(async () => {
      store1 = createStore();
      await store1.clearDB();
    });

    it('stores and restores key-value pair', async () => {
      await firstValueFrom(store1.setValue(key1, doc1));

      const store2 = createStore();
      expect(await firstValueFrom(store2.getValues([key1]))).toEqual([doc1]);
    });

    it('getValue completes without emitting when document is not present', async () => {
      await assertCompletesWithoutEmitting(store1.getValues([key2]));
      await firstValueFrom(store1.setValue(key1, doc1));
      await assertCompletesWithoutEmitting(store1.getValues([key2]));
    });

    it('setAll overwrites the entire collection', async () => {
      await firstValueFrom(store1.setValue(key1, doc1));
      await firstValueFrom(
        store1.setAll([
          { key: key1, value: doc1 },
          { key: key3, value: doc2 }
        ])
      );
      await assertCompletesWithoutEmitting(store1.getValues([key2]));
      expect(await firstValueFrom(store1.getValues([key3, key1]))).toEqual([doc2, doc1]);
    });

    it('destroy() disables store functions', async () => {
      await firstValueFrom(store1.setValue(key1, doc1));
      await firstValueFrom(store1.destroy());
      await assertCompletesWithoutEmitting(store1.getValues([key1]));
      await assertCompletesWithoutEmitting(store1.setValue(key1, doc1));
      await assertCompletesWithoutEmitting(store1.setAll([{ key: key2, value: doc2 }]));
    });

    it.todo('setAll and setValues completes without emitting on any pouchdb error');
  });
});
