import { InMemoryCollectionStore, InMemoryDocumentStore } from '../../../src/persistence';
import { Milliseconds } from '../../../src';
import { Observable, firstValueFrom, interval, take } from 'rxjs';
import {
  PersistentCollectionTrackerSubject,
  SyncableIntervalPersistentDocumentTrackerSubject
} from '../../../src/services/util';
import { createTestScheduler } from '../../testScheduler';

const testInterval = ({ pollInterval, numTriggers }: { pollInterval: number; numTriggers: number }) =>
  interval(pollInterval).pipe(take(numTriggers));

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
  let pollInterval: Milliseconds; // not used, overwriting interval$
  let store: InMemoryDocumentStore<string>;

  beforeEach(() => {
    store = new InMemoryDocumentStore();
  });

  it('calls the provider immediately and then every [pollInterval], only emitting distinct values', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const provider$ = stubObservableProvider(cold('--a|'), cold('--b|'), cold('c|'));
      const tracker$ = new SyncableIntervalPersistentDocumentTrackerSubject(
        { pollInterval, provider$, store },
        { interval$: testInterval({ numTriggers: 2, pollInterval: 5 }) }
      );
      expectObservable(tracker$.asObservable()).toBe('--a----b--c');
    });
  });

  // mostly covers PersistentDocumentTrackerSubject
  it('emits value from store first (if present) and stores value on each source emission', async () => {
    await firstValueFrom(store.set('x'));
    store.set = jest.fn().mockImplementation(store.set.bind(store));
    createTestScheduler().run(({ cold, expectObservable }) => {
      const provider$ = stubObservableProvider(cold('--a|'), cold('--b|'), cold('c|'));
      const tracker$ = new SyncableIntervalPersistentDocumentTrackerSubject(
        { pollInterval, provider$, store },
        { interval$: testInterval({ numTriggers: 2, pollInterval: 5 }) }
      );
      expectObservable(tracker$.asObservable()).toBe('x-a----b--c');
    });
    expect(store.set).toBeCalledTimes(3);
    expect(await firstValueFrom(store.get())).toBe('c');
  });

  it('doesnt wait for subscriptions to subscribe to underlying provider', () => {
    createTestScheduler().run(({ cold, flush }) => {
      const provider$ = cold('--a|');
      const tracker$ = new SyncableIntervalPersistentDocumentTrackerSubject(
        { pollInterval, provider$, store },
        { interval$: testInterval({ numTriggers: 3, pollInterval: 5 }) }
      );
      flush();
      expect(tracker$.value).toBe('a');
    });
  });

  it('throttles interval requests to provider', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const provider$ = stubObservableProvider(cold('-----a|'), cold('-----b|'), cold('c'));
      const tracker$ = new SyncableIntervalPersistentDocumentTrackerSubject(
        { pollInterval, provider$, store },
        { interval$: testInterval({ numTriggers: 3, pollInterval: 5 }) }
      );
      expectObservable(tracker$).toBe('-----a---------b');
    });
  });

  // The code is fairly simple, but quite a few additional tests are needed to test all paths
  it.todo('external trigger cancels an ongoing interval request and makes a new one');
  it.todo('external trigger cancels an ongoing external trigger request and makes a new one');
  it.todo('sync() calls external trigger');
  it.todo('retries on interval requests failure with exponential backoff strategy');
  it.todo('retries on any external trigger requests failure with exponential backoff strategy');
});
