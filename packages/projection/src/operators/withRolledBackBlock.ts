import { ChainSyncEventType } from '@cardano-sdk/core';
import { EMPTY, concatMap, filter, finalize, map, mergeMap, noop, of, switchMap, take, takeWhile } from 'rxjs';
import type { Cardano, ChainSyncEvent, TipOrOrigin } from '@cardano-sdk/core';
import type { ExtChainSyncOperator, StabilityWindowBuffer, WithBlock } from '../types.js';
import type { Observable } from 'rxjs';

const syncFromOrigin = (chainSyncEvent: ChainSyncEvent, projectedTip$: Observable<TipOrOrigin>) =>
  projectedTip$.pipe(
    take(1),
    mergeMap((tip) => {
      if (tip !== 'origin') {
        // TODO: replace with a ChainSyncError after reworking CardanoNodeErrors
        throw new Error('Rollback to origin: wrong network?');
      } else {
        // Rollback to origin while local tip is at origin is a no-op
        chainSyncEvent.requestNext();
        return EMPTY;
      }
    })
  );

/**
 * Transforms rollback event into a stream of granular rollback events, each containing a single rolled back block.
 * Intended to be used as the 1st projection operator.
 */
export const withRolledBackBlock =
  (
    projectedTip$: Observable<TipOrOrigin>,
    buffer: StabilityWindowBuffer
  ): ExtChainSyncOperator<{}, {}, {}, WithBlock> =>
  (evt$: Observable<ChainSyncEvent>) =>
    evt$.pipe(
      concatMap((chainSyncEvent) => {
        switch (chainSyncEvent.eventType) {
          case ChainSyncEventType.RollForward:
            return of(chainSyncEvent);
          case ChainSyncEventType.RollBackward: {
            const rollbackPoint = chainSyncEvent.point;
            if (rollbackPoint === 'origin') {
              return syncFromOrigin(chainSyncEvent, projectedTip$);
            }
            return projectedTip$.pipe(
              takeWhile(
                (tip): tip is Cardano.PartialBlockHeader => tip !== 'origin' && tip.hash !== rollbackPoint.hash
              ),
              switchMap((tip) => buffer.getBlock(tip.hash)),
              filter((block): block is Cardano.Block => {
                if (!block) {
                  // TODO: replace with a ChainSyncError after reworking CardanoNodeErrors
                  throw new Error(
                    `Could not rollback to ${rollbackPoint.hash}: tip block not found in stability window buffer`
                  );
                }
                return true;
              }),
              map((block) => ({
                ...chainSyncEvent,
                block,
                requestNext: noop
              })),
              // Call requestNext() once all rolled back blocks are processed
              finalize(chainSyncEvent.requestNext)
            );
          }
        }
      })
    );
