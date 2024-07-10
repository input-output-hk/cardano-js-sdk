import {
  CardanoNode,
  EraSummary,
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
  HealthCheckResponse,
  Milliseconds,
  StakeDistribution
} from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import {
  MonoTypeOperatorFunction,
  Observable,
  Subject,
  defaultIfEmpty,
  firstValueFrom,
  pipe,
  takeUntil,
  throwError,
  throwIfEmpty,
  timeout
} from 'rxjs';
import { OgmiosObservableCardanoNode } from './OgmiosObservableCardanoNode';
import { RunnableModule } from '@cardano-sdk/util';

const DEFAULT_RESPONSE_TIMEOUT = Milliseconds(10_000);

const withTimeout = <T>(): MonoTypeOperatorFunction<T> =>
  // Connection errors are retried by the OgmiosObservableCardanoNode. This timeout ensures the request will not hang indefinitely.
  timeout({
    first: DEFAULT_RESPONSE_TIMEOUT,
    with: () =>
      throwError(() => new GeneralCardanoNodeError(GeneralCardanoNodeErrorCode.ConnectionFailure, null, 'Timeout'))
  });

const withShutdown = <T>(shuttingDown$: Observable<void>): MonoTypeOperatorFunction<T> =>
  pipe(
    // Cancel ongoing requests when shutting down
    takeUntil(shuttingDown$),
    // Promises require a response, so throw if the observable completes without emitting a value due to a shutdown
    throwIfEmpty(
      () =>
        new GeneralCardanoNodeError(
          GeneralCardanoNodeErrorCode.ServerNotReady,
          null,
          'OgmiosCardanoNode is shutting down.'
        )
    )
  );

/**
 * Access cardano-node APIs via Ogmios
 *
 * @class OgmiosCardanoNode
 */
export class OgmiosCardanoNode extends RunnableModule implements CardanoNode {
  #ogmiosObservableCardanoNode: OgmiosObservableCardanoNode;
  #shuttingDown$: Subject<void>;

  constructor(ogmiosObservableCardanoNode: OgmiosObservableCardanoNode, logger: Logger) {
    super('OgmiosCardanoNode', logger);
    this.#ogmiosObservableCardanoNode = ogmiosObservableCardanoNode;
    this.#shuttingDown$ = new Subject<void>();
  }

  public async initializeImpl(): Promise<void> {
    return Promise.resolve();
  }

  public async shutdownImpl(): Promise<void> {
    this.#shuttingDown$.next();
    return Promise.resolve();
  }

  public async eraSummaries(): Promise<EraSummary[]> {
    this.#assertIsRunning();
    return firstValueFrom(
      this.#ogmiosObservableCardanoNode.eraSummaries$.pipe(withTimeout(), withShutdown(this.#shuttingDown$))
    );
  }

  public async systemStart(): Promise<Date> {
    this.#assertIsRunning();
    return firstValueFrom(
      this.#ogmiosObservableCardanoNode.systemStart$.pipe(withTimeout(), withShutdown(this.#shuttingDown$))
    );
  }

  public async stakeDistribution(): Promise<StakeDistribution> {
    this.#assertIsRunning();
    return firstValueFrom(
      this.#ogmiosObservableCardanoNode.stakeDistribution$.pipe(withTimeout(), withShutdown(this.#shuttingDown$))
    );
  }

  healthCheck(): Promise<HealthCheckResponse> {
    return firstValueFrom(
      this.#ogmiosObservableCardanoNode.healthCheck$.pipe(
        takeUntil(this.#shuttingDown$),
        defaultIfEmpty({ message: 'OgmiosCardanoNode is shutting down.', ok: false })
      )
    );
  }

  async startImpl(): Promise<void> {
    return Promise.resolve();
  }

  #assertIsRunning() {
    if (this.state !== 'running') {
      throw new GeneralCardanoNodeError(
        GeneralCardanoNodeErrorCode.ServerNotReady,
        null,
        'OgmiosCardanoNode is not running'
      );
    }
  }
}
