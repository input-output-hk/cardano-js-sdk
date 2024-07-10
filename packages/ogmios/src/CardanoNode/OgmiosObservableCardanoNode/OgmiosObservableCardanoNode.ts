// Tested in packages/e2e/test/projection
import {
  Cardano,
  CardanoNodeError,
  CardanoNodeUtil,
  EraSummary,
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
  HealthCheckResponse,
  Milliseconds,
  ObservableCardanoNode,
  ObservableChainSync,
  PointOrOrigin,
  StakeDistribution,
  StateQueryErrorCode,
  TxCBOR
} from '@cardano-sdk/core';
import {
  ChainSynchronization,
  ConnectionConfig,
  TransactionSubmission,
  createConnectionObject,
  createLedgerStateQueryClient,
  getServerHealth
} from '@cardano-ogmios/client';
import { InteractionContextProps, createObservableInteractionContext } from './createObservableInteractionContext';
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
  take,
  throwError,
  timeout
} from 'rxjs';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { WithLogger, contextLogger } from '@cardano-sdk/util';
import { createObservableChainSyncClient } from './createObservableChainSyncClient';
import { ogmiosServerHealthToHealthCheckResponse } from '../../util';
import { ogmiosToCorePointOrOrigin, ogmiosToCoreTipOrOrigin, pointOrOriginToOgmios } from './util';
import {
  queryEraSummaries,
  queryGenesisParameters,
  queryStakeDistribution,
  withCoreCardanoNodeError
} from '../queries';
import isEqual from 'lodash/isEqual.js';

const ogmiosToCoreIntersection = (intersection: ChainSynchronization.Intersection) => ({
  point: ogmiosToCorePointOrOrigin(intersection.intersection),
  tip: ogmiosToCoreTipOrOrigin(intersection.tip)
});

export type LocalStateQueryRetryConfig = Pick<RetryBackoffConfig, 'initialInterval' | 'maxInterval'>;
export type SubmitTxRetryConfig = Pick<RetryBackoffConfig, 'initialInterval' | 'maxInterval' | 'maxRetries'>;

const DEFAULT_HEALTH_CHECK_TIMEOUT = Milliseconds(2000);
const DEFAULT_SUBMIT_MAX_RETRIES = 5;
const DEFAULT_RETRY_CONFIG: LocalStateQueryRetryConfig = {
  initialInterval: 1000,
  maxInterval: 30_000
};
export type OgmiosObservableCardanoNodeProps = InteractionContextProps & {
  /** Default: 2000ms */
  healthCheckTimeout?: Milliseconds;
  /** Default: {initialInterval: 1000, maxInterval: 30_000} */
  localStateQueryRetryConfig?: LocalStateQueryRetryConfig;
  /** Default: {initialInterval: 1000, maxInterval: 30_000, maxRetries: 5} */
  submitTxQueryRetryConfig?: SubmitTxRetryConfig;
};

const retryableCardanoNodeErrors = new Set<number>([
  GeneralCardanoNodeErrorCode.ServerNotReady,
  GeneralCardanoNodeErrorCode.ConnectionFailure
]);

const retryableStateQueryErrors = new Set<number>([
  ...retryableCardanoNodeErrors,
  StateQueryErrorCode.UnavailableInCurrentEra
]);

const stateQueryRetryBackoffConfig = (
  retryConfig: LocalStateQueryRetryConfig = DEFAULT_RETRY_CONFIG,
  logger: Logger
): RetryBackoffConfig => ({
  ...retryConfig,
  shouldRetry: (error) => {
    if (retryableStateQueryErrors.has(CardanoNodeUtil.asCardanoNodeError(error)?.code)) {
      logger.info('Local state query unavailable yet, will retry...');
      return true;
    }
    return false;
  }
});

