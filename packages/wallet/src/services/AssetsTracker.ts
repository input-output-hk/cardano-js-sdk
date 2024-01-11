import { Asset, Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import {
  Observable,
  buffer,
  concat,
  connect,
  debounceTime,
  distinctUntilChanged,
  filter,
  map,
  of,
  share,
  switchMap,
  take,
  tap
} from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackedAssetProvider } from './ProviderTracker';
import { TransactionsTracker } from './types';
import { coldObservableProvider, concatAndCombineLatest } from '@cardano-sdk/util-rxjs';
import { deepEquals, isNotNil } from '@cardano-sdk/util';
import { newTransactions$ } from './TransactionsTracker';
import chunk from 'lodash/chunk';
import uniq from 'lodash/uniq';

const isAssetInfoComplete = (assetInfo: Asset.AssetInfo): boolean =>
  assetInfo.nftMetadata !== undefined && assetInfo.tokenMetadata !== undefined;
const isEveryAssetInfoComplete = (assetInfos: Asset.AssetInfo[]): boolean => assetInfos.every(isAssetInfoComplete);

/** Buffers the source Observable values emitted at the same time (within 1 ms) */
const bufferTick =
  <T>() =>
  (source$: Observable<T>) =>
    source$.pipe(connect((shared$) => shared$.pipe(buffer(shared$.pipe(debounceTime(1))))));

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
          pollUntil: isEveryAssetInfoComplete,
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

const uniqueAssetIds = ({ body: { outputs } }: Cardano.OnChainTx) =>
  outputs.flatMap(({ value: { assets } }) => (assets ? [...assets.keys()] : []));
const flatUniqueAssetIds = (txes: Cardano.OnChainTx[]) => uniq(txes.flatMap(uniqueAssetIds));

export const createAssetsTracker = (
  { assetProvider, transactionsTracker: { history$ }, retryBackoffConfig, logger, onFatalError }: AssetsTrackerProps,
  { assetService = createAssetService(assetProvider, retryBackoffConfig, onFatalError) }: AssetsTrackerInternals = {}
) =>
  new Observable<Map<Cardano.AssetId, Asset.AssetInfo>>((subscriber) => {
    let fetchedAssetInfoMap = new Map<Cardano.AssetId, Asset.AssetInfo>();
    const allAssetIds = new Set<Cardano.AssetId>();
    const sharedHistory$ = history$.pipe(share());
    return concat(
      sharedHistory$.pipe(
        map((historyTxs) => uniq(historyTxs.flatMap(uniqueAssetIds))),
        tap((assetIds) =>
          logger.debug(
            assetIds.length > 0
              ? `Historical total assets: ${assetIds.length}`
              : 'Setting assetProvider stats as initialized'
          )
        ),
        tap((assetIds) => assetIds.length === 0 && assetProvider.setStatInitialized(assetProvider.stats.getAsset$)),
        take(1)
      ),
      newTransactions$(sharedHistory$).pipe(
        bufferTick(),
        map(flatUniqueAssetIds),
        map((assetIds) => {
          const newAssetIds = assetIds.filter((assetId) => !allAssetIds.has(assetId));
          // re-fetch all asset infos that either
          // - weren't fetched yet
          // - were fetched with incomplete metadata
          const assetIdsToRefetch = [...allAssetIds.values()].filter((assetId) => {
            const assetInfo = fetchedAssetInfoMap.get(assetId);
            return !assetInfo || !isAssetInfoComplete(assetInfo);
          });
          // When we see a CIP-68 reference NFT, it means metadata for a user NFT that we own might have changed
          const assetsWithCip68MetadataUpdates = assetIds
            .map((assetId) => {
              const assetName = Cardano.AssetId.getAssetName(assetId);
              const decoded = Asset.AssetNameLabel.decode(assetName);
              if (decoded?.label === Asset.AssetNameLabelNum.ReferenceNFT) {
                return Cardano.AssetId.fromParts(
                  Cardano.AssetId.getPolicyId(assetId),
                  Asset.AssetNameLabel.encode(decoded.content, Asset.AssetNameLabelNum.UserNFT)
                );
              }
            })
            .filter(isNotNil);
          return uniq([...newAssetIds, ...assetIdsToRefetch, ...assetsWithCip68MetadataUpdates]);
        }),
        filter((assetIds) => assetIds.length > 0)
      )
    )
      .pipe(
        tap((assetIds) => {
          for (const assetId of assetIds) {
            allAssetIds.add(assetId);
          }
        }),
        // Restart inner observable if there are new assets to be fetched,
        // otherwise the whole pipe will hang waiting for all assetInfos to resolve
        switchMap((assetIdsToFetch) => (assetIdsToFetch.length > 0 ? assetService(assetIdsToFetch) : of([]))),
        map((fetchedAssetInfos) => [...[...fetchedAssetInfoMap.values()].filter(isNotNil), ...fetchedAssetInfos]),
        distinctUntilChanged(deepEquals), // It optimizes to not process duplicate emissions of the assets
        tap((assetInfos) => logger.debug(`Got metadata for ${assetInfos.length} assets`)),
        map((assetInfos) => new Map(assetInfos.map((assetInfo) => [assetInfo.assetId, assetInfo]))),
        tap((v) => (fetchedAssetInfoMap = v))
      )
      .subscribe(subscriber);
  });
