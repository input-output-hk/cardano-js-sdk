import { Cardano } from '@cardano-sdk/core';
import { ConnectionStatus, TipTracker } from '../../src/services';
import { InMemoryDocumentStore } from '../../src/persistence';
import { Milliseconds, SyncStatus } from '../../src';
import { NEVER, Observable, firstValueFrom, of, take, takeUntil, timer } from 'rxjs';
import { createStubObservable, createTestScheduler } from '@cardano-sdk/util-dev';
import { dummyLogger } from 'ts-log';

const mockTips = {
  a: { hash: 'ha' },
  b: { hash: 'hb' },
  c: { hash: 'hc' },
  d: { hash: 'hd' },
  x: { hash: 'hx' },
  y: { hash: 'hy' }
} as unknown as Record<string, Cardano.Tip>;

const trueFalse = { f: false, t: true };

describe('TipTracker', () => {
  const pollInterval: Milliseconds = 1; // delays emission after trigger
  let store: InMemoryDocumentStore<Cardano.Tip>;
  let connectionStatus$: Observable<ConnectionStatus>;
  const logger = dummyLogger;

  beforeEach(() => {
    store = new InMemoryDocumentStore();
    connectionStatus$ = of(ConnectionStatus.up);
  });

  it('calls the provider as soon as subscribed', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const provider$ = createStubObservable<Cardano.Tip>(cold('a|', mockTips));
      const tracker$ = new TipTracker({
        connectionStatus$,
        logger,
        maxPollInterval: Number.MAX_VALUE,
        minPollInterval: pollInterval,
        provider$,
        store,
        syncStatus: { isSettled$: NEVER } as unknown as SyncStatus
      });
      expectObservable(tracker$.asObservable().pipe(take(1))).toBe('(a|)', mockTips);
    });
  });

  it('LW-11686 ignores multiple syncStatus emissions during pollInterval', () => {
    const poll: Milliseconds = 3;
    const sync = '-ttt-t----|';
    const tipT = 'a---b---c-|';
    // a-b--c-d|
    createTestScheduler().run(({ cold, expectObservable }) => {
      const syncStatus: Partial<SyncStatus> = { isSettled$: cold(sync, trueFalse) };
      const provider$ = createStubObservable<Cardano.Tip>(
        cold('(a|)', mockTips),
        cold('(b|)', mockTips),
        cold('(c|)', mockTips),
        cold('(d|)', mockTips)
      );
      const tracker$ = new TipTracker({
        connectionStatus$,
        logger,
        maxPollInterval: Number.MAX_VALUE,
        minPollInterval: poll,
        provider$,
        store,
        syncStatus: syncStatus as SyncStatus
      });
      expectObservable(tracker$.asObservable().pipe(takeUntil(timer(10)))).toBe(tipT, mockTips);
    });
  });

  it('calls the provider immediately, only emitting distinct values, with throttling', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const syncStatus: Partial<SyncStatus> = { isSettled$: cold('---a---bc--d|') };
      const provider$ = createStubObservable<Cardano.Tip>(
        cold('-x|', mockTips),
        cold('--a|', mockTips),
        cold('--b|', mockTips),
        cold('d|', mockTips)
      );
      const tracker$ = new TipTracker({
        connectionStatus$,
        logger,
        maxPollInterval: Number.MAX_VALUE,
        minPollInterval: pollInterval,
        provider$,
        store,
        syncStatus: syncStatus as SyncStatus
      });
      expectObservable(tracker$.asObservable()).toBe('-x----a---b-d', mockTips);
    });
  });

  it('starting offline, then coming online should subscribe to provider immediately for initial fetch', () => {
    createTestScheduler().run(({ cold, hot, expectObservable, expectSubscriptions }) => {
      const connectionStatusOffOn$ = hot('d--u----|', {
        d: ConnectionStatus.down,
        u: ConnectionStatus.up
      });
      const syncStatus: Partial<SyncStatus> = { isSettled$: cold('------|') };
      const provider$ = cold<Cardano.PartialBlockHeader>('|');
      const tracker$ = new TipTracker({
        connectionStatus$: connectionStatusOffOn$,
        logger,
        maxPollInterval: Number.MAX_VALUE,
        minPollInterval: pollInterval,
        provider$,
        store,
        syncStatus: syncStatus as SyncStatus
      });
      expectObservable(tracker$, '^-----------!').toBe('----');
      // unsubscribes in the same frame because provider$ instantly completes
      expectSubscriptions(provider$.subscriptions).toBe('---(^!)');
    });
  });

  // mostly covers PersistentDocumentTrackerSubject
  it('emits value from store first (if present) and stores value on each source emission', async () => {
    await firstValueFrom(store.set(mockTips.x));
    store.set = jest.fn().mockImplementation(store.set.bind(store));
    createTestScheduler().run(({ cold, expectObservable }) => {
      const syncStatus: Partial<SyncStatus> = { isSettled$: cold('---a---b|') };
      const provider$ = createStubObservable<Cardano.Tip>(
        cold('-y|', mockTips),
        cold('--a|', mockTips),
        cold('-ab|', mockTips)
      );
      const tracker$ = new TipTracker({
        connectionStatus$,
        logger,
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
      const provider$ = createStubObservable<Cardano.Tip>(
        cold('-a|', mockTips),
        cold('-b|', mockTips),
        cold('-c|', mockTips)
      );
      const tracker$ = new TipTracker({
        connectionStatus$,
        logger,
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

  it('syncStatus updates emitted only once connection is back up', () => {
    createTestScheduler().run(({ cold, hot, expectObservable }) => {
      const syncStatus: Partial<SyncStatus> = { isSettled$: cold('x-ba-|') };
      const connectionStatusMock$: Observable<ConnectionStatus> = hot('pd--p|', {
        d: ConnectionStatus.down,
        p: ConnectionStatus.up
      });
      const provider$ = createStubObservable<Cardano.Tip>(cold('x|', mockTips), cold('a|', mockTips));
      const tracker$ = new TipTracker({
        connectionStatus$: connectionStatusMock$,
        logger,
        maxPollInterval: Number.MAX_VALUE,
        minPollInterval: 0,
        provider$,
        store,
        syncStatus: syncStatus as SyncStatus
      });
      expectObservable(tracker$.asObservable()).toBe('x---a', mockTips);
    });
  });

  it('syncStatus timeout while connection is down does not emit tip updates', () => {
    createTestScheduler().run(({ cold, hot, expectObservable, expectSubscriptions }) => {
      const syncStatus: Partial<SyncStatus> = { isSettled$: hot('10ms |') };
      const connectionStatusMock$: Observable<ConnectionStatus> = hot('d--|', { d: ConnectionStatus.down });
      const provider$ = cold('x|', mockTips);
      const tracker$ = new TipTracker({
        connectionStatus$: connectionStatusMock$,
        logger,
        maxPollInterval: 6,
        minPollInterval: 0,
        provider$,
        store,
        syncStatus: syncStatus as SyncStatus
      });
      expectObservable(tracker$.asObservable()).toBe('');
      expectSubscriptions(provider$.subscriptions).toBe('');
    });
  });

  // The code is fairly simple, but quite a few additional tests are needed to test all paths
  it.todo('external trigger cancels an ongoing interval request and makes a new one');
  it.todo('external trigger cancels an ongoing external trigger request and makes a new one');
  it.todo('sync() calls external trigger');
});
