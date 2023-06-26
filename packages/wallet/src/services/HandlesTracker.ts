import { Assets, HandleInfo } from '../types';
import { Cardano } from '@cardano-sdk/core';
import {
  EMPTY,
  Observable,
  combineLatest,
  distinctUntilChanged,
  map,
  mergeMap,
  of,
  shareReplay,
  withLatestFrom
} from 'rxjs';
import { Logger } from 'ts-log';
import { deepEquals, isNotNil } from '@cardano-sdk/util';
import { sameArrayItems, strictEquals } from './util';
import uniqBy from 'lodash/uniqBy';

export interface HandlesTrackerProps {
  utxo$: Observable<Cardano.Utxo[]>;
  assetInfo$: Observable<Assets>;
  tip$: Observable<Cardano.Tip>;
  handlePolicyIds: Cardano.PolicyId[];
  logger: Logger;
}

const handleInfoEquals = (a: HandleInfo, b: HandleInfo) =>
  a.assetId === b.assetId &&
  a.resolvedAt?.hash === b.resolvedAt?.hash &&
  deepEquals(a.tokenMetadata, b.tokenMetadata) &&
  deepEquals(a.nftMetadata, b.nftMetadata);

export const createHandlesTracker = ({ tip$, assetInfo$, handlePolicyIds, logger, utxo$ }: HandlesTrackerProps) =>
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
            handle: Buffer.from(Cardano.AssetId.getAssetName(handleAssetId), 'hex').toString('utf8'),
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
    shareReplay({ bufferSize: 1, refCount: true })
  );
