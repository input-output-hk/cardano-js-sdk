import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, NetworkInfoProviderStats, ProviderFnStats, TrackedNetworkInfoProvider } from '../../../src';
import { NetworkInfoProvider } from '@cardano-sdk/core';
import { mockNetworkInfoProvider } from '../../mocks';

describe('TrackedNetworkInfoProvider', () => {
  let networkInfoProvider: NetworkInfoProvider;
  let trackedNetworkInfoProvider: TrackedNetworkInfoProvider;
  beforeEach(() => {
    networkInfoProvider = mockNetworkInfoProvider();
    trackedNetworkInfoProvider = new TrackedNetworkInfoProvider(networkInfoProvider);
  });

  describe('wraps underlying provider functions, tracks # of calls/responses and resets on stats.reset()', () => {
    const testFunctionStats =
      <T>(
        call: (networkInfoProvider: NetworkInfoProvider) => Promise<T>,
        selectStats: (stats: NetworkInfoProviderStats) => BehaviorSubject<ProviderFnStats>
        // eslint-disable-next-line unicorn/consistent-function-scoping
      ) =>
      async () => {
        const stats$ = selectStats(trackedNetworkInfoProvider.stats);
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        const result = call(trackedNetworkInfoProvider);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, numCalls: 1 });
        await result;
        expect(stats$.value).toEqual({
          didLastRequestFail: false,
          initialized: true,
          numCalls: 1,
          numFailures: 0,
          numResponses: 1
        });
        trackedNetworkInfoProvider.stats.reset();
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        trackedNetworkInfoProvider.setStatInitialized(stats$);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, initialized: true });
      };

    test(
      'networkInfo',
      testFunctionStats(
        (provider) => provider.networkInfo(),
        (stats) => stats.networkInfo$
      )
    );
  });
});
