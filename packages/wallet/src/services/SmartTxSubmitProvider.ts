import {
  Cardano,
  HealthCheckResponse,
  ProviderError,
  ProviderFailure,
  SubmitTxArgs,
  TxSubmitProvider,
  cmlUtil
} from '@cardano-sdk/core';
import { ConnectionStatus, ConnectionStatusTracker } from './util';
import { Observable, combineLatest, filter, from, mergeMap, take, tap } from 'rxjs';
import { ObservableProvider } from '@cardano-sdk/util-rxjs';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';

export interface RetryingTxSubmitProviderProps {
  retryBackoffConfig: RetryBackoffConfig;
}

export type TipSlot = Pick<Cardano.Tip, 'slot'>;

export interface RetryingTxSubmitProviderDependencies {
  txSubmitProvider: ObservableProvider<TxSubmitProvider>;
  tip$: Observable<TipSlot>;
  connectionStatus$: ConnectionStatusTracker;
}

/**
 * Wraps a `TxSubmitProvider` to enhance it's `submitTx` with the following functionality:
 * - Immediately rejects if network tip is already >= `ValidityInterval.invalidHereafter`
 * - Awaits for the following conditions before submitting:
 *   - Network tip is ahead of tx body `ValidityInterval.invalidBefore`.
 *   - Connection status is 'up'.
 * - Re-submits transactions that failed to submit due to connection or recoverable provider issue.
 */
export class SmartTxSubmitProvider implements ObservableProvider<TxSubmitProvider> {
  readonly #txSubmitProvider: ObservableProvider<TxSubmitProvider>;
  readonly #tip$: Observable<TipSlot>;
  readonly #retryBackoffConfig: RetryBackoffConfig;
  readonly #connectionStatus$: ConnectionStatusTracker;

  constructor(
    { retryBackoffConfig }: RetryingTxSubmitProviderProps,
    { connectionStatus$, tip$, txSubmitProvider }: RetryingTxSubmitProviderDependencies
  ) {
    this.#txSubmitProvider = txSubmitProvider;
    this.#tip$ = tip$;
    this.#connectionStatus$ = connectionStatus$;
    this.#retryBackoffConfig = retryBackoffConfig;
  }

  submitTx(args: SubmitTxArgs): Observable<void> {
    return new Observable((observer) => {
      const {
        body: {
          validityInterval: { invalidBefore, invalidHereafter }
        }
      } = cmlUtil.deserializeTx(args.signedTransaction);
      const onlineAndWithinValidityInterval$ = combineLatest([this.#connectionStatus$, this.#tip$]).pipe(
        tap(([_, { slot }]) => {
          if (slot >= (invalidHereafter || Number.POSITIVE_INFINITY))
            throw new ProviderError(
              ProviderFailure.BadRequest,
              new Cardano.TxSubmissionErrors.OutsideOfValidityIntervalError({
                outsideOfValidityInterval: {
                  currentSlot: slot,
                  interval: { invalidBefore: invalidBefore || null, invalidHereafter: invalidHereafter || null }
                }
              })
            );
        }),
        filter(
          ([connectionStatus, { slot }]) => connectionStatus === ConnectionStatus.up && slot >= (invalidBefore || 0)
        ),
        take(1)
      );

      return onlineAndWithinValidityInterval$
        .pipe(
          mergeMap(() => from(this.#txSubmitProvider.submitTx(args))),
          retryBackoff({
            ...this.#retryBackoffConfig,
            shouldRetry: (error) =>
              error instanceof ProviderError &&
              [ProviderFailure.Unhealthy, ProviderFailure.ConnectionFailure, ProviderFailure.Unknown].includes(
                error.reason
              )
          })
        )
        .subscribe(observer);
    });
  }

  healthCheck(): Observable<HealthCheckResponse> {
    return this.#txSubmitProvider.healthCheck();
  }
}