const submitTxRetryBackoffConfig = (
  retryConfig: SubmitTxRetryConfig = DEFAULT_RETRY_CONFIG,
  logger: Logger
): RetryBackoffConfig => ({
  ...retryConfig,
  maxRetries: retryConfig.maxRetries || DEFAULT_SUBMIT_MAX_RETRIES,
  shouldRetry: (error) => {
    if (retryableStateQueryErrors.has(CardanoNodeUtil.asCardanoNodeError(error)?.code)) {
      logger.warn('Failed to submitTx, will retry', error);
      return true;
    }
    return false;
  }
});

export class OgmiosObservableCardanoNode implements ObservableCardanoNode {
  readonly #connectionConfig$: Observable<ConnectionConfig>;
  readonly #submitTxRetryBackoffConfig: RetryBackoffConfig;
  readonly #logger: Logger;
  readonly #interactionContext$;

  readonly eraSummaries$: Observable<EraSummary[]>;
  readonly genesisParameters$: Observable<Cardano.CompactGenesis>;
  readonly stakeDistribution$: Observable<StakeDistribution>;
  readonly systemStart$: Observable<Date>;
  readonly healthCheck$: Observable<HealthCheckResponse>;

  constructor(props: OgmiosObservableCardanoNodeProps, { logger }: WithLogger) {
    this.#connectionConfig$ = props.connectionConfig$;
    this.#logger = contextLogger(logger, 'ObservableOgmiosCardanoNode');
    this.#submitTxRetryBackoffConfig = submitTxRetryBackoffConfig(props.submitTxQueryRetryConfig, logger);
    this.#interactionContext$ = createObservableInteractionContext(
      {
        ...props
      },
      { logger: this.#logger }
    ).pipe(shareReplay({ bufferSize: 1, refCount: true }));
    const stateQueryClient$ = this.#interactionContext$.pipe(
      switchMap((interactionContext) => from(createLedgerStateQueryClient(interactionContext))),
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
    this.stakeDistribution$ = stateQueryClient$.pipe(
      switchMap((client) => from(queryStakeDistribution(client, this.#logger))),
      retryBackoff(stateQueryRetryBackoffConfig(props.localStateQueryRetryConfig, logger))
    );
    this.systemStart$ = stateQueryClient$.pipe(
      switchMap((client) => from(withCoreCardanoNodeError(() => client.networkStartTime()))),
      retryBackoff(stateQueryRetryBackoffConfig(props.localStateQueryRetryConfig, logger))
    );
    this.healthCheck$ = this.#connectionConfig$.pipe(
      switchMap((connectionConfig) => from(getServerHealth({ connection: createConnectionObject(connectionConfig) }))),
      map(ogmiosServerHealthToHealthCheckResponse),
      timeout({
        first: props.healthCheckTimeout || DEFAULT_HEALTH_CHECK_TIMEOUT,
        with: () => {
          logger.error('healthCheck$ didnt emit within healthCheckTimeout');
          return throwError(
            () =>
              new GeneralCardanoNodeError(
                GeneralCardanoNodeErrorCode.ConnectionFailure,
                null,
                'Healthcheck request timeout'
              )
          );
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
            if (subscriber.closed) return;
            void ChainSynchronization.findIntersection(interactionContext, points.map(pointOrOriginToOgmios))
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
                if (error instanceof CardanoNodeError && error.code === GeneralCardanoNodeErrorCode.ConnectionFailure) {
                  // interactionContext$ will reconnect and trigger a retry
                  return;
                }
                subscriber.error(error);
              });
          })
      )
    );
  }

  submitTx(tx: TxCBOR): Observable<Cardano.TransactionId> {
    return this.#interactionContext$.pipe(
      switchMap((context) =>
        from(
          withCoreCardanoNodeError(() =>
            TransactionSubmission.submitTransaction(context, tx)
          ) as Promise<Cardano.TransactionId>
        )
      ),
      retryBackoff(this.#submitTxRetryBackoffConfig),
      take(1)
    );
  }
}
