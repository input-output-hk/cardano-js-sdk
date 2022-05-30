import { InMemoryCollectionStore, InMemoryDocumentStore } from '../../../src/persistence';
import { Milliseconds } from '../../../src';
import { Observable, firstValueFrom } from 'rxjs';
import {
  PersistentCollectionTrackerSubject,
  SyncableIntervalPersistentDocumentTrackerSubject
} from '../../../src/services/util';
import { createTestScheduler } from '@cardano-sdk/util-dev';

const stubObservableProvider = <T>(...calls: Observable<T>[]) => {
  let numCall = 0;
  return new Observable<T>((subscriber) => {
    const sub = calls[numCall++].subscribe(subscriber);
    return () => sub.unsubscribe();
  });
};

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

describe('SyncableIntervalPersistentDocumentTrackerSubject', () => {
  const pollInterval: Milliseconds = 1; // delays emission after trigger
  let store: InMemoryDocumentStore<string>;

  beforeEach(() => {
    store = new InMemoryDocumentStore();
  });

  it('calls the provider immediately and on trigger$, only emitting distinct values, with throttling', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const trigger$ = cold('---a---bc--d|');
      const provider$ = stubObservableProvider(cold('-x|'), cold('--a|'), cold('--b|'), cold('d|'));
      const tracker$ = new SyncableIntervalPersistentDocumentTrackerSubject({
        maxPollInterval: Number.MAX_VALUE,
        pollInterval,
        provider$,
        store,
        trigger$
      });
      expectObservable(tracker$.asObservable()).toBe('-x----a---b-d');
    });
  });

  // mostly covers PersistentDocumentTrackerSubject
  it('emits value from store first (if present) and stores value on each source emission', async () => {
    await firstValueFrom(store.set('x'));
    store.set = jest.fn().mockImplementation(store.set.bind(store));
    createTestScheduler().run(({ cold, expectObservable }) => {
      const trigger$ = cold('---a---b|');
      const provider$ = stubObservableProvider(cold('-y|'), cold('--a|'), cold('-ab|'));
      const tracker$ = new SyncableIntervalPersistentDocumentTrackerSubject({
        maxPollInterval: Number.MAX_VALUE,
        pollInterval,
        provider$,
        store,
        trigger$
      });
      expectObservable(tracker$.asObservable()).toBe('xy----a---b');
    });
    expect(store.set).toBeCalledTimes(3);
    expect(await firstValueFrom(store.get())).toBe('b');
  });

  it('times out trigger$ with maxPollInterval, then listens for trigger$ again', () => {
    createTestScheduler().run(({ cold, hot, expectObservable }) => {
      const trigger$ = hot('10ms a|');
      const provider$ = stubObservableProvider(cold('-a|'), cold('-b|'), cold('-c|'));
      const tracker$ = new SyncableIntervalPersistentDocumentTrackerSubject({
        maxPollInterval: 6,
        pollInterval,
        provider$,
        store,
        trigger$
      });
      // b is emitted at t=8 (before trigger$ emits anything)
      // c is emitted at t=12 (after trigger$ emits upon resubscribing to it)
      expectObservable(tracker$, '^ 15ms !').toBe('-a------b---c');
    });
  });

  // The code is fairly simple, but quite a few additional tests are needed to test all paths
  it.todo('external trigger cancels an ongoing interval request and makes a new one');
  it.todo('external trigger cancels an ongoing external trigger request and makes a new one');
  it.todo('sync() calls external trigger');
});
