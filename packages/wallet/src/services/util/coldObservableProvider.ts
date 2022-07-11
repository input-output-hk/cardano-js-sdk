import { NEVER, Observable, distinctUntilChanged, from, of, switchMap, takeUntil } from 'rxjs';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { strictEquals } from './equals';

export interface ColdObservableProviderProps<T> {
  provider: () => Promise<T>;
  retryBackoffConfig: RetryBackoffConfig;
  trigger$?: Observable<unknown>;
  equals?: (t1: T, t2: T) => boolean;
  combinator?: typeof switchMap;
  cancel$?: Observable<unknown>;
}

export const coldObservableProvider = <T>({
  provider,
  retryBackoffConfig,
  trigger$ = of(true),
  equals = strictEquals,
  combinator = switchMap,
  cancel$ = NEVER
}: ColdObservableProviderProps<T>) =>
  new Observable<T>((subscriber) => {
    const sub = trigger$
      .pipe(
        combinator(() => from(provider()).pipe(retryBackoff(retryBackoffConfig))),
        distinctUntilChanged(equals),
        takeUntil(cancel$)
      )
      .subscribe(subscriber);
    return () => sub.unsubscribe();
  });
