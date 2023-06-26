import { Asset, Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Observable, combineLatest, distinctUntilChanged, map, of, switchMap, tap } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackedAssetProvider } from './ProviderTracker';
import { TransactionsTracker } from './types';
import { coldObservableProvider, concatAndCombineLatest } from '@cardano-sdk/util-rxjs';
import { deepEquals } from '@cardano-sdk/util';
import chunk from 'lodash/chunk';
import uniq from 'lodash/uniq';

const isAssetInfoComplete = (assetInfos: Asset.AssetInfo[]): boolean =>
  assetInfos.every((assetInfo) => assetInfo.nftMetadata !== undefined && assetInfo.tokenMetadata !== undefined);

const ASSET_INFO_FETCH_CHUNK_SIZE = 100;
export const createAssetService =
  (
    assetProvider: TrackedAssetProvider,
    retryBackoffConfig: RetryBackoffConfig,
    onFatalError?: (value: unknown) => void
  ) =>
  (assetIds: Cardano.AssetId[]) =>
    concatAndCombineLatest(
      chunk(assetIds, ASSET_INFO_FETCH_CHUNK_SIZE).map((assetIdsChunk) =>
        coldObservableProvider({
          onFatalError,
          pollUntil: isAssetInfoComplete,
          provider: () =>
            assetProvider.getAssets({
              assetIds: assetIdsChunk,
              extraData: { nftMetadata: true, tokenMetadata: true }
            }),
          retryBackoffConfig,
          trigger$: of(true) // fetch only once
        })
      )
    ).pipe(map((arr) => arr.flat())); // concat the chunk results
export type AssetService = ReturnType<typeof createAssetService>;

export interface AssetsTrackerProps {
  transactionsTracker: TransactionsTracker;
  assetProvider: TrackedAssetProvider;
  retryBackoffConfig: RetryBackoffConfig;
  logger: Logger;
  onFatalError?: (value: unknown) => void;
}

interface AssetsTrackerInternals {
  assetService?: AssetService;
}

export const createAssetsTracker = (
  { assetProvider, transactionsTracker: { history$ }, retryBackoffConfig, logger, onFatalError }: AssetsTrackerProps,
  { assetService = createAssetService(assetProvider, retryBackoffConfig, onFatalError) }: AssetsTrackerInternals = {}
) =>
  new Observable<Map<Cardano.AssetId, Asset.AssetInfo>>((subscriber) => {
    let assetsMap = new Map<Cardano.AssetId, Asset.AssetInfo>();
    const sub = history$
      .pipe(
        map((historyTxs) =>
          uniq(
            historyTxs.flatMap(({ body: { outputs } }) =>
              outputs.flatMap(({ value: { assets } }) => (assets ? [...assets.keys()] : []))
            )
          )
        ),
        distinctUntilChanged(deepEquals), // It optimizes to not process duplicate emissions of the assets
        tap((assetIds) =>
          logger.debug(
            assetIds.length > 0
              ? `Historical total assets: ${assetIds.length}`
              : 'Setting assetProvider stats as initialized'
          )
        ),
        tap((assetIds) => assetIds.length === 0 && assetProvider.setStatInitialized(assetProvider.stats.getAsset$)),
        // Fetch asset metadata only for assets not already present in assetsMap
        // Restart inner observable if assetIds change, otherwise the whole pipe will hang waiting for all assetInfos to resolve
        switchMap((assetIds) => {
          const assetIdsToFetch = assetIds.filter((assetId) => {
            const assetInfo = assetsMap.get(assetId);
            return !assetInfo || !isAssetInfoComplete([assetInfo]);
          });
          const assetInfosCached$ = of([...assetsMap.values()]);
          const assetInfosFetched$ = assetIdsToFetch.length > 0 ? assetService(assetIdsToFetch) : of([]);

          return combineLatest([assetInfosCached$, assetInfosFetched$]).pipe(map((allInfos) => allInfos.flat()));
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
