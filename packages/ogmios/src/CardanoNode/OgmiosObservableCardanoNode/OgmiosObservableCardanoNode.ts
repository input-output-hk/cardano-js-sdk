// Tested in packages/e2e/test/projection
import {
  Cardano,
  CardanoNodeErrors,
  EraSummary,
  ObservableCardanoNode,
  ObservableChainSync,
  PointOrOrigin
} from '@cardano-sdk/core';
import { InteractionContextProps, createObservableInteractionContext } from './createObservableInteractionContext';
import { Intersection, findIntersect } from '@cardano-ogmios/client/dist/ChainSync';
import { Logger } from 'ts-log';
import { Observable, distinctUntilChanged, from, shareReplay, switchMap } from 'rxjs';
import { WithLogger, contextLogger } from '@cardano-sdk/util';
import { createObservableChainSyncClient } from './createObservableChainSyncClient';
import { createStateQueryClient } from '@cardano-ogmios/client';
import { ogmiosToCorePointOrOrigin, ogmiosToCoreTipOrOrigin, pointOrOriginToOgmios } from './util';
import { queryEraSummaries, queryGenesisParameters } from '../queries';
import isEqual from 'lodash/isEqual';

const ogmiosToCoreIntersection = (intersection: Intersection) => ({
  point: ogmiosToCorePointOrOrigin(intersection.point),
  tip: ogmiosToCoreTipOrOrigin(intersection.tip)
});

export type OgmiosObservableCardanoNodeProps = Omit<InteractionContextProps, 'interactionType'>;

export class OgmiosObservableCardanoNode implements ObservableCardanoNode {
  readonly #logger: Logger;
  readonly #interactionContext$;

  readonly eraSummaries$: Observable<EraSummary[]>;
  readonly genesisParameters$: Observable<Cardano.CompactGenesis>;

  constructor(props: OgmiosObservableCardanoNodeProps, { logger }: WithLogger) {
    this.#logger = contextLogger(logger, 'ObservableOgmiosCardanoNode');
    this.#interactionContext$ = createObservableInteractionContext(
      {
        ...props,
        interactionType: 'LongRunning'
      },
      { logger: this.#logger }
    ).pipe(shareReplay({ bufferSize: 1, refCount: true }));
    const stateQueryClient$ = this.#interactionContext$.pipe(
      switchMap((interactionContext) => from(createStateQueryClient(interactionContext))),
      distinctUntilChanged(isEqual),
      shareReplay({ bufferSize: 1, refCount: true })
    );
    this.eraSummaries$ = stateQueryClient$.pipe(switchMap((client) => from(queryEraSummaries(client, this.#logger))));
    this.genesisParameters$ = stateQueryClient$.pipe(
      switchMap((client) => from(queryGenesisParameters(client, this.#logger))),
      distinctUntilChanged(isEqual),
      shareReplay({ bufferSize: 1, refCount: true })
    );
  }

  /**
   * See {@link ObservableCardanoNode.findIntersect}.
   *
   * This implementation of `chainSync$` in the emitted object should only have
   * a single subscriber per client (instance of OgmiosObservableCardanoNode),
   * because it's using a stateful connection - limited to 1 cursor per connection.
   */
  findIntersect(points: PointOrOrigin[]) {
    return this.#interactionContext$.pipe(
      switchMap(
        (interactionContext) =>
          new Observable<ObservableChainSync>((subscriber) => {
            // eslint-disable-next-line promise/always-return
            if (subscriber.closed) return;
            void findIntersect(interactionContext, points.map(pointOrOriginToOgmios))
              // eslint-disable-next-line promise/always-return
              .then((ogmiosIntersection) => {
                const intersection = ogmiosToCoreIntersection(ogmiosIntersection);
                subscriber.next({
                  chainSync$: createObservableChainSyncClient(
                    { intersectionPoint: intersection.point },
                    { interactionContext$: this.#interactionContext$ }
                  ),
                  intersection
                });
              })
              .catch((error) => {
                this.#logger.error('"findIntersect" failed', error);
                if (error instanceof CardanoNodeErrors.CardanoClientErrors.ConnectionError) {
                  // interactionContext$ will reconnect and trigger a retry
                  return;
                }
                subscriber.error(error);
              });
          })
      )
    );
  }
}
