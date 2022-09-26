import {
  NEVER,
  Observable,
  concat,
  defer,
  distinctUntilChanged,
  from,
  mergeMap,
  of,
  switchMap,
  takeUntil,
  throwError
} from 'rxjs';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { strictEquals } from './equals';

export interface ColdObservableProviderProps<T> {
  provider: () => Promise<T>;
  retryBackoffConfig: RetryBackoffConfig;
  trigger$?: Observable<unknown>;
  equals?: (t1: T, t2: T) => boolean;
  combinator?: typeof switchMap;
  cancel$?: Observable<unknown>;
  pollUntil?: (v: T) => boolean;
}

export const coldObservableProvider = <T>({
  provider,
  retryBackoffConfig,
  trigger$ = of(true),
  equals = strictEquals,
  combinator = switchMap,
  cancel$ = NEVER,
  pollUntil = () => true
}: ColdObservableProviderProps<T>) =>
  new Observable<T>((subscriber) => {
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
          ).pipe(retryBackoff(retryBackoffConfig))
        ),
        distinctUntilChanged(equals),
        takeUntil(cancel$)
      )
      .subscribe(subscriber);
    return () => sub.unsubscribe();
  });
