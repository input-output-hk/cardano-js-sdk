import { Observable, ReplaySubject, defer, finalize } from 'rxjs';
import { retryBackoff } from 'backoff-rxjs';
import type { OperatorFunction } from 'rxjs';
import type { RetryBackoffConfig } from 'backoff-rxjs';

const defaultRetryBackoffConfig: RetryBackoffConfig = { initialInterval: 10, maxInterval: 5000, resetOnSuccess: true };

/**
 * Subscribes to source observable once and wraps `operator` with retry logic based on provided `retryBackoffConfig`.
 * Calls `operator` function on each retry, causing it to re-subscribe to it's source, which re-emits
 * the last emitted value (the one which caused the error).
 *
 * @param operator re-subscribed on retry
 * @param retryBackoffConfig by default { initialInterval: 10, maxInterval: 5000, resetOnSuccess: true }
 */
export const shareRetryBackoff =
  <In, Out>(
    operator: OperatorFunction<In, Out>,
    retryBackoffConfig?: Partial<RetryBackoffConfig>
  ): OperatorFunction<In, Out> =>
  (evt$) => {
    const subject$ = new ReplaySubject<In>(1);
    const sourceSubscription = evt$.subscribe(subject$);
    return new Observable((observer) =>
      subject$
        .pipe(
          (source$) => defer(() => operator(source$)),
          // This will re-subscribe all the way up to subject$,
          // which will re-emit the last event without re-subscribing to source event.
          retryBackoff({
            ...defaultRetryBackoffConfig,
            ...retryBackoffConfig
          }),
          finalize(() => {
            sourceSubscription.unsubscribe();
          })
        )
        .subscribe(observer)
    );
  };
