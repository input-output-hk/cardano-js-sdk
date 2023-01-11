/* eslint-disable jsdoc/valid-types */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano, ChainSyncEventType, Intersection } from '@cardano-sdk/core';
import {
  InvalidIntersectionError,
  ObservableChainSync,
  ObservableChainSyncClient,
  UnifiedProjectorEvent
} from './types';
import { Logger } from 'ts-log';
import {
  Observable,
  combineLatest,
  concat,
  concatMap,
  defaultIfEmpty,
  defer,
  map,
  mergeMap,
  noop,
  of,
  take,
  takeWhile,
  tap
} from 'rxjs';
import { Projection } from './projections';
import { Sink, Sinks, manageBuffer } from './sinks';
import { WithNetworkInfo, withNetworkInfo, withRolledBackBlock } from './operators';
import { combineProjections } from './combineProjections';
import { passthrough } from '@cardano-sdk/util-rxjs';
import uniq from 'lodash/uniq';

export interface ProjectIntoSinkProps<P, PS extends P> {
  projections: P;
  sinks: Sinks<PS>;
  chainSync: ObservableChainSyncClient;
  networkInfo: WithNetworkInfo;
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

const intersectionDescription = (intersection: Intersection) =>
  intersection.point === 'origin' ? 'origin' : `slot ${intersection.point.slot}, block ${intersection.point.hash}`;

// TODO: try to write types that will infer returned observable type from supplied projections.
// Inferring properties added by sinks (e.g. before() and after()) would be nice too, but probably not necessary.
/**
 * @throws {@link InvalidIntersectionError} when no intesection with provided {@link StabilityWindowBuffer} is found.
 */
export const projectIntoSink = <P extends object, PS extends P>(
  props: ProjectIntoSinkProps<P, PS>
): Observable<ProjectionsEvent<P>> => {
  const syncFromIntersection = ({ intersection, chainSync$ }: ObservableChainSync) =>
    new Observable<UnifiedProjectorEvent<{}>>((observer) => {
      props.logger.info(`Starting ChainSync from ${intersectionDescription(intersection)}`);
      return chainSync$.pipe(withRolledBackBlock(props.sinks.buffer)).subscribe(observer);
    });

  const rollbackAndSyncFromIntersection = (initialChainSync: ObservableChainSync, tail: Cardano.Block | 'origin') =>
    new Observable<UnifiedProjectorEvent<{}>>((subscriber) => {
      props.logger.warn(`Rolling back to intersection ${intersectionDescription(initialChainSync.intersection)}`);
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
          return props
            .chainSync({
              points: blocksToPoints([block, tail, 'origin'])
            })
            .pipe(
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
    mergeMap((blocks) =>
      props
        .chainSync({
          points: blocksToPoints(blocks)
        })
        .pipe(
          mergeMap((initialChainSync) => {
            if (initialChainSync.intersection.point === 'origin') {
              if (blocks[0] !== 'origin') {
                throw new InvalidIntersectionError(
                  "Couldn't find intersection within stability window buffer. Possible network configuration mismatch."
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
        )
    ),
    withNetworkInfo(props.networkInfo)
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
      const bufferSink$ = manageBuffer(projectorEvent, props.sinks.buffer);
      return combineLatest([...projectionSinks, bufferSink$].map((o$) => o$.pipe(defaultIfEmpty(null)))).pipe(
        map(() => projectorEvent)
      );
    }),
    props.sinks.after || passthrough(),
    tap((evt) => evt.requestNext())
  );
};
