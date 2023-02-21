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
  PointOrOrigin
} from '@cardano-sdk/core';
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
import { Projection } from './projections';
import { Sink, Sinks, manageStabilityWindowBuffer } from './sinks';
import { UnifiedProjectorEvent } from './types';
import { WithNetworkInfo, withNetworkInfo, withRolledBackBlock } from './operators';
import { combineProjections } from './combineProjections';
import { contextLogger } from '@cardano-sdk/util';
import { passthrough } from '@cardano-sdk/util-rxjs';
import uniq from 'lodash/uniq';

export interface ProjectIntoSinkProps<P, PS extends P> {
  projections: P;
  sinks: Sinks<PS>;
  cardanoNode: ObservableCardanoNode;
  logger: Logger;
}

type ProjectionTypes<P> = {
  [k in keyof P]: P[k] extends Projection<infer Props> ? Props : never;
};
// https://stackoverflow.com/a/50375286
type UnionToIntersection<U> = (U extends any ? (k: U) => void : never) extends (k: infer I) => void ? I : never;
type ProjectionsEvent<P extends object> = UnifiedProjectorEvent<UnionToIntersection<ProjectionTypes<P>[keyof P]>>;

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

// TODO: try to write types that will infer returned observable type from supplied projections.
// Inferring properties added by sinks (e.g. before() and after()) would be nice too, but probably not necessary.
/**
 * @throws {@link InvalidIntersectionError} when no intersection with provided {@link sinks.StabilityWindowBuffer} is found.
 */
export const projectIntoSink = <P extends object, PS extends P>(
  props: ProjectIntoSinkProps<P, PS>
): Observable<ProjectionsEvent<P>> => {
  const logger = contextLogger(props.logger, 'Projector');

  const syncFromIntersection = ({ intersection, chainSync$ }: ObservableChainSync) =>
    new Observable<UnifiedProjectorEvent<{}>>((observer) => {
      logger.info(`Starting ChainSync from ${pointDescription(intersection.point)}`);
      return chainSync$.pipe(withRolledBackBlock(props.sinks.buffer)).subscribe(observer);
    });

  const rollbackAndSyncFromIntersection = (initialChainSync: ObservableChainSync, tail: Cardano.Block | 'origin') =>
    new Observable<UnifiedProjectorEvent<{}>>((subscriber) => {
      logger.warn('Rolling back to find intersection');
      let skipFindingNewIntersection = true;
      let chainSync = initialChainSync;
      const rollback$ = props.sinks.buffer.tip$.pipe(
        takeWhile((block): block is Cardano.Block => block !== 'origin'),
        mergeMap((block): Observable<Cardano.Block> => {
          // we already have an intersection for the 1st tip
          if (skipFindingNewIntersection) {
            skipFindingNewIntersection = false;
            return of(block);
          }
          // try to find intersection with new tip
          return props.cardanoNode.findIntersect(blocksToPoints([block, tail, 'origin'])).pipe(
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
        )
      );
      return concat(
        rollback$,
        defer(() => syncFromIntersection(chainSync))
      ).subscribe(subscriber);
    });

  const source$ = combineLatest([props.sinks.buffer.tip$, props.sinks.buffer.tail$]).pipe(
    take(1),
    mergeMap((blocks) => {
      const points = blocksToPoints(blocks);
      logger.info(`Starting projector with local tip at ${pointDescription(points[0])}`);

      return props.cardanoNode.findIntersect(points).pipe(
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
                        hash: point.hash.toString(),
                        slot: point.slot.valueOf()
                      }
                )
              );
            }
            // buffer is empty, sync from origin
            return syncFromIntersection(initialChainSync);
          }
          if (blocks[0] !== 'origin' && initialChainSync.intersection.point.hash !== blocks[0].header.hash) {
            // rollback to intersection, then sync from intersection
            return rollbackAndSyncFromIntersection(initialChainSync, blocks[1]);
          }
          // intersection is at tip$ - no rollback, just sync from intersection
          return syncFromIntersection(initialChainSync);
        })
      );
    }),
    // tap((evt) => {
    //   logger.debug(
    //     `Processed event PRE ${
    //       evt.eventType === ChainSyncEventType.RollForward ? 'RollForward' : 'RollBackward'
    //     } ${pointDescription(evt.block.header)}`
    //   );
    // }),
    withNetworkInfo(props.cardanoNode)
    // tap((evt) => {
    //   logger.debug(
    //     `Processed event POST ${
    //       evt.eventType === ChainSyncEventType.RollForward ? 'RollForward' : 'RollBackward'
    //     } ${pointDescription(evt.block.header)}`
    //   );
    // })
  );
  // eslint-disable-next-line prefer-spread
  const projected$ = source$.pipe.apply(source$, combineProjections(props.projections) as any);
  const sinks: Sink<any, any>[] = Object.keys(props.sinks.projectionSinks)
    .filter((k) => k in props.projections)
    .map((k) => (props.sinks.projectionSinks as any)[k]);
  return projected$.pipe(
    props.sinks.before || passthrough(),
    concatMap((evt) => {
      const projectionSinks = sinks.map((sink) => sink.sink(evt));
      const projectorEvent = evt as UnifiedProjectorEvent<WithNetworkInfo>;
      const bufferSink$ = manageStabilityWindowBuffer(projectorEvent, props.sinks.buffer);
      return combineLatest([...projectionSinks, bufferSink$].map((o$) => o$.pipe(defaultIfEmpty(null)))).pipe(
        map(() => projectorEvent)
      );
    }),
    props.sinks.after || passthrough(),
    tap((evt) => {
      logger.debug(
        `Processed event ${
          evt.eventType === ChainSyncEventType.RollForward ? 'RollForward' : 'RollBackward'
        } ${pointDescription(evt.block.header)}`
      );
      evt.requestNext();
    }),
    finalize(() => logger.info('Stopped'))
  );
};
