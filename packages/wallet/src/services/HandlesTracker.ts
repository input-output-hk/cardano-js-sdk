import { Assets, HandleInfo } from '../types';
import { Cardano, Handle, HandleProvider } from '@cardano-sdk/core';
import {
  EMPTY,
  Observable,
  catchError,
  combineLatest,
  concatMap,
  defer,
  distinctUntilChanged,
  from,
  map,
  mergeMap,
  of,
  shareReplay,
  startWith,
  tap,
  toArray,
  withLatestFrom
} from 'rxjs';
import { Logger } from 'ts-log';
import { deepEquals, isNotNil, sameArrayItems, strictEquals } from '@cardano-sdk/util';
import { passthrough } from '@cardano-sdk/util-rxjs';
import { retryBackoff } from 'backoff-rxjs';
import uniqBy from 'lodash/uniqBy';

export const HYDRATE_HANDLE_INITIAL_INTERVAL = 50;
export const HYDRATE_HANDLE_MAX_RETRIES = 5;

export interface HandlesTrackerProps {
  utxo$: Observable<Cardano.Utxo[]>;
  assetInfo$: Observable<Assets>;
  tip$: Observable<Cardano.Tip>;
  handlePolicyIds: Cardano.PolicyId[];
  logger: Logger;
  handleProvider: HandleProvider;
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
        profilePic: resolution?.profilePic
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
              ? of(hydratedHandles[handleInfo.handle] as HandleInfo)
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

export const createHandlesTracker = ({
  tip$,
  assetInfo$,
  handlePolicyIds,
  handleProvider,
  hydrateHandle = hydrateHandleAsync,
  logger,
  utxo$
}: HandlesTrackerProps) =>
  combineLatest([
    utxo$.pipe(
      map((utxo) =>
        utxo.flatMap(([_, txOut]) =>
          uniqBy(
            [...(txOut.value.assets?.keys() || [])]
              .filter((assetId) => handlePolicyIds.some((policyId) => assetId.startsWith(policyId)))
              .map((assetId) => ({
                handleAssetId: assetId,
                txOut
              })),
            ({ handleAssetId }) => handleAssetId
          )
        )
      ),
      distinctUntilChanged((a, b) => sameArrayItems(a, b, strictEquals)),
      withLatestFrom(tip$)
    ),
    assetInfo$
  ]).pipe(
    mergeMap(([[utxo, tip], assets]) => {
      const handlesWithAssetInfo = utxo
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
            hasDatum: !!txOut.datum,
            resolvedAt: tip
          };
        })
        .filter(isNotNil);
      if (utxo.length > 0 && handlesWithAssetInfo.length === 0) {
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
