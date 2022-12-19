/* eslint-disable max-len */
import { Asset, Cardano } from '@cardano-sdk/core';
import { BalanceTracker } from './types';
import { Logger } from 'ts-log';
import { Observable, combineLatest, distinctUntilChanged, map, mergeMap, of, tap } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackedAssetProvider } from './ProviderTracker';
import { coldObservableProvider } from './util';
import { deepEquals } from '@cardano-sdk/util';

const isAssetInfoComplete = (assetInfo: Asset.AssetInfo): boolean =>
  assetInfo.nftMetadata !== undefined && assetInfo.tokenMetadata !== undefined;

export const createAssetService =
  (
    assetProvider: TrackedAssetProvider,
    retryBackoffConfig: RetryBackoffConfig,
    onFatalError?: (value: unknown) => void
  ) =>
  (assetId: Cardano.AssetId) =>
    coldObservableProvider({
      onFatalError,
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
  onFatalError?: (value: unknown) => void;
}

interface AssetsTrackerInternals {
  assetService?: AssetService;
}

export const createAssetsTracker = (
  { assetProvider, balanceTracker, retryBackoffConfig, logger, onFatalError }: AssetsTrackerProps,
  { assetService = createAssetService(assetProvider, retryBackoffConfig, onFatalError) }: AssetsTrackerInternals = {}
) =>
  new Observable<Map<Cardano.AssetId, Asset.AssetInfo>>((subscriber) => {
    let assetsMap = new Map<Cardano.AssetId, Asset.AssetInfo>();
    const sub = balanceTracker.utxo.total$
      .pipe(
        map(({ assets }) => [...(assets?.keys() || [])]),
        distinctUntilChanged(deepEquals), // It optimizes to not process duplicate emissions of the assets
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
        // If there are assets -> wait for all asset metadata fetches have a value, otherwise emit an empty array observable
        mergeMap((assetInfos) => {
          if (assetInfos.length === 0) return of([]);
          return combineLatest(assetInfos);
        }),
        tap((assetInfos) => logger.debug(`Got metadata for ${assetInfos.length} assets`)),
        map((assetInfos) => new Map(assetInfos.map((assetInfo) => [assetInfo!.assetId, assetInfo!]))),
        tap((v) => (assetsMap = v))
      )
      .subscribe(subscriber);

    return () => {
      sub.unsubscribe();
    };
  });
