// Tested in packages/e2e/test/projection
import { CardanoNodeErrors } from '@cardano-sdk/core';
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
import { contextLogger } from '@cardano-sdk/util';
import { createConnectionObject, createStateQueryClient, getServerHealth } from '@cardano-ogmios/client';
import { createObservableChainSyncClient } from './createObservableChainSyncClient.js';
import { createObservableInteractionContext } from './createObservableInteractionContext.js';
import { findIntersect } from '@cardano-ogmios/client/dist/ChainSync';
import { ogmiosServerHealthToHealthCheckResponse } from '../../util.js';
import { ogmiosToCorePointOrOrigin, ogmiosToCoreTipOrOrigin, pointOrOriginToOgmios } from './util.js';
import { queryEraSummaries, queryGenesisParameters } from '../queries.js';
import { retryBackoff } from 'backoff-rxjs';
import isEqual from 'lodash/isEqual.js';
import type {
  Cardano,
  EraSummary,
  HealthCheckResponse,
  Milliseconds,
  ObservableCardanoNode,
  ObservableChainSync,
  PointOrOrigin
} from '@cardano-sdk/core';
import type { ConnectionConfig } from '@cardano-ogmios/client';
import type { InteractionContextProps } from './createObservableInteractionContext.js';
import type { Intersection } from '@cardano-ogmios/client/dist/ChainSync';
import type { Logger } from 'ts-log';
import type { RetryBackoffConfig } from 'backoff-rxjs';
import type { WithLogger } from '@cardano-sdk/util';

const ogmiosToCoreIntersection = (intersection: Intersection) => ({
  point: ogmiosToCorePointOrOrigin(intersection.point),
  tip: ogmiosToCoreTipOrOrigin(intersection.tip)
});

export type LocalStateQueryRetryConfig = Pick<RetryBackoffConfig, 'initialInterval' | 'maxInterval'>;

const DEFAULT_HEALTH_CHECK_TIMEOUT = 2000;
const DEFAULT_LSQ_RETRY_CONFIG: LocalStateQueryRetryConfig = {
  initialInterval: 1000,
  maxInterval: 30_000
};
export type OgmiosObservableCardanoNodeProps = Omit<InteractionContextProps, 'interactionType'> & {
  /** Default: 2000ms */
  healthCheckTimeout?: Milliseconds;
  /** Default: {initialInterval: 1000, maxInterval: 30_000} */
  localStateQueryRetryConfig?: LocalStateQueryRetryConfig;
};

const stateQueryRetryBackoffConfig = (
  retryConfig: LocalStateQueryRetryConfig = DEFAULT_LSQ_RETRY_CONFIG,
  logger: Logger
): RetryBackoffConfig => ({
  ...retryConfig,
  shouldRetry: (error) => {
    if (error instanceof CardanoNodeErrors.CardanoClientErrors.QueryUnavailableInCurrentEraError) {
      logger.info('Local state query unavailable yet, will retry...');
      return true;
    }
    return false;
  }
});

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
    this.eraSummaries$ = stateQueryClient$.pipe(
      switchMap((client) => from(queryEraSummaries(client, this.#logger))),
      retryBackoff(stateQueryRetryBackoffConfig(props.localStateQueryRetryConfig, logger))
    );
    this.genesisParameters$ = stateQueryClient$.pipe(
      switchMap((client) => from(queryGenesisParameters(client, this.#logger))),
      retryBackoff(stateQueryRetryBackoffConfig(props.localStateQueryRetryConfig, logger)),
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
                    { interactionContext$: this.#interactionContext$, logger: this.#logger }
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
