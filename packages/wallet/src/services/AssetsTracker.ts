import { Asset, Cardano } from '@cardano-sdk/core';
import { Assets } from '../types';
import { BalanceTracker, Milliseconds, TransactionsTracker } from './types';
import { Logger } from 'ts-log';
import {
  Observable,
  buffer,
  concat,
  connect,
  debounceTime,
  distinctUntilChanged,
  filter,
  firstValueFrom,
  map,
  of,
  share,
  switchMap,
  tap
} from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackedAssetProvider } from './ProviderTracker';
import { concatAndCombineLatest } from '@cardano-sdk/util-rxjs';
import { deepEquals, isNotNil } from '@cardano-sdk/util';
import { newTransactions$ } from './TransactionsTracker';
import { pollProvider } from './util';
import chunk from 'lodash/chunk.js';
import uniq from 'lodash/uniq.js';

const isAssetInfoComplete = (assetInfo: Asset.AssetInfo): boolean =>
  assetInfo.nftMetadata !== undefined && assetInfo.tokenMetadata !== undefined;
const isEveryAssetInfoComplete = (assetInfos: Asset.AssetInfo[]): boolean => assetInfos.every(isAssetInfoComplete);

/** Buffers the source Observable values emitted at the same time (within 1 ms) */
const bufferTick =
  <T>() =>
  (source$: Observable<T>) =>
    source$.pipe(connect((shared$) => shared$.pipe(buffer(shared$.pipe(debounceTime(1))))));

const ASSET_INFO_FETCH_CHUNK_SIZE = 100;
const ONE_DAY = 24 * 60 * 60 * 1000;
const ONE_WEEK = 7 * ONE_DAY;

const isInBalance = (assetId: Cardano.AssetId, balance: Cardano.Value): boolean =>
  balance.assets?.has(assetId) ?? false;

/**
 * Splits a list of asset IDs into cached and uncached groups based on their presence in the cache,
 * their freshness, and their balance status:
 *
 * 1. Assets not in Balance:
 *    - Always use the cached version if present in the cache, ignoring freshness.
 * 2. Assets in Balance:
 *    - Use the cached version only if it exists and its `staleAt` timestamp did not expire.
 * 3. Uncached Assets:
 *    - If an asset is not in the cache or does not meet the above criteria, mark it as uncached.
 */
const splitCachedAndUncachedAssets = (
  cache: Assets,
  balance: Cardano.Value,
  assetIds: Cardano.AssetId[]
): { cachedAssets: Assets; uncachedAssetIds: Cardano.AssetId[] } => {
  const cachedAssets: Assets = new Map();
  const uncachedAssetIds: Cardano.AssetId[] = [];
  const now = new Date();

  for (const id of assetIds) {
    const cachedAssetInfo = cache.get(id);

    if (!cachedAssetInfo) {
      uncachedAssetIds.push(id);
      continue;
    }

    const { staleAt } = cachedAssetInfo;

    const expired = !staleAt || new Date(staleAt) < now;

    const mustFetch = !isAssetInfoComplete(cachedAssetInfo) || (isInBalance(id, balance) && expired);

    if (mustFetch) {
      uncachedAssetIds.push(id);
    } else {
      cachedAssets.set(id, cachedAssetInfo);
    }
  }

  return { cachedAssets, uncachedAssetIds };
};

const getAssetsWithCache = async (
  assetIdsChunk: Cardano.AssetId[],
  assetCache$: Observable<Assets>,
  totalBalance$: Observable<Cardano.Value>,
  assetProvider: TrackedAssetProvider,
  maxAssetInfoCacheAge: Milliseconds
): Promise<Asset.AssetInfo[]> => {
  const [cache, totalValue] = await Promise.all([firstValueFrom(assetCache$), firstValueFrom(totalBalance$)]);

  const { cachedAssets, uncachedAssetIds } = splitCachedAndUncachedAssets(cache, totalValue, assetIdsChunk);

  if (uncachedAssetIds.length === 0) {
    // If all assets are cached we wont perform any fetches from assetProvider, but still need to
    // mark it as initialized.
    if (!assetProvider.stats.getAsset$.value.initialized) {
      assetProvider.setStatInitialized(assetProvider.stats.getAsset$);
    }

    return [...cachedAssets.values()];
  }

  const fetchedAssets = await assetProvider.getAssets({
    assetIds: uncachedAssetIds,
    extraData: { nftMetadata: true, tokenMetadata: true }
  });

  const now = Date.now();
  const updatedFetchedAssets = fetchedAssets.map((asset) => {
    const randomDelta = Math.floor(Math.random() * 2 * ONE_DAY); // Random time between 0 and 2 days
    return {
      ...asset,
      staleAt: new Date(now + maxAssetInfoCacheAge + randomDelta)
    };
  });

  return [...cachedAssets.values(), ...updatedFetchedAssets];
};

export const createAssetService =
  (
    assetProvider: TrackedAssetProvider,
    assetCache$: Observable<Assets>,
    totalBalance$: Observable<Cardano.Value>,
    retryBackoffConfig: RetryBackoffConfig,
    logger: Logger,
    maxAssetInfoCacheAge: Milliseconds = ONE_WEEK
    // eslint-disable-next-line max-params
  ) =>
  (assetIds: Cardano.AssetId[]) =>
    concatAndCombineLatest(
      chunk(assetIds, ASSET_INFO_FETCH_CHUNK_SIZE).map((assetIdsChunk) =>
        pollProvider({
          logger,
          pollUntil: isEveryAssetInfoComplete,
          retryBackoffConfig,
          sample: () =>
            getAssetsWithCache(assetIdsChunk, assetCache$, totalBalance$, assetProvider, maxAssetInfoCacheAge),
          trigger$: of(true) // fetch only once
        })
      )
    ).pipe(map((arr) => arr.flat())); // Concatenate the chunk results

export type AssetService = ReturnType<typeof createAssetService>;

export interface AssetsTrackerProps {
  transactionsTracker: TransactionsTracker;
  assetProvider: TrackedAssetProvider;
  retryBackoffConfig: RetryBackoffConfig;
  logger: Logger;
  assetsCache$: Observable<Assets>;
  balanceTracker: BalanceTracker;
  maxAssetInfoCacheAge?: Milliseconds;
}

interface AssetsTrackerInternals {
  assetService?: AssetService;
}

const uniqueAssetIds = ({ body: { outputs } }: Cardano.OnChainTx) =>
  outputs.flatMap(({ value: { assets } }) => (assets ? [...assets.keys()] : []));
const flatUniqueAssetIds = (txes: Cardano.OnChainTx[]) => uniq(txes.flatMap(uniqueAssetIds));

export const createAssetsTracker = (
  {
    assetProvider,
    assetsCache$,
    transactionsTracker: { history$ },
    balanceTracker: {
      utxo: { total$ }
    },
    retryBackoffConfig,
    logger,
    maxAssetInfoCacheAge
  }: AssetsTrackerProps,
  {
    assetService = createAssetService(
      assetProvider,
      assetsCache$,
      total$,
      retryBackoffConfig,
      logger,
      maxAssetInfoCacheAge
    )
  }: AssetsTrackerInternals = {}
) =>
  new Observable<Map<Cardano.AssetId, Asset.AssetInfo>>((subscriber) => {
    let fetchedAssetInfoMap = new Map<Cardano.AssetId, Asset.AssetInfo>();
    const allAssetIds = new Set<Cardano.AssetId>();
    const sharedHistory$ = history$.pipe(share());
    return concat(
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
