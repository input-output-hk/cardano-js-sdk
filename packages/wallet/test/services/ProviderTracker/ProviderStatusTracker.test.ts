/* eslint-disable prettier/prettier */
/* eslint-disable no-multi-spaces */
import {
  CLEAN_FN_STATS,
  ProviderFnStats,
  TrackedAssetProvider,
  TrackedChainHistoryProvider,
  TrackedRewardsProvider,
  TrackedStakePoolProvider,
  TrackedUtxoProvider,
  TrackedWalletNetworkInfoProvider,
  createProviderStatusTracker
} from '../../../src';
import { createStubStakePoolProvider, createTestScheduler, mockProviders } from '@cardano-sdk/util-dev';
import { dummyLogger } from 'ts-log';

const {
  mockAssetProvider,
  mockChainHistoryProvider,
  mockNetworkInfoProvider,
  mockRewardsProvider,
  mockUtxoProvider
} = mockProviders;

const providerFnStats = {
  a: [CLEAN_FN_STATS, CLEAN_FN_STATS], // Initial state
  b: [{ initialized: true, numCalls: 1, numFailures: 0, numResponses: 0 }, CLEAN_FN_STATS], // One provider fn called
  c: [
    // One provider fn resolved
    { initialized: true, numCalls: 1, numFailures: 0, numResponses: 1 },
    CLEAN_FN_STATS
  ],
  d: [
    // One provider fn called, one resolved
    { initialized: true, numCalls: 1, numFailures: 0, numResponses: 1 },
    { initialized: true, numCalls: 1, numFailures: 0, numResponses: 0 }
  ],
  e: [
    { initialized: true, numCalls: 1, numFailures: 0, numResponses: 1 }, // Both provider fns resolved
    { initialized: true, numCalls: 1, numFailures: 0, numResponses: 1 }
  ],
  f: [
    // Both provider fns called again
    { initialized: true, numCalls: 2, numFailures: 0, numResponses: 1 },
    { initialized: true, numCalls: 2, numFailures: 0, numResponses: 1 }
  ],
  g: [
    // One provider fn resolved, one failed
    { didLastRequestFail: true, initialized: true, numCalls: 2, numFailures: 1, numResponses: 1 },
    { initialized: true, numCalls: 2, numFailures: 0, numResponses: 2 }
  ],
  h: [
    // Failed request fn called again
    { didLastRequestFail: true, initialized: true, numCalls: 3, numFailures: 1, numResponses: 1 },
    { initialized: true, numCalls: 2, numFailures: 0, numResponses: 2 }
  ],
  i: [
    // Failed request fn resolved
    { didLastRequestFail: false, initialized: true, numCalls: 3, numFailures: 1, numResponses: 2 },
    { initialized: true, numCalls: 2, numFailures: 0, numResponses: 2 }
  ]
};

