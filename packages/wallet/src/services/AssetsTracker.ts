import { Asset, Cardano } from '@cardano-sdk/core';
import { BalanceTracker } from './types';
import { Logger } from 'ts-log';
import { Observable, combineLatest, map, mergeMap, of, tap } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackedAssetProvider } from './ProviderTracker';
import { coldObservableProvider } from './util';

const isAssetInfoComplete = (assetInfo: Asset.AssetInfo): boolean =>
  assetInfo.nftMetadata !== undefined && assetInfo.tokenMetadata !== undefined;

export const createAssetService =
  (assetProvider: TrackedAssetProvider, retryBackoffConfig: RetryBackoffConfig) => (assetId: Cardano.AssetId) =>
    coldObservableProvider({
      pollUntil: isAssetInfoComplete,
      provider: () =>
        assetProvider.getAsset({ assetId, extraData: { history: false, nftMetadata: true, tokenMetadata: true } }),
      retryBackoffConfig,
      trigger$: of(true) // fetch only once
    });
export type AssetService = ReturnType<typeof createAssetService>;

export interface AssetsTrackerProps {
  balanceTracker: BalanceTracker;
  assetProvider: TrackedAssetProvider;
  retryBackoffConfig: RetryBackoffConfig;
  logger: Logger;
}

interface AssetsTrackerInternals {
  assetService?: AssetService;
}

export const createAssetsTracker = (
  { assetProvider, balanceTracker, retryBackoffConfig, logger }: AssetsTrackerProps,
  { assetService = createAssetService(assetProvider, retryBackoffConfig) }: AssetsTrackerInternals = {}
) =>
  new Observable<Map<Cardano.AssetId, Asset.AssetInfo>>((subscriber) => {
    let assetsMap = new Map<Cardano.AssetId, Asset.AssetInfo>();
    const sub = balanceTracker.utxo.total$
      .pipe(
        map(({ assets }) => [...(assets?.keys() || [])]),
        tap((assetIds) =>
          logger.debug(
            assetIds.length > 0
              ? `Balance total assets: ${assetIds.length}`
              : 'Setting assetProvider stats as initialized'
          )
        ),
        tap((assetIds) => assetIds.length === 0 && assetProvider.setStatInitialized(assetProvider.stats.getAsset$)),
        // Fetch asset metadata only for assets not already present in assetsMap
        map((assetIds) =>
          assetIds.map((assetId) => {
            const assetInfo = assetsMap.get(assetId);
            if (assetInfo && isAssetInfoComplete(assetInfo)) {
              return of(assetInfo);
            }
            logger.debug('Fetching asset data for', assetId);
            return assetService(assetId);
          })
        ),
        // Wait for all asset metadata fetches have a value
        mergeMap((assetInfos) => combineLatest(assetInfos)),
        tap((assetInfos) => logger.debug(`Got metadata for ${assetInfos.length} assets`)),
        map((assetInfos) => new Map(assetInfos.map((assetInfo) => [assetInfo!.assetId, assetInfo!]))),
        tap((v) => (assetsMap = v))
      )
      .subscribe(subscriber);

    return () => {
      sub.unsubscribe();
    };
  });
