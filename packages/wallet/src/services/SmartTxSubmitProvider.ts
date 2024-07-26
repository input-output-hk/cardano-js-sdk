/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  Cardano,
  CardanoNodeUtil,
  HealthCheckResponse,
  OutsideOfValidityIntervalData,
  ProviderError,
  ProviderFailure,
  SubmitTxArgs,
  TxSubmissionError,
  TxSubmissionErrorCode,
  TxSubmitProvider,
  deserializeTx
} from '@cardano-sdk/core';
import { ConnectionStatus, ConnectionStatusTracker } from './util';
import { Observable, combineLatest, filter, firstValueFrom, from, mergeMap, take, tap } from 'rxjs';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';

export interface RetryingTxSubmitProviderProps {
  retryBackoffConfig: RetryBackoffConfig;
}

export type TipSlot = Pick<Cardano.Tip, 'slot'>;

export interface RetryingTxSubmitProviderDependencies {
  txSubmitProvider: TxSubmitProvider;
  tip$: Observable<TipSlot>;
  connectionStatus$: ConnectionStatusTracker;
}

/**
 * Wraps a `TxSubmitProvider` to enchance it's `submitTx` with the following functionality:
 * - Immediately rejects if network tip is already >= `ValidityInterval.invalidHereafter`
 * - Awaits for the following conditions before submitting:
 *   - Network tip is ahead of tx body `ValidityInterval.invalidBefore`.
 *   - Connection status is 'up'.
 * - Re-submits transactions that failed to submit due to connection or recoverable provider issue.
 */
export class SmartTxSubmitProvider implements TxSubmitProvider {
  readonly #txSubmitProvider: TxSubmitProvider;
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

  submitTx(args: SubmitTxArgs): Promise<void> {
    const {
      body: { validityInterval }
    } = deserializeTx(args.signedTransaction);

    const onlineAndWithinValidityInterval$ = combineLatest([this.#connectionStatus$, this.#tip$]).pipe(
      tap(([_, { slot }]) => {
        if (slot >= (validityInterval?.invalidHereafter || Number.POSITIVE_INFINITY)) {
          const data: OutsideOfValidityIntervalData = {
            currentSlot: slot,
            validityInterval: {
              invalidBefore: validityInterval?.invalidBefore,
              invalidHereafter: validityInterval?.invalidHereafter
            }
          };
          throw new ProviderError(
            ProviderFailure.BadRequest,
            new TxSubmissionError(
              TxSubmissionErrorCode.OutsideOfValidityInterval,
              data,
              'Not submitting transaction due to validity interval'
            )
          );
        }
      }),
      filter(
        ([connectionStatus, { slot }]) =>
          connectionStatus === ConnectionStatus.up && slot >= (validityInterval?.invalidBefore || 0)
      ),
      take(1)
    );
    return firstValueFrom(
      onlineAndWithinValidityInterval$.pipe(
        mergeMap(() => from(this.#txSubmitProvider.submitTx(args))),
        retryBackoff({
          ...this.#retryBackoffConfig,
          shouldRetry: (error) =>
            CardanoNodeUtil.isProviderError(error) &&
            [ProviderFailure.Unhealthy, ProviderFailure.ConnectionFailure].includes(error.reason)
        })
      )
    );
  }

  healthCheck(): Promise<HealthCheckResponse> {
    return this.#txSubmitProvider.healthCheck();
  }
}
