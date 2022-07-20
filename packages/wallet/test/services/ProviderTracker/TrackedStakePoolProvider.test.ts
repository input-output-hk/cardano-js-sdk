import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, StakePoolProviderStats, TrackedStakePoolProvider } from '../../../src';
import { StakePoolProvider } from '@cardano-sdk/core';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';

describe('TrackedStakePoolProvider', () => {
  let stakePoolProvider: StakePoolProvider;
  let trackedStakePoolProvider: TrackedStakePoolProvider;
  beforeEach(() => {
    stakePoolProvider = createStubStakePoolProvider();
    trackedStakePoolProvider = new TrackedStakePoolProvider(stakePoolProvider);
  });

  describe('wraps underlying provider functions, tracks # of calls/responses and resets on stats.reset()', () => {
    const testFunctionStats =
      <T>(
        call: (stakePoolProvider: StakePoolProvider) => Promise<T>,
        selectStats: (stats: StakePoolProviderStats) => BehaviorSubject<ProviderFnStats>
        // eslint-disable-next-line unicorn/consistent-function-scoping
      ) =>
      async () => {
        const stats$ = selectStats(trackedStakePoolProvider.stats);
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        const result = call(trackedStakePoolProvider);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, numCalls: 1 });
        await result;
        expect(stats$.value).toEqual({
          didLastRequestFail: false,
          initialized: true,
          numCalls: 1,
          numFailures: 0,
          numResponses: 1
        });
        trackedStakePoolProvider.stats.reset();
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        trackedStakePoolProvider.setStatInitialized(stats$);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, initialized: true });
      };

    test(
      'healthCheck',
      testFunctionStats(
        (provider) => provider.healthCheck(),
        (stats) => stats.healthCheck$
      )
    );

    test(
      'queryStakePools',
      testFunctionStats(
        (provider) => provider.queryStakePools({}),
        (stats) => stats.queryStakePools$
      )
    );

    test(
      'stakePoolStats',
      testFunctionStats(
        (provider) => provider.stakePoolStats(),
        (stats) => stats.stakePoolStats$
      )
    );
  });
});
