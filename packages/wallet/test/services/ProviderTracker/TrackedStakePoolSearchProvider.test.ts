import { BehaviorSubject } from 'rxjs';
import {
  CLEAN_FN_STATS,
  ProviderFnStats,
  StakePoolSearchProviderStats,
  TrackedStakePoolSearchProvider
} from '../../../src';
import { StakePoolSearchProvider } from '@cardano-sdk/core';
import { createStubStakePoolSearchProvider } from '@cardano-sdk/util-dev';

describe('TrackedStakePoolSearchProvider', () => {
  let stakePoolSearchProvider: StakePoolSearchProvider;
  let trackedStakePoolSearchProvider: TrackedStakePoolSearchProvider;
  beforeEach(() => {
    stakePoolSearchProvider = createStubStakePoolSearchProvider();
    trackedStakePoolSearchProvider = new TrackedStakePoolSearchProvider(stakePoolSearchProvider);
  });

  describe('wraps underlying provider functions, tracks # of calls/responses and resets on stats.reset()', () => {
    const testFunctionStats =
      <T>(
        call: (stakePoolSearchProvider: StakePoolSearchProvider) => Promise<T>,
        selectStats: (stats: StakePoolSearchProviderStats) => BehaviorSubject<ProviderFnStats>
        // eslint-disable-next-line unicorn/consistent-function-scoping
      ) =>
      async () => {
        const stats$ = selectStats(trackedStakePoolSearchProvider.stats);
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        const result = call(trackedStakePoolSearchProvider);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, numCalls: 1 });
        await result;
        expect(stats$.value).toEqual({
          didLastRequestFail: false,
          initialized: true,
          numCalls: 1,
          numFailures: 0,
          numResponses: 1
        });
        trackedStakePoolSearchProvider.stats.reset();
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        trackedStakePoolSearchProvider.setStatInitialized(stats$);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, initialized: true });
      };

    test(
      'queryStakePools',
      testFunctionStats(
        (provider) => provider.queryStakePools({}),
        (stats) => stats.queryStakePools$
      )
    );
  });
});
