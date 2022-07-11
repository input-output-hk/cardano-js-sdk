import { Asset, Cardano } from '@cardano-sdk/core';
import { BalanceTracker } from './types';
import { Observable, forkJoin, map, mergeMap, of, tap } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackedAssetProvider } from './ProviderTracker';
import { coldObservableProvider } from './util';

export const createAssetService =
  (assetProvider: TrackedAssetProvider, retryBackoffConfig: RetryBackoffConfig) => (assetId: Cardano.AssetId) =>
    coldObservableProvider({
      provider: () => assetProvider.getAsset(assetId, { history: false, nftMetadata: true, tokenMetadata: true }),
      retryBackoffConfig,
      trigger$: of(true) // fetch only once
    });
export type AssetService = ReturnType<typeof createAssetService>;

export interface AssetsTrackerProps {
  balanceTracker: BalanceTracker;
  assetProvider: TrackedAssetProvider;
  retryBackoffConfig: RetryBackoffConfig;
}

interface AssetsTrackerInternals {
  assetService?: AssetService;
}

export const createAssetsTracker = (
  { assetProvider, balanceTracker, retryBackoffConfig }: AssetsTrackerProps,
  { assetService = createAssetService(assetProvider, retryBackoffConfig) }: AssetsTrackerInternals = {}
) =>
  new Observable<Map<Cardano.AssetId, Asset.AssetInfo>>((subscriber) => {
    let assetsMap = new Map<Cardano.AssetId, Asset.AssetInfo>();
    const sub = balanceTracker.utxo.total$
      .pipe(
        map(({ assets }) => [...(assets?.keys() || [])]),
        tap((assetIds) => assetIds.length === 0 && assetProvider.setStatInitialized(assetProvider.stats.getAsset$)),
        // Fetch asset metadata only for assets not already present in assetsMap
        map((assetIds) =>
          assetIds.map((assetId) => (assetsMap.has(assetId) ? of(assetsMap.get(assetId)) : assetService(assetId)))
        ),
        // Wait for all asset metadata fetches to complete
        mergeMap((assetInfos) => forkJoin(assetInfos)),
        map((assetInfos) => new Map(assetInfos.map((assetInfo) => [assetInfo!.assetId, assetInfo!]))),
        tap((v) => (assetsMap = v))
      )
      .subscribe(subscriber);

    return () => {
      sub.unsubscribe();
    };
  });