describe('createProviderStatusTracker', () => {
  let stakePoolProvider: TrackedStakePoolProvider;
  let networkInfoProvider: TrackedWalletNetworkInfoProvider;
  let assetProvider: TrackedAssetProvider;
  let utxoProvider: TrackedUtxoProvider;
  let chainHistoryProvider: TrackedChainHistoryProvider;
  let rewardsProvider: TrackedRewardsProvider;

  const timeout = 5000;

  beforeEach(() => {
    utxoProvider = new TrackedUtxoProvider(mockUtxoProvider());
    stakePoolProvider = new TrackedStakePoolProvider(createStubStakePoolProvider());
    networkInfoProvider = new TrackedWalletNetworkInfoProvider(mockNetworkInfoProvider());
    assetProvider = new TrackedAssetProvider(mockAssetProvider());
    chainHistoryProvider = new TrackedChainHistoryProvider(mockChainHistoryProvider());
    rewardsProvider = new TrackedRewardsProvider(mockRewardsProvider());
  });

  // n - not pending
  // p - pending
  it('isAnyRequestPending$: true if there are any reqs in flight, false when all resolved', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const source = 'ab-c-d-e-f-g-h-i';
      const status = '-p--np--np------n';
      const getProviderSyncRelevantStats = jest
        .fn()
        .mockReturnValueOnce(cold<ProviderFnStats[]>(source, providerFnStats));
      const tracker = createProviderStatusTracker(
        {
          assetProvider,
          chainHistoryProvider,
          logger: dummyLogger,
          networkInfoProvider,
          rewardsProvider,
          stakePoolProvider,
          utxoProvider
        },
        { consideredOutOfSyncAfter: timeout },
        { getProviderSyncRelevantStats }
      );
      // debounced by 1
      expectObservable(tracker.isAnyRequestPending$).toBe(status, {
        n: false,
        p: true
      });
    });
  });

  it.each([
    { descr: 'not-pending is debounced', expected: '---n|', source: 'aaa-|' },
    { descr: 'pending are not debounced', expected: 'p--|', source: 'bbb|' },
    { descr: 'not-pending are dropped because they were debounced, pending is emitted immediately', expected: '--p|', source: 'aab|' },
    { descr: 'flipping pending status shows pending, then waits for the first not-pending debounce to expire', expected: 'p-----n|', source: 'bababa-|' }
  ])('isAnyRequestPending$: %s', ({ descr, source, expected }) => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const getProviderSyncRelevantStats = jest
        .fn()
        .mockReturnValueOnce(cold<ProviderFnStats[]>(source, providerFnStats));

        const tracker = createProviderStatusTracker(
          {
            assetProvider,
            chainHistoryProvider,
            logger: dummyLogger,
            networkInfoProvider,
            rewardsProvider,
            stakePoolProvider,
            utxoProvider
          },
          { consideredOutOfSyncAfter: timeout },
          { getProviderSyncRelevantStats }
        );

        expectObservable(tracker.isAnyRequestPending$).toBe(expected, {
          n: false,
          p: true
        }, descr);
    });
  });

  it('isSettled$: false on load, true when all requests are resolved, then reverse of isAnyRequestPending', async () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const source = '-a-b-c-d-e-f-g-h-i';
      const settle = 'a---------ef------i';
      const getProviderSyncRelevantStats = jest
        .fn()
        .mockReturnValueOnce(cold<ProviderFnStats[]>(source, providerFnStats));
      const tracker = createProviderStatusTracker(
        {
          assetProvider,
          chainHistoryProvider,
          logger: dummyLogger,
          networkInfoProvider,
          rewardsProvider,
          stakePoolProvider,
          utxoProvider
        },
        { consideredOutOfSyncAfter: timeout },
        { getProviderSyncRelevantStats }
      );
      // debounced by 1
      expectObservable(tracker.isSettled$).toBe(settle, {
        a: false,
        e: true,
        f: false,
        i: true
      });
    });
  });

  it('isUpToDate$: false on load, true when all requests are resolved, then false on timeout', async () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const getProviderSyncRelevantStats = jest
        .fn()
        .mockReturnValueOnce(cold<ProviderFnStats[]>(`-a-b-c-d-e-f ${timeout}ms g-h-i`, providerFnStats));
      const tracker = createProviderStatusTracker(
        {
          assetProvider,
          chainHistoryProvider,
          logger: dummyLogger,
          networkInfoProvider,
          rewardsProvider,
          stakePoolProvider,
          utxoProvider
        },
        { consideredOutOfSyncAfter: timeout },
        { getProviderSyncRelevantStats }
      );
      // debounced by 1
      expectObservable(tracker.isUpToDate$, `^ ${timeout * 2}ms !`).toBe(`a---------e ${timeout - 1}ms f------g`, {
        a: false,
        e: true,
        f: false,
        g: true
      });
    });
  });

  it('shutdown() completes all observables', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const getProviderSyncRelevantStats = jest
        .fn()
        .mockReturnValueOnce(cold<ProviderFnStats[]>(`-a-b-c-d-e-f ${timeout}ms g-h-i`, providerFnStats));
      const tracker = createProviderStatusTracker(
        {
          assetProvider,
          chainHistoryProvider,
          logger: dummyLogger,
          networkInfoProvider,
          rewardsProvider,
          stakePoolProvider,
          utxoProvider
        },
        { consideredOutOfSyncAfter: timeout },
        { getProviderSyncRelevantStats }
      );
      tracker.shutdown();
      expectObservable(tracker.isUpToDate$).toBe('(a|)', { a: false });
      expectObservable(tracker.isSettled$).toBe('(a|)', { a: false });
      expectObservable(tracker.isAnyRequestPending$).toBe('|');
    });
  });
});
