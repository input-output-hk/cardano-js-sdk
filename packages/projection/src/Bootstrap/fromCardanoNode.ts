/* eslint-disable max-len */
/* eslint-disable jsdoc/valid-types */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { ChainSyncEventType, ObservableCardanoNode } from '@cardano-sdk/core';
import { Observable, concat, defer, map, mergeMap, noop, of, switchMap, take, takeWhile, tap } from 'rxjs';
import { contextLogger } from '@cardano-sdk/util';
import { pointDescription } from '../util.js';
import { withEpochBoundary, withEpochNo, withNetworkInfo, withRolledBackBlock } from '../operators/index.js';
import uniq from 'lodash/uniq.js';
import type { Cardano, Intersection, ObservableChainSync, TipOrOrigin } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';
import type { ProjectionEvent, StabilityWindowBuffer, UnifiedExtChainSyncEvent } from '../types.js';

const isIntersectionBlock = (block: Cardano.Block, intersection: Intersection) => {
  if (intersection.point === 'origin') {
    return false;
  }
  return block.header.hash === intersection.point.hash;
};

const syncFromIntersection = ({
  blocksBufferLength,
  buffer,
  cardanoNode,
  projectedTip$,
  chainSync: { intersection, chainSync$ },
  logger
}: {
  blocksBufferLength: number;
  buffer: StabilityWindowBuffer;
  cardanoNode: ObservableCardanoNode;
  chainSync: ObservableChainSync;
  projectedTip$: Observable<TipOrOrigin>;
  logger: Logger;
}) =>
  new Observable<ProjectionEvent>((observer) => {
    logger.info(`Starting ChainSync from ${pointDescription(intersection.point)}`);
    return chainSync$
      .pipe(
        ObservableCardanoNode.bufferChainSyncEvent(blocksBufferLength),
        withRolledBackBlock(projectedTip$, buffer),
        withNetworkInfo(cardanoNode),
        withEpochNo(),
        withEpochBoundary(intersection)
      )
      .subscribe(observer);
  });

const rollbackAndSyncFromIntersection = ({
  blocksBufferLength,
  buffer,
  cardanoNode,
  initialChainSync,
  logger,
  projectedTip$
}: {
  blocksBufferLength: number;
  buffer: StabilityWindowBuffer;
  cardanoNode: ObservableCardanoNode;
  initialChainSync: ObservableChainSync;
  logger: Logger;
  projectedTip$: Observable<TipOrOrigin>;
}) =>
  new Observable<ProjectionEvent>((subscriber) => {
    logger.warn('Rolling back to find intersection');
    let skipFindingNewIntersection = true;
    let chainSync = initialChainSync;
    const rollback$ = projectedTip$.pipe(
      // Use the initial tip as intersection point for withEpochBoundary
      take(1),
      mergeMap((initialTip) =>
        projectedTip$.pipe(
          takeWhile((tip): tip is Cardano.PartialBlockHeader => tip !== 'origin'),
          switchMap((tip) => buffer.getBlock(tip.hash)),
          mergeMap((block): Observable<Cardano.Block> => {
            if (!block) {
              // TODO: replace with a ChainSyncError after reworking CardanoNodeErrors
              throw new Error('Block not found in the buffer');
            }
            // we already have an intersection for the 1st tip
            if (skipFindingNewIntersection) {
              skipFindingNewIntersection = false;
              return of(block);
            }
            // try to find intersection with new tip
            return cardanoNode.findIntersect([block.header, 'origin']).pipe(
              take(1),
              tap((newChainSync) => {
                chainSync = newChainSync;
              }),
              map(() => block)
            );
          }),
          takeWhile((block) => !isIntersectionBlock(block, chainSync.intersection)),
          mergeMap(
            (block): Observable<UnifiedExtChainSyncEvent<{}>> =>
              of({
                block,
                eventType: ChainSyncEventType.RollBackward,
                point: chainSync.intersection.point,
                // requestNext is a no-op when rolling back during initialization, because projectIntoSink will
                // delete block from the buffer for every RollBackward event via `manageBuffer`,
                // which will trigger the buffer to emit the next tip$
                requestNext: noop,
                tip: chainSync.intersection.tip
              })
          ),
          withNetworkInfo(cardanoNode),
          withEpochNo(),
          withEpochBoundary({ point: initialTip })
        )
      )
    );
    return concat(
      rollback$,
      defer(() => syncFromIntersection({ blocksBufferLength, buffer, cardanoNode, chainSync, logger, projectedTip$ }))
    ).subscribe(subscriber);
  });

/**
 * Finds intersection with local projectedTip$.
 * If bootstrapping from a forked local state:
 * - Will emit RollBackward events with block from buffer tip one by one until it finds intersection.
 * - Expects projectedTip$ to emit after processing each RollBackward event
 */
export const fromCardanoNode = ({
  blocksBufferLength,
  buffer,
  projectedTip$,
  cardanoNode,
  logger: baseLogger
}: {
  blocksBufferLength: number;
  buffer: StabilityWindowBuffer;
  cardanoNode: ObservableCardanoNode;
  logger: Logger;
  projectedTip$: Observable<TipOrOrigin>;
}): Observable<ProjectionEvent> => {
  const logger = contextLogger(baseLogger, 'Bootstrap');
  return projectedTip$.pipe(
    take(1),
    mergeMap((tip) => {
      logger.info(`Starting projector with local tip at ${pointDescription(tip)}`);
      const points = uniq([tip, 'origin' as const]);
      return cardanoNode.findIntersect(points).pipe(
        take(1),
        mergeMap((initialChainSync) => {
          if (
            tip === 'origin' ||
            (initialChainSync.intersection.point !== 'origin' && initialChainSync.intersection.point.hash === tip.hash)
          ) {
            logger.info('syncFromIntersection');
            // either sync from origin, or start sync from local tip
            return syncFromIntersection({
              blocksBufferLength,
              buffer,
              cardanoNode,
              chainSync: initialChainSync,
              logger,
              projectedTip$
            });
          }
          // no intersection at local tip
          return rollbackAndSyncFromIntersection({
            blocksBufferLength,
            buffer,
            cardanoNode,
            initialChainSync,
            logger,
            projectedTip$
          });
        })
      );
    })
  );
};
