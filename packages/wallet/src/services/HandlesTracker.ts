import { Asset, Cardano, Handle, HandleProvider } from '@cardano-sdk/core';
import { Assets, HandleInfo } from '../types';
import {
  EMPTY,
  Observable,
  catchError,
  combineLatest,
  concatMap,
  defer,
  distinctUntilChanged,
  from,
  mergeMap,
  of,
  shareReplay,
  startWith,
  tap,
  toArray
} from 'rxjs';
import { Logger } from 'ts-log';
import { deepEquals, isNotNil, sameArrayItems } from '@cardano-sdk/util';
import { passthrough } from '@cardano-sdk/util-rxjs';
import { retryBackoff } from 'backoff-rxjs';
import uniqBy from 'lodash/uniqBy.js';

export const HYDRATE_HANDLE_INITIAL_INTERVAL = 50;
export const HYDRATE_HANDLE_MAX_RETRIES = 5;

export interface HandlesTrackerProps {
  utxo$: Observable<Cardano.Utxo[]>;
  assetInfo$: Observable<Assets>;
  handlePolicyIds$: Observable<Cardano.PolicyId[]>;
  logger: Logger;
  handleProvider: HandleProvider;
}

interface HandlesTrackerInternals {
  hydrateHandle?: (
    handleProvider: HandleProvider,
    logger: Logger
  ) => (handles: HandleInfo) => Promise<HandleInfo> | Observable<HandleInfo>;
}

const handleInfoEquals = (a: HandleInfo, b: HandleInfo) =>
  a.assetId === b.assetId &&
  a.resolvedAt?.hash === b.resolvedAt?.hash &&
  deepEquals(a.tokenMetadata, b.tokenMetadata) &&
  deepEquals(a.nftMetadata, b.nftMetadata);

const isHydrated = (handleInfo: HandleInfo) =>
  'image' in handleInfo && 'backgroundImage' in handleInfo && 'profilePic' in handleInfo;

export const hydrateHandleAsync =
  (handleProvider: HandleProvider, logger: Logger) =>
  async (handle: HandleInfo): Promise<HandleInfo> => {
    logger.debug('hydrating handle', handle.handle);
    try {
      const [resolution] = await handleProvider.resolveHandles({ handles: [handle.handle] });
      return {
        ...handle,
        backgroundImage: resolution?.backgroundImage,
        image: resolution?.image,
        profilePic: resolution?.profilePic,
        resolvedAt: resolution?.resolvedAt
      };
    } catch (error) {
      logger.error("Couldn't hydrate handle", error);
      throw error;
    }
  };

export const hydrateHandles =
  (hydrateHandle: (handle: HandleInfo) => Promise<HandleInfo> | Observable<HandleInfo>) =>
  (evt$: Observable<HandleInfo[]>): Observable<HandleInfo[]> => {
    const hydratedHandles: Partial<Record<Handle, HandleInfo>> = {};
    return evt$.pipe(
      mergeMap((handles) =>
        from(handles).pipe(
          concatMap((handleInfo) =>
            handleInfo.handle in hydratedHandles
              ? of(hydratedHandles[handleInfo.handle]!)
              : defer(() => from(hydrateHandle(handleInfo))).pipe(
                  retryBackoff({
                    initialInterval: HYDRATE_HANDLE_INITIAL_INTERVAL,
                    maxRetries: HYDRATE_HANDLE_MAX_RETRIES,
                    resetOnSuccess: true
                  }),
                  catchError(() => of(handleInfo))
                )
          ),
          tap((handleInfo) => {
            if (isHydrated(handleInfo)) {
              hydratedHandles[handleInfo.handle] = handleInfo;
            }
          }),
          toArray(),
          handles.length > 0 ? startWith(handles) : passthrough()
        )
      )
    );
  };

export const createHandlesTracker = (
  { assetInfo$, handlePolicyIds$, handleProvider, logger, utxo$ }: HandlesTrackerProps,
  { hydrateHandle = hydrateHandleAsync }: HandlesTrackerInternals = {}
) =>
  combineLatest([handlePolicyIds$, utxo$, assetInfo$]).pipe(
    mergeMap(([handlePolicyIds, utxo, assets]) => {
      const filteredUtxo = utxo.flatMap(([_, txOut]) =>
        uniqBy(
          [...(txOut.value.assets?.keys() || [])]
            .filter((assetId) => {
              const matchPolicyId = handlePolicyIds.some((policyId) => assetId.startsWith(policyId));
              if (!matchPolicyId) {
                return false;
              }

              const assetName = Cardano.AssetId.getAssetName(assetId);
              const decoded = Asset.AssetNameLabel.decode(assetName);
              return !decoded || decoded.label === Asset.AssetNameLabelNum.UserNFT;
            })
            .map((assetId) => ({
              handleAssetId: assetId,
              txOut
            })),
          ({ handleAssetId }) => handleAssetId
        )
      );

      const handlesWithAssetInfo = filteredUtxo
        .map(({ handleAssetId, txOut }): HandleInfo | null => {
          const assetInfo = assets.get(handleAssetId);
          if (!assetInfo) {
            logger.debug(`Asset info not (yet?) found for ${handleAssetId}`);
            return null;
          }
          return {
            ...assetInfo,
            cardanoAddress: txOut.address,
            handle: Cardano.AssetId.getAssetNameAsText(handleAssetId),
            hasDatum: !!txOut.datum
          };
        })
        .filter(isNotNil);

      if (filteredUtxo.length > 0 && handlesWithAssetInfo.length === 0) {
        // AssetInfo is still resolving
        return EMPTY;
      }

      return of(
        handlesWithAssetInfo.filter(({ handle, supply }) => {
          if (supply > 1n) {
            logger.warn(`Omitting handle with supply >1: ${handle}`);
            return false;
          }
          return true;
        })
      );
    }),
    distinctUntilChanged((a, b) => sameArrayItems(a, b, handleInfoEquals)),
    hydrateHandles(hydrateHandle(handleProvider, logger)),
    shareReplay({ bufferSize: 1, refCount: true })
  );
