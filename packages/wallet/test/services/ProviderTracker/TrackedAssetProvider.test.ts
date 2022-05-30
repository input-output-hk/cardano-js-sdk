import { AssetProvider, Cardano } from '@cardano-sdk/core';
import { AssetProviderStats, CLEAN_FN_STATS, ProviderFnStats, TrackedAssetProvider } from '../../../src';
import { BehaviorSubject } from 'rxjs';
import { mockAssetProvider } from '../../mocks';

describe('TrackedAssetProvider', () => {
  let assetProvider: AssetProvider;
  let trackedAssetProvider: TrackedAssetProvider;

  beforeEach(() => {
    assetProvider = mockAssetProvider();
    trackedAssetProvider = new TrackedAssetProvider(assetProvider);
  });

  describe('wraps underlying provider functions, tracks # of calls/responses and resets on stats.reset()', () => {
    const assetId = Cardano.AssetId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e');
    const extraData = {
      history: false
    };

    const testFunctionStats =
      <T>(
        call: (assetProvider: AssetProvider) => Promise<T>,
        selectStats: (stats: AssetProviderStats) => BehaviorSubject<ProviderFnStats>,
        assertExtra?: () => void
        // eslint-disable-next-line unicorn/consistent-function-scoping
      ) =>
      async () => {
        const stats$ = selectStats(trackedAssetProvider.stats);
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        const result = call(trackedAssetProvider);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, numCalls: 1 });
        await result;
        expect(stats$.value).toEqual({
          didLastRequestFail: false,
          initialized: true,
          numCalls: 1,
          numFailures: 0,
          numResponses: 1
        });
        trackedAssetProvider.stats.reset();
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        trackedAssetProvider.setStatInitialized(stats$);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, initialized: true });
        assertExtra?.();
      };

    test(
      'getAsset',
      testFunctionStats(
        (provider) => provider.getAsset(assetId, extraData),
        (stats) => stats.getAsset$,
        () => expect(assetProvider.getAsset).toBeCalledWith(assetId, extraData)
      )
    );
  });
});
