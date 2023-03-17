/* eslint-disable max-len */
/* eslint-disable jsdoc/valid-types */
/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  Cardano,
  CardanoNodeErrors,
  ChainSyncEventType,
  Intersection,
  ObservableCardanoNode,
  ObservableChainSync,
  PointOrOrigin,
  TipOrOrigin
} from '@cardano-sdk/core';
import { DefaultProjectionProps, Projection } from './projections';
import { Logger } from 'ts-log';
import {
  Observable,
  combineLatest,
  concat,
  concatMap,
  defaultIfEmpty,
  defer,
  finalize,
  map,
  mergeMap,
  noop,
  of,
  take,
  takeWhile,
  tap
} from 'rxjs';
import { Sink, Sinks, SinksFactory } from './sinks';
import { UnifiedProjectorEvent } from './types';
import { WithNetworkInfo, withEpochBoundary, withEpochNo, withNetworkInfo, withRolledBackBlock } from './operators';
import { combineProjections } from './combineProjections';
import { contextLogger } from '@cardano-sdk/util';
import { passthrough } from '@cardano-sdk/util-rxjs';
import uniq from 'lodash/uniq';

export interface ProjectIntoSinkProps<P, PS extends P> {
  projections: P;
  sinksFactory: SinksFactory<PS>;
  cardanoNode: ObservableCardanoNode;
  logger: Logger;
}

type ProjectionTypes<P> = {
  [k in keyof P]: P[k] extends Projection<infer Props> ? Props : never;
};
// https://stackoverflow.com/a/50375286
type UnionToIntersection<U> = (U extends any ? (k: U) => void : never) extends (k: infer I) => void ? I : never;
export type ProjectionsEvent<P extends object> = UnifiedProjectorEvent<
  UnionToIntersection<ProjectionTypes<P>[keyof P]>
>;

const isIntersectionBlock = (block: Cardano.Block, intersection: Intersection) => {
  if (intersection.point === 'origin') {
    return false;
  }
  return block.header.hash === intersection.point.hash;
};

const blocksToPoints = (blocks: Array<Cardano.Block | 'origin'>) =>
  uniq([...blocks.map((p) => (p === 'origin' ? p : p.header)), 'origin' as const]);

const pointDescription = (point: PointOrOrigin) =>
  point === 'origin' ? 'origin' : `slot ${point.slot}, block ${point.hash}`;

const isAtTheTipOrHigher = (header: Cardano.PartialBlockHeader, tip: TipOrOrigin) => {
  if (tip === 'origin') return false;
  return header.blockNo >= tip.blockNo;
};

const logEvent =
  <T extends UnifiedProjectorEvent<{}>>(logger: Logger) =>
  (evt$: Observable<T>) => {
    let numEvt = 0;
    const logFrequency = 1000;
    const startedAt = Date.now();
    let lastLogAt = startedAt;
    return evt$.pipe(
      tap(({ block: { header }, eventType, tip }) => {
        numEvt++;
        if (isAtTheTipOrHigher(header, tip)) {
          logger.info(
            `Processed event ${
              eventType === ChainSyncEventType.RollForward ? 'RollForward' : 'RollBackward'
            } ${pointDescription(header)}`
          );
        } else if (numEvt % logFrequency === 0 && tip !== 'origin') {
          const syncPercentage = ((header.blockNo * 100) / tip.blockNo).toFixed(2);
          const now = Date.now();
          const currentSpeed = Math.round(logFrequency / ((now - lastLogAt) / 1000));
          lastLogAt = now;
          const overallSpeedPerMs = numEvt / (now - startedAt);
          const overallSpeed = Math.round(overallSpeedPerMs * 1000);
          const eta = new Date(now + (tip.blockNo - header.blockNo) / overallSpeedPerMs);
          logger.info(
            `Initializing ${syncPercentage}% at block #${
              header.blockNo
            }. Speed: ${currentSpeed}bps (avg ${overallSpeed}bps). ETA: ${eta.toISOString()}`
          );
        }
      })
    );
  };

