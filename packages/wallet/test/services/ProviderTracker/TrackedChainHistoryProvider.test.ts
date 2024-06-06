import { CLEAN_FN_STATS, TrackedChainHistoryProvider } from '../../../src/index.js';
import { mockProviders } from '@cardano-sdk/util-dev';
import type { BehaviorSubject } from 'rxjs';
import type { ChainHistoryProvider } from '@cardano-sdk/core';
import type { ChainHistoryProviderStats, ProviderFnStats } from '../../../src/index.js';

describe('TrackedChainHistoryProvider', () => {
  let chainHistoryProvider: mockProviders.ChainHistoryProviderStub;
  let trackedChainHistoryProvider: TrackedChainHistoryProvider;
  beforeEach(() => {
    chainHistoryProvider = mockProviders.mockChainHistoryProvider();
    trackedChainHistoryProvider = new TrackedChainHistoryProvider(chainHistoryProvider);
  });

  test('CLEAN_FN_STATS all stats are 0', () => {
    expect(CLEAN_FN_STATS).toEqual({ numCalls: 0, numFailures: 0, numResponses: 0 });
  });

  describe('wraps underlying provider functions, tracks # of calls/responses and resets on stats.reset()', () => {
    const testFunctionStats =
      <T>(
        call: (chainHistoryProvider: ChainHistoryProvider) => Promise<T>,
        selectStats: (stats: ChainHistoryProviderStats) => BehaviorSubject<ProviderFnStats>,
        selectFn: (mockChainHistoryProvider: mockProviders.ChainHistoryProviderStub) => jest.Mock
        // eslint-disable-next-line unicorn/consistent-function-scoping
      ) =>
      async () => {
        const stats$ = selectStats(trackedChainHistoryProvider.stats);
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        const result = call(trackedChainHistoryProvider);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, numCalls: 1 });
        await result;
        const statsAfterResponse = {
          didLastRequestFail: false,
          initialized: true,
          numCalls: 1,
          numFailures: 0,
          numResponses: 1
        };
        expect(stats$.value).toEqual(statsAfterResponse);
        selectFn(chainHistoryProvider).mockRejectedValueOnce(new Error('any error'));
        const failure = call(trackedChainHistoryProvider).catch(() => void 0);
        const statsAfterFailureCall = {
          ...statsAfterResponse,
          numCalls: statsAfterResponse.numCalls + 1
        };
        expect(stats$.value).toEqual(statsAfterFailureCall);
        await failure;
        expect(stats$.value).toEqual({
          ...statsAfterFailureCall,
          didLastRequestFail: true,
          numFailures: 1
        });
        trackedChainHistoryProvider.stats.reset();
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        trackedChainHistoryProvider.setStatInitialized(stats$);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, initialized: true });
      };

    test(
      'blocksByHashes',
      testFunctionStats(
        (provider) => provider.blocksByHashes({ ids: [] }),
        (stats) => stats.blocksByHashes$,
        (mock) => mock.blocksByHashes
      )
    );

    test(
      'healthCheck',
      testFunctionStats(
        (provider) => provider.healthCheck(),
        (stats) => stats.healthCheck$,
        (mock) => mock.healthCheck
      )
    );

    test(
      'transactionsByAddresses',
      testFunctionStats(
        (provider) => provider.transactionsByAddresses({ addresses: [], pagination: { limit: 25, startAt: 0 } }),
        (stats) => stats.transactionsByAddresses$,
        (mock) => mock.transactionsByAddresses
      )
    );

    test(
      'transactionsByHashes',
      testFunctionStats(
        (provider) => provider.transactionsByHashes({ ids: [] }),
        (stats) => stats.transactionsByHashes$,
        (mock) => mock.transactionsByHashes
      )
    );
  });
});
