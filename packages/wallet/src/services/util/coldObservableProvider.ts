import { Observable, distinctUntilChanged, from, of, switchMap } from 'rxjs';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { strictEquals } from './equals';

export interface ColdObservableProviderProps<T> {
  provider: () => Promise<T>;
  retryBackoffConfig: RetryBackoffConfig;
  trigger$?: Observable<unknown>;
  equals?: (t1: T, t2: T) => boolean;
  combinator?: typeof switchMap;
}

export const coldObservableProvider = <T>({
  provider,
  retryBackoffConfig,
  trigger$ = of(true),
  equals = strictEquals,
  combinator = switchMap
}: ColdObservableProviderProps<T>) =>
  new Observable<T>((subscriber) => {
    const sub = trigger$
      .pipe(
        combinator(() => from(provider()).pipe(retryBackoff(retryBackoffConfig))),
        distinctUntilChanged(equals)
      )
      .subscribe(subscriber);
    return () => sub.unsubscribe();
  });
