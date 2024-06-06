import { CLEAN_FN_STATS, TrackedRewardsProvider } from '../../../src/index.js';
import { mockProviders } from '@cardano-sdk/util-dev';
import type { BehaviorSubject } from 'rxjs';
import type { ProviderFnStats, RewardsProviderStats } from '../../../src/index.js';
import type { RewardsProvider } from '@cardano-sdk/core';

const { mockRewardsProvider, rewardAccount } = mockProviders;

describe('TrackedRewardsProvider', () => {
  let rewardsProvider: mockProviders.RewardsProviderStub;
  let trackedRewardsProvider: TrackedRewardsProvider;
  beforeEach(() => {
    rewardsProvider = mockRewardsProvider();
    trackedRewardsProvider = new TrackedRewardsProvider(rewardsProvider);
  });

  describe.skip('wraps underlying provider functions, tracks # of calls/responses and resets on stats.reset()', () => {
    const testFunctionStats =
      <T>(
        call: (rewardsProvider: RewardsProvider) => Promise<T>,
        selectStats: (stats: RewardsProviderStats) => BehaviorSubject<ProviderFnStats>,
        selectFn: (mockRewardsProvider: mockProviders.RewardsProviderStub) => jest.Mock
        // eslint-disable-next-line unicorn/consistent-function-scoping
      ) =>
      async () => {
        const stats$ = selectStats(trackedRewardsProvider.stats);
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        const result = call(trackedRewardsProvider);
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
        selectFn(rewardsProvider).mockRejectedValueOnce(new Error('any error'));
        const failure = call(trackedRewardsProvider).catch(() => void 0);
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
        trackedRewardsProvider.stats.reset();
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        trackedRewardsProvider.setStatInitialized(stats$);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, initialized: true });
      };

    test(
      'healthCheck',
      testFunctionStats(
        (rp) => rp.healthCheck(),
        (stats) => stats.healthCheck$,
        (mockRP) => mockRP.healthCheck
      )
    );

    test(
      'rewards',
      testFunctionStats(
        (rp) => rp.rewardAccountBalance({ rewardAccount }),
        (stats) => stats.rewardAccountBalance$,
        (mockRP) => mockRP.rewardAccountBalance
      )
    );

    test(
      'rewardsHistory',
      testFunctionStats(
        (rp) => rp.rewardsHistory({ rewardAccounts: [] }),
        (stats) => stats.rewardsHistory$,
        (mockRP) => mockRP.rewardsHistory
      )
    );
  });
});
