import {
  InMemoryAssetsStore,
  InMemoryCollectionStore,
  InMemoryDocumentStore,
  InMemoryGenesisParametersStore,
  InMemoryKeyValueStore,
  InMemoryNetworkInfoStore,
  InMemoryProtocolParametersStore,
  InMemoryRewardAccountsStore,
  InMemoryRewardsBalancesStore,
  InMemoryRewardsHistoryStore,
  InMemoryStakePoolsStore,
  InMemoryTimeSettingsStore,
  InMemoryTipStore,
  InMemoryTransactionsStore,
  InMemoryUtxoStore
} from '../../src/persistence';
import { Observable, firstValueFrom } from 'rxjs';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const assertCompletesWithoutEmitting = async (observable: Observable<any>) =>
  expect(
    await new Promise((resolve, reject) =>
      observable.subscribe({ complete: () => resolve(true), error: reject, next: reject })
    )
  ).toBe(true);

describe('inMemoryStores', () => {
  describe('InMemoryDocumentStore', () => {
    it('remembers the last set document', async () => {
      const store = new InMemoryDocumentStore();
      await assertCompletesWithoutEmitting(store.get());
      const doc = { a: 'b' };
      await firstValueFrom(store.set(doc));
      expect(await firstValueFrom(store.get())).toBe(doc);
    });
  });

  describe('InMemoryCollectionStore', () => {
    it('Remembers last set array object', async () => {
      const store = new InMemoryCollectionStore();
      await assertCompletesWithoutEmitting(store.getAll());
      const docs = [{ a: 'b' }];
      await firstValueFrom(store.setAll(docs));
      expect(await firstValueFrom(store.getAll())).toBe(docs);
    });
  });

  describe('InMemoryKeyValueStore', () => {
    let store: InMemoryKeyValueStore<string, string>;

    beforeEach(() => {
      store = new InMemoryKeyValueStore();
    });

    it('Extends InMemoryCollectionStore', () => {
      expect(new InMemoryKeyValueStore()).toBeInstanceOf(InMemoryCollectionStore);
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
  });

  it('Specific collection stores are implemented using InMemoryCollectionStore', () => {
    expect(new InMemoryTransactionsStore()).toBeInstanceOf(InMemoryCollectionStore);
    expect(new InMemoryRewardAccountsStore()).toBeInstanceOf(InMemoryCollectionStore);
    expect(new InMemoryUtxoStore()).toBeInstanceOf(InMemoryCollectionStore);
  });

  it('Specific collection stores are implemented using InMemoryKeyValueStore', () => {
    expect(new InMemoryRewardsHistoryStore()).toBeInstanceOf(InMemoryKeyValueStore);
    expect(new InMemoryStakePoolsStore()).toBeInstanceOf(InMemoryKeyValueStore);
    expect(new InMemoryRewardsBalancesStore()).toBeInstanceOf(InMemoryKeyValueStore);
  });

  it('Specific document stores are implemented using InMemoryDocumentStore', () => {
    expect(new InMemoryTipStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryProtocolParametersStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryGenesisParametersStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryTimeSettingsStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryNetworkInfoStore()).toBeInstanceOf(InMemoryDocumentStore);
    expect(new InMemoryAssetsStore()).toBeInstanceOf(InMemoryDocumentStore);
  });
});
