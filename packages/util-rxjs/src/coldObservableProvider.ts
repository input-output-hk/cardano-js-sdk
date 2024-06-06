import { InvalidStringError, strictEquals } from '@cardano-sdk/util';
import {
  NEVER,
  Observable,
  Subject,
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
import { retryBackoff } from 'backoff-rxjs';
import type { RetryBackoffConfig } from 'backoff-rxjs';

export interface ColdObservableProviderProps<T> {
  provider: () => Promise<T>;
  retryBackoffConfig: RetryBackoffConfig;
  onFatalError?: (value: unknown) => void;
  trigger$?: Observable<unknown>;
  equals?: (t1: T, t2: T) => boolean;
  combinator?: typeof switchMap;
  cancel$?: Observable<unknown>;
  pollUntil?: (v: T) => boolean;
}

export const coldObservableProvider = <T>({
  provider,
  retryBackoffConfig,
  onFatalError,
  trigger$ = of(true),
  equals = strictEquals,
  combinator = switchMap,
  cancel$ = NEVER,
  pollUntil = () => true
}: ColdObservableProviderProps<T>) =>
  new Observable<T>((subscriber) => {
    const cancelOnFatalError$ = new Subject<boolean>();
    const internalCancel$ = merge(cancel$, cancelOnFatalError$);
    const sub = trigger$
      .pipe(
        combinator(() =>
          defer(() =>
            from(provider()).pipe(
              mergeMap((v) =>
                pollUntil(v)
                  ? of(v)
                  : // emit value, but also throw error to force retryBackoff to kick in
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
                if (retryBackoffConfig.shouldRetry && !retryBackoffConfig.shouldRetry(error)) return false;

                if (error instanceof InvalidStringError) {
                  onFatalError?.(error);
                  cancelOnFatalError$.next(true);
                }

                return true;
              }
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
