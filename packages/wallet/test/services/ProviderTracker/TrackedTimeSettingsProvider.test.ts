import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, TimeSettingsProviderStats, TrackedTimeSettingsProvider } from '../../../src';
import { TimeSettingsProvider, testnetTimeSettings } from '@cardano-sdk/core';
import { createStubTimeSettingsProvider } from '@cardano-sdk/util-dev';

describe('TrackedTimeSettingsProvider', () => {
  let timeSettingsProvider: TimeSettingsProvider;
  let trackedTimeSettingsProvider: TrackedTimeSettingsProvider;
  beforeEach(() => {
    timeSettingsProvider = createStubTimeSettingsProvider(testnetTimeSettings);
    trackedTimeSettingsProvider = new TrackedTimeSettingsProvider(timeSettingsProvider);
  });

  describe('wraps underlying provider functions, tracks # of calls/responses and resets on stats.reset()', () => {
    const testFunctionStats =
      <T>(
        call: (timeSettingsProvider: TimeSettingsProvider) => Promise<T>,
        selectStats: (stats: TimeSettingsProviderStats) => BehaviorSubject<ProviderFnStats>
        // eslint-disable-next-line unicorn/consistent-function-scoping
      ) =>
      async () => {
        const stats$ = selectStats(trackedTimeSettingsProvider.stats);
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        const result = call(trackedTimeSettingsProvider);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, numCalls: 1 });
        await result;
        expect(stats$.value).toEqual({
          didLastRequestFail: false,
          initialized: true,
          numCalls: 1,
          numFailures: 0,
          numResponses: 1
        });
        trackedTimeSettingsProvider.stats.reset();
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        trackedTimeSettingsProvider.setStatInitialized(stats$);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, initialized: true });
      };

    test(
      'getTimeSettings',
      testFunctionStats(
        (provider) => provider.getTimeSettings(),
        (stats) => stats.getTimeSettings$
      )
    );
  });
});