const syncFromIntersection = <PS>({
  cardanoNode,
  chainSync: { intersection, chainSync$ },
  logger,
  sinks
}: {
  logger: Logger;
  cardanoNode: ObservableCardanoNode;
  sinks: Sinks<PS>;
  chainSync: ObservableChainSync;
}) =>
  new Observable<UnifiedProjectorEvent<DefaultProjectionProps>>((observer) => {
    logger.info(`Starting ChainSync from ${pointDescription(intersection.point)}`);
    return chainSync$
      .pipe(
        withRolledBackBlock(sinks.buffer),
        withNetworkInfo(cardanoNode),
        withEpochNo(),
        withEpochBoundary(intersection)
      )
      .subscribe(observer);
  });

const rollbackAndSyncFromIntersection = <PS>({
  sinks,
  cardanoNode,
  initialChainSync,
  logger,
  tail
}: {
  sinks: Sinks<PS>;
  cardanoNode: ObservableCardanoNode;
  initialChainSync: ObservableChainSync;
  logger: Logger;
  tail: Cardano.Block | 'origin';
}) =>
  new Observable<UnifiedProjectorEvent<{}>>((subscriber) => {
    logger.warn('Rolling back to find intersection');
    let skipFindingNewIntersection = true;
    let chainSync = initialChainSync;
    const rollback$ = sinks.buffer.tip$.pipe(
      // Use the initial tip as intersection point for withEpochBoundary
      take(1),
      mergeMap((initialTip) =>
        sinks.buffer.tip$.pipe(
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
      defer(() => syncFromIntersection({ cardanoNode, chainSync, logger, sinks }))
    ).subscribe(subscriber);
  });

const createChainSyncSource = <PS>({
  sinks,
  logger,
  cardanoNode
}: {
  cardanoNode: ObservableCardanoNode;
  logger: Logger;
  sinks: Sinks<PS>;
}) =>
  combineLatest([sinks.buffer.tip$, sinks.buffer.tail$]).pipe(
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
            return syncFromIntersection({ cardanoNode, chainSync: initialChainSync, logger, sinks });
          }
          if (blocks[0] !== 'origin' && initialChainSync.intersection.point.hash !== blocks[0].header.hash) {
            // rollback to intersection, then sync from intersection
            return rollbackAndSyncFromIntersection({
              cardanoNode,
              initialChainSync,
              logger,
              sinks,
              tail: blocks[1]
            });
          }
          // intersection is at tip$ - no rollback, just sync from intersection
          return syncFromIntersection({ cardanoNode, chainSync: initialChainSync, logger, sinks });
        })
      );
    })
  );

// TODO: try to write types that will infer returned observable type from supplied projections.
// Inferring properties added by sinks (e.g. before() and after()) would be nice too, but probably not necessary.
/**
 * @throws {@link InvalidIntersectionError} when no intersection with provided {@link selectedSinks.StabilityWindowBuffer} is found.
 */
export const projectIntoSink = <P extends object, PS extends P>({
  cardanoNode,
  logger: baseLogger,
  projections,
  sinksFactory
}: ProjectIntoSinkProps<P, PS>): Observable<ProjectionsEvent<P>> => {
  const logger = contextLogger(baseLogger, 'Projector');

  return defer(() => of(sinksFactory())).pipe(
    mergeMap((sinks) => {
      const source$ = createChainSyncSource({ cardanoNode, logger, sinks });
      // eslint-disable-next-line prefer-spread
      const projected$ = source$.pipe.apply(source$, combineProjections(projections) as any);
      const selectedSinks: Sink<any, any>[] = Object.keys(sinks.projectionSinks)
        .filter((k) => k in projections)
        .map((k) => (sinks.projectionSinks as any)[k]);
      return projected$.pipe(
        sinks.before || passthrough(),
        concatMap((evt) => {
          const projectionSinks = selectedSinks.map((sink) => sink.sink(evt));
          const projectorEvent = evt as UnifiedProjectorEvent<WithNetworkInfo>;
          return projectionSinks.length > 0
            ? combineLatest(projectionSinks.map((o$) => o$.pipe(defaultIfEmpty(null)))).pipe(map(() => projectorEvent))
            : of(projectorEvent);
        }),
        sinks.buffer.handleEvents,
        sinks.after || passthrough(),
        logEvent(logger),
        tap((evt) => evt.requestNext()),
        finalize(() => logger.info('Stopped'))
      );
    })
  );
};
