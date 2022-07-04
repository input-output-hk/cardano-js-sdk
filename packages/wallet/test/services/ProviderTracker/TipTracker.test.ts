import { Cardano } from '@cardano-sdk/core';
import { InMemoryDocumentStore } from '../../../src/persistence';
import { Milliseconds, SyncStatus } from '../../../src';
import { Observable, firstValueFrom } from 'rxjs';
import { TipTracker } from '../../../src/services';
import { createTestScheduler } from '@cardano-sdk/util-dev';

const stubObservableProvider = <T>(...calls: Observable<T>[]) => {
  let numCall = 0;
  return new Observable<T>((subscriber) => {
    const sub = calls[numCall++].subscribe(subscriber);
    return () => sub.unsubscribe();
  });
};

const mockTips = {
  a: { hash: 'ha' },
  b: { hash: 'hb' },
  c: { hash: 'hc' },
  d: { hash: 'hd' },
  x: { hash: 'hx' },
  y: { hash: 'hy' }
} as unknown as Record<string, Cardano.Tip>;

describe('TipTracker', () => {
  const pollInterval: Milliseconds = 1; // delays emission after trigger
  let store: InMemoryDocumentStore<Cardano.Tip>;

  beforeEach(() => {
    store = new InMemoryDocumentStore();
  });

  it('calls the provider immediately, only emitting distinct values, with throttling', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const syncStatus: Partial<SyncStatus> = { isSettled$: cold('---a---bc--d|') };
      const provider$ = stubObservableProvider<Cardano.Tip>(
        cold('-x|', mockTips),
        cold('--a|', mockTips),
        cold('--b|', mockTips),
        cold('d|', mockTips)
      );
      const tracker$ = new TipTracker({
        maxPollInterval: Number.MAX_VALUE,
        minPollInterval: pollInterval,
        provider$,
        store,
        syncStatus: syncStatus as SyncStatus
      });
      expectObservable(tracker$.asObservable()).toBe('-x----a---b-d', mockTips);
    });
  });

  // mostly covers PersistentDocumentTrackerSubject
  it('emits value from store first (if present) and stores value on each source emission', async () => {
    await firstValueFrom(store.set(mockTips.x));
    store.set = jest.fn().mockImplementation(store.set.bind(store));
    createTestScheduler().run(({ cold, expectObservable }) => {
      const syncStatus: Partial<SyncStatus> = { isSettled$: cold('---a---b|') };
      const provider$ = stubObservableProvider<Cardano.Tip>(
        cold('-y|', mockTips),
        cold('--a|', mockTips),
        cold('-ab|', mockTips)
      );
      const tracker$ = new TipTracker({
        maxPollInterval: Number.MAX_VALUE,
        minPollInterval: pollInterval,
        provider$,
        store,
        syncStatus: syncStatus as SyncStatus
      });
      expectObservable(tracker$.asObservable()).toBe('xy----a---b', mockTips);
    });
    expect(store.set).toBeCalledTimes(3);
    expect(await firstValueFrom(store.get())).toBe(mockTips.b);
  });

  it('times out trigger$ with maxPollInterval, then listens for trigger$ again', () => {
    createTestScheduler().run(({ cold, hot, expectObservable }) => {
      const syncStatus: Partial<SyncStatus> = { isSettled$: hot('10ms a|') };
      const provider$ = stubObservableProvider<Cardano.Tip>(
        cold('-a|', mockTips),
        cold('-b|', mockTips),
        cold('-c|', mockTips)
      );
      const tracker$ = new TipTracker({
        maxPollInterval: 6,
        minPollInterval: pollInterval,
        provider$,
        store,
        syncStatus: syncStatus as SyncStatus
      });
      // b is emitted at t=8 (before trigger$ emits anything)
      // c is emitted at t=12 (after trigger$ emits upon resubscribing to it)
      expectObservable(tracker$, '^ 15ms !').toBe('-a------b---c', mockTips);
    });
  });

  // The code is fairly simple, but quite a few additional tests are needed to test all paths
  it.todo('external trigger cancels an ongoing interval request and makes a new one');
  it.todo('external trigger cancels an ongoing external trigger request and makes a new one');
  it.todo('sync() calls external trigger');
});
