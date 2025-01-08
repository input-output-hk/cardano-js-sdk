import {
  InMemoryAddressesStore,
  InMemoryAssetsStore,
  InMemoryCollectionStore,
  InMemoryDocumentStore,
  InMemoryEraSummariesStore,
  InMemoryGenesisParametersStore,
  InMemoryInFlightTransactionsStore,
  InMemoryKeyValueStore,
  InMemoryProtocolParametersStore,
  InMemoryRewardAccountInfoStore,
  InMemoryRewardsHistoryStore,
  InMemoryStakePoolsStore,
  InMemoryStakeSummaryStore,
  InMemorySupplySummaryStore,
  InMemoryTipStore,
  InMemoryTransactionsStore,
  InMemoryUtxoStore
} from '../../src/persistence';
import { assertCompletesWithoutEmitting } from './util';
import { firstValueFrom, mergeMap, share, shareReplay, take, toArray } from 'rxjs';

describe('inMemoryStores', () => {
  describe('InMemoryDocumentStore', () => {
    const doc = { a: 'b' };
    it('remembers the last set document', async () => {
      const store = new InMemoryDocumentStore();
      await assertCompletesWithoutEmitting(store.get());
      await firstValueFrom(store.set(doc));
      expect(await firstValueFrom(store.get())).toBe(doc);
    });
    // eslint-disable-next-line sonarjs/no-duplicate-string
    it('destroy() disables store functions', async () => {
      const store = new InMemoryDocumentStore();
      await firstValueFrom(store.set(doc));
      await firstValueFrom(store.destroy());
      await assertCompletesWithoutEmitting(store.get());
      await assertCompletesWithoutEmitting(store.set(doc));
    });
  });

  describe('InMemoryCollectionStore', () => {
    const docs = [{ a: 'b' }];
    it('Remembers last set array object', async () => {
      const store = new InMemoryCollectionStore();
      await assertCompletesWithoutEmitting(store.getAll());
      await firstValueFrom(store.setAll(docs));
      expect(await firstValueFrom(store.getAll())).toBe(docs);
    });
    it('destroy() disables store functions', async () => {
      const store = new InMemoryCollectionStore();
      await firstValueFrom(store.setAll(docs));
      await firstValueFrom(store.destroy());
      await assertCompletesWithoutEmitting(store.getAll());
      await assertCompletesWithoutEmitting(store.setAll(docs));
    });
    describe('observeAll', () => {
      it('emits an empty array when collection is empty', async () => {
        const store = new InMemoryCollectionStore();
        await expect(firstValueFrom(store.observeAll())).resolves.toEqual([]);
      });
      it('emits all items upon subscription', async () => {
        const store = new InMemoryCollectionStore();
        await firstValueFrom(store.setAll(docs));
        await expect(firstValueFrom(store.observeAll())).resolves.toEqual(docs);
      });
      it('emits updated items when setAll is called after subscription', async () => {
        const updatedDocs = [...docs, { c: 'd' }];
        const store = new InMemoryCollectionStore();
        await firstValueFrom(store.setAll(docs));
        const observe$ = store.observeAll().pipe(share());
        const firstEmission = firstValueFrom(observe$);
        const twoEmissions = firstValueFrom(observe$.pipe(take(2), toArray()));
        await firstEmission;
        await firstValueFrom(store.setAll(updatedDocs));
        await expect(twoEmissions).resolves.toEqual([docs, updatedDocs]);
      });
      it('observeAll followed by immediate setAll does not skip 2nd emission', async () => {
        const store = new InMemoryCollectionStore();
        const items$ = store.observeAll().pipe(shareReplay(1));
        await firstValueFrom(items$.pipe(mergeMap(() => store.setAll(docs))));
        await expect(firstValueFrom(items$)).resolves.toEqual(docs);
      });
    });
  });

  describe('InMemoryKeyValueStore', () => {
    let store: InMemoryKeyValueStore<string, string>;

    beforeEach(() => {
      store = new InMemoryKeyValueStore();
    });

    it('Extends InMemoryCollectionStore', () => {
      expect(store).toBeInstanceOf(InMemoryCollectionStore);
    });

    it('getValues([]) completes without emittting', async () => {
      await assertCompletesWithoutEmitting(store.getValues([]));
    });

    it('setValue inserts a new value or updates an existing value', async () => {
      // eslint-disable-next-line unicorn/consistent-function-scoping
      const setValueAndAssertStore = async (value: string) => {
        const key = 'key';
        await firstValueFrom(store.setValue(key, value));
        const storedValues = await firstValueFrom(store.getAll());
        expect(storedValues.length).toBe(1);
        expect(storedValues[0]).toEqual({ key, value });
      };
      await setValueAndAssertStore('value1');
      await setValueAndAssertStore('value2');
    });

    it('completes without emitting if missing a value', async () => {
      store.setValue('key', 'value');
      await assertCompletesWithoutEmitting(store.getValues(['other-key']));
    });
    it('resolves with a value per supplied key', async () => {
      await firstValueFrom(
        store.setAll([
          { key: 'key1', value: 'value1' },
          { key: 'key2', value: 'value2' },
          { key: 'key3', value: 'value3' }
        ])
      );
      expect(await firstValueFrom(store.getValues(['key1', 'key3']))).toEqual(['value1', 'value3']);
    });

    it('destroy() disables store functions', async () => {
      const docs = [{ key: 'key1', value: 'value1' }];
      await firstValueFrom(store.setAll(docs));
      await firstValueFrom(store.destroy());
      await assertCompletesWithoutEmitting(store.setValue('key1', 'value2'));
      await assertCompletesWithoutEmitting(store.setAll(docs));
      await assertCompletesWithoutEmitting(store.getValues([docs[0].key]));
    });
  });

  it('Specific collection stores are implemented using InMemoryCollectionStore', () => {
    expect(new InMemoryTransactionsStore()).toBeInstanceOf(InMemoryCollectionStore);
    expect(new InMemoryUtxoStore()).toBeInstanceOf(InMemoryCollectionStore);
  });

  it('Specific collection stores are implemented using InMemoryKeyValueStore', () => {
    expect(new InMemoryRewardsHistoryStore()).toBeInstanceOf(InMemoryKeyValueStore);
    expect(new InMemoryStakePoolsStore()).toBeInstanceOf(InMemoryKeyValueStore);
    expect(new InMemoryRewardAccountInfoStore()).toBeInstanceOf(InMemoryKeyValueStore);
  });

  it('Specific document stores are implemented using InMemoryDocumentStore', () => {
    expect(new InMemoryTipStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryProtocolParametersStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryGenesisParametersStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemorySupplySummaryStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryStakeSummaryStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryEraSummariesStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryAssetsStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryAddressesStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryInFlightTransactionsStore()).toBeInstanceOf(InMemoryDocumentStore);
  });
});
