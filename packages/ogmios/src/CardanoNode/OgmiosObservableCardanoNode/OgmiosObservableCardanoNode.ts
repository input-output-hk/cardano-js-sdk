// Tested in packages/e2e/test/projection
import {
  Cardano,
  CardanoNodeErrors,
  EraSummary,
  HealthCheckResponse,
  Milliseconds,
  ObservableCardanoNode,
  ObservableChainSync,
  PointOrOrigin
} from '@cardano-sdk/core';
import {
  ConnectionConfig,
  createConnectionObject,
  createStateQueryClient,
  getServerHealth
} from '@cardano-ogmios/client';
import { InteractionContextProps, createObservableInteractionContext } from './createObservableInteractionContext';
import { Intersection, findIntersect } from '@cardano-ogmios/client/dist/ChainSync';
import { Logger } from 'ts-log';
import {
  Observable,
  catchError,
  distinctUntilChanged,
  from,
  map,
  of,
  shareReplay,
  switchMap,
  throwError,
  timeout
} from 'rxjs';
import { WithLogger, contextLogger } from '@cardano-sdk/util';
import { createObservableChainSyncClient } from './createObservableChainSyncClient';
import { ogmiosServerHealthToHealthCheckResponse } from '../../util';
import { ogmiosToCorePointOrOrigin, ogmiosToCoreTipOrOrigin, pointOrOriginToOgmios } from './util';
import { queryEraSummaries, queryGenesisParameters } from '../queries';
import isEqual from 'lodash/isEqual';

const ogmiosToCoreIntersection = (intersection: Intersection) => ({
  point: ogmiosToCorePointOrOrigin(intersection.point),
  tip: ogmiosToCoreTipOrOrigin(intersection.tip)
});

const DEFAULT_HEALTH_CHECK_TIMEOUT = 2000;
export type OgmiosObservableCardanoNodeProps = Omit<InteractionContextProps, 'interactionType'> & {
  /**
   * Default: 2000ms
   */
  healthCheckTimeout?: Milliseconds;
};

export class OgmiosObservableCardanoNode implements ObservableCardanoNode {
  readonly #connectionConfig$: Observable<ConnectionConfig>;
  readonly #logger: Logger;
  readonly #interactionContext$;

  readonly eraSummaries$: Observable<EraSummary[]>;
  readonly genesisParameters$: Observable<Cardano.CompactGenesis>;
  readonly healthCheck$: Observable<HealthCheckResponse>;

  constructor(props: OgmiosObservableCardanoNodeProps, { logger }: WithLogger) {
    this.#connectionConfig$ = props.connectionConfig$;
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
      distinctUntilChanged((a, b) => isEqual(a, b)),
      shareReplay({ bufferSize: 1, refCount: true })
    );
    this.eraSummaries$ = stateQueryClient$.pipe(switchMap((client) => from(queryEraSummaries(client, this.#logger))));
    this.genesisParameters$ = stateQueryClient$.pipe(
      switchMap((client) => from(queryGenesisParameters(client, this.#logger))),
      distinctUntilChanged(isEqual),
      shareReplay({ bufferSize: 1, refCount: true })
    );
    this.healthCheck$ = this.#connectionConfig$.pipe(
      switchMap((connectionConfig) => from(getServerHealth({ connection: createConnectionObject(connectionConfig) }))),
      map(ogmiosServerHealthToHealthCheckResponse),
      timeout({
        first: props.healthCheckTimeout || DEFAULT_HEALTH_CHECK_TIMEOUT,
        with: () => {
          logger.error('healthCheck$ didnt emit within healthCheckTimeout');
          return throwError(() => new CardanoNodeErrors.CardanoClientErrors.ConnectionError());
        }
      }),
      catchError((error) => {
        this.#logger.error(error);
        return of({ ok: false });
      }),
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
