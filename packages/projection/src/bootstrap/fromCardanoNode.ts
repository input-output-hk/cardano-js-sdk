/* eslint-disable max-len */
/* eslint-disable jsdoc/valid-types */
/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  Cardano,
  CardanoNodeErrors,
  ChainSyncEventType,
  Intersection,
  ObservableCardanoNode,
  ObservableChainSync
} from '@cardano-sdk/core';
import { DefaultProjectionProps } from '../projections';
import { Logger } from 'ts-log';
import { Observable, combineLatest, concat, defer, map, mergeMap, noop, of, take, takeWhile, tap } from 'rxjs';
import { ProjectionSource } from './types';
import { StabilityWindowBuffer } from '../sinks';
import { UnifiedProjectorEvent } from '../types';
import { contextLogger } from '@cardano-sdk/util';
import { pointDescription } from '../util';
import { withEpochBoundary, withEpochNo, withNetworkInfo, withRolledBackBlock } from '../operators';
import uniq from 'lodash/uniq';

const isIntersectionBlock = (block: Cardano.Block, intersection: Intersection) => {
  if (intersection.point === 'origin') {
    return false;
  }
  return block.header.hash === intersection.point.hash;
};

const blocksToPoints = (blocks: Array<Cardano.Block | 'origin'>) =>
  uniq([...blocks.map((p) => (p === 'origin' ? p : p.header)), 'origin' as const]);

const syncFromIntersection = ({
  cardanoNode,
  chainSync: { intersection, chainSync$ },
  logger,
  buffer
}: {
  logger: Logger;
  cardanoNode: ObservableCardanoNode;
  buffer: StabilityWindowBuffer;
  chainSync: ObservableChainSync;
}) =>
  new Observable<UnifiedProjectorEvent<DefaultProjectionProps>>((observer) => {
    logger.info(`Starting ChainSync from ${pointDescription(intersection.point)}`);
    return chainSync$
      .pipe(withRolledBackBlock(buffer), withNetworkInfo(cardanoNode), withEpochNo(), withEpochBoundary(intersection))
      .subscribe(observer);
  });

const rollbackAndSyncFromIntersection = ({
  buffer,
  cardanoNode,
  initialChainSync,
  logger,
  tail
}: {
  buffer: StabilityWindowBuffer;
  cardanoNode: ObservableCardanoNode;
  initialChainSync: ObservableChainSync;
  logger: Logger;
  tail: Cardano.Block | 'origin';
}) =>
  new Observable<UnifiedProjectorEvent<DefaultProjectionProps>>((subscriber) => {
    logger.warn('Rolling back to find intersection');
    let skipFindingNewIntersection = true;
    let chainSync = initialChainSync;
    const rollback$ = buffer.tip$.pipe(
      // Use the initial tip as intersection point for withEpochBoundary
      take(1),
      mergeMap((initialTip) =>
        buffer.tip$.pipe(
          takeWhile((block): block is Cardano.Block => block !== 'origin'),
          mergeMap((block): Observable<Cardano.Block> => {
            // we already have an intersection for the 1st tip
            if (skipFindingNewIntersection) {
              skipFindingNewIntersection = false;
              return of(block);
            }
            // try to find intersection with new tip
            return cardanoNode.findIntersect(blocksToPoints([block, tail, 'origin'])).pipe(
              take(1),
              tap((newChainSync) => {
                chainSync = newChainSync;
              }),
              map(() => block)
            );
          }),
          takeWhile((block) => !isIntersectionBlock(block, chainSync.intersection)),
          mergeMap(
            (block): Observable<UnifiedProjectorEvent<{}>> =>
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
          withEpochBoundary({ point: initialTip === 'origin' ? initialTip : initialTip.header })
        )
      )
    );
    return concat(
      rollback$,
      defer(() => syncFromIntersection({ buffer, cardanoNode, chainSync, logger }))
    ).subscribe(subscriber);
  });

/**
 * Finds intersection with provider StabilityWindowBuffer.
 * If bootstrapping from a forked local state:
 * - Will emit RollBackward events with block from buffer tip one by one until it finds intersection.
 * - Expects buffer to emit new tip$ after processing each RollBackward event
 *
 * @throws InvalidIntersectionError when no intersection with provided {@link StabilityWindowBuffer} is found.
 */
export const fromCardanoNode = ({
  buffer,
  logger: baseLogger,
  cardanoNode
}: {
  cardanoNode: ObservableCardanoNode;
  logger: Logger;
  buffer: StabilityWindowBuffer;
}): ProjectionSource => {
  const logger = contextLogger(baseLogger, 'Bootstrap');
  return combineLatest([buffer.tip$, buffer.tail$]).pipe(
    take(1),
    mergeMap((blocks) => {
      const points = blocksToPoints(blocks);
      logger.info(`Starting projector with local tip at ${pointDescription(points[0])}`);

      return cardanoNode.findIntersect(points).pipe(
        take(1),
        mergeMap((initialChainSync) => {
          if (initialChainSync.intersection.point === 'origin') {
            if (blocks[0] !== 'origin') {
              throw new CardanoNodeErrors.CardanoClientErrors.IntersectionNotFoundError(
                // TODO: CardanoClientErrors are currently coupled to ogmios types.
                // This would be cleaner if errors were mapped to use our core objects.
                points.map((point) =>
                  point === 'origin'
                    ? 'origin'
                    : {
                        hash: point.hash,
                        slot: point.slot
                      }
                )
              );
            }
            // buffer is empty, sync from origin
            return syncFromIntersection({ buffer, cardanoNode, chainSync: initialChainSync, logger });
          }
          if (blocks[0] !== 'origin' && initialChainSync.intersection.point.hash !== blocks[0].header.hash) {
            // rollback to intersection, then sync from intersection
            return rollbackAndSyncFromIntersection({
              buffer,
              cardanoNode,
              initialChainSync,
              logger,
              tail: blocks[1]
            });
          }
          // intersection is at tip$ - no rollback, just sync from intersection
          return syncFromIntersection({ buffer, cardanoNode, chainSync: initialChainSync, logger });
        })
      );
    })
  );
};
