import { InMemoryCollectionStore } from '../../../src/persistence/index.js';
import { PersistentCollectionTrackerSubject } from '../../../src/services/util/index.js';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { firstValueFrom } from 'rxjs';

describe('PersistentCollectionTrackerSubject', () => {
  let store: InMemoryCollectionStore<string>;

  beforeEach(() => {
    store = new InMemoryCollectionStore();
  });

  it('emits from source if no documents are stored', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const a = ['a'];
      const b = ['a', 'b'];
      const c = ['a', 'b', 'c'];
      const source$ = cold('--a---b-c', { a, b, c });
      const tracker$ = new PersistentCollectionTrackerSubject<string>(() => source$, store);
      expectObservable(tracker$.asObservable()).toBe('--a---b-c', { a, b, c });
    });
  });

  it('emits from the store first if some documents are stored and stores value on each source emission', async () => {
    const a = ['a'];
    const b = ['a', 'b'];
    const c = ['a', 'b', 'c'];
    await firstValueFrom(store.setAll(a));
    store.setAll = jest.fn().mockImplementation(store.setAll.bind(store));
    createTestScheduler().run(({ cold, expectObservable }) => {
      const source$ = cold('--b--c', { b, c });
      const tracker$ = new PersistentCollectionTrackerSubject<string>(() => source$, store);
      expectObservable(tracker$.asObservable()).toBe('a-b--c', { a, b, c });
    });
    expect(store.setAll).toBeCalledTimes(2);
    expect(await firstValueFrom(store.getAll())).toBe(c);
  });
});
