import { InvalidStringError, strictEquals } from '@cardano-sdk/util';
import { Logger } from 'ts-log';
import {
  NEVER,
  Observable,
  Subject,
  catchError,
  concat,
  defer,
  distinctUntilChanged,
  from,
  merge,
  mergeMap,
  of,
  switchMap,
  takeUntil,
  throwError
} from 'rxjs';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';

export interface PollProps<T> {
  sample: () => Promise<T>;
  retryBackoffConfig: RetryBackoffConfig;
  onFatalError?: (value: unknown) => void;
  trigger$?: Observable<unknown>;
  equals?: (t1: T, t2: T) => boolean;
  combinator?: typeof switchMap;
  cancel$?: Observable<unknown>;
  pollUntil?: (v: T) => boolean;
  logger: Logger;
}

export const poll = <T>({
  sample,
  retryBackoffConfig,
  onFatalError,
  trigger$ = of(true),
  equals = strictEquals,
  combinator = switchMap,
  cancel$ = NEVER,
  pollUntil = () => true,
  logger
}: PollProps<T>) =>
  new Observable<T>((subscriber) => {
    const cancelOnFatalError$ = new Subject<boolean>();
    const internalCancel$ = merge(cancel$, cancelOnFatalError$);
    const sub = trigger$
      .pipe(
        combinator(() =>
          defer(() =>
            from(sample()).pipe(
              mergeMap((v) =>
                pollUntil(v)
                  ? of(v)
                  : // Emit value, but also throw error to force retryBackoff to kick in
                    concat(
                      of(v),
                      throwError(() => new Error('polling'))
                    )
              )
            )
          ).pipe(
            retryBackoff({
              ...retryBackoffConfig,
              shouldRetry: (error) => {
                logger.error(error);

                if (retryBackoffConfig.shouldRetry) {
                  const shouldRetry = retryBackoffConfig.shouldRetry(error);
                  logger.debug(`Should retry: ${shouldRetry}`);

                  if (!shouldRetry) {
                    return false;
                  }
                }

                if (error instanceof InvalidStringError) {
                  onFatalError?.(error);
                  cancelOnFatalError$.next(true);
                  return false;
                }

                return true;
              }
            }),
            catchError((error) => {
              onFatalError?.(error);

              // Re-throw the error to propagate it to the subscriber and complete the observable
              return throwError(() => error);
            })
          )
        ),
        distinctUntilChanged(equals),
        takeUntil(internalCancel$)
      )
      .subscribe(subscriber);

    return () => {
      sub.unsubscribe();
      cancelOnFatalError$.complete();
    };
  });
