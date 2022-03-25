import { Observable, distinctUntilChanged, from, of, switchMap } from 'rxjs';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { strictEquals } from './equals';

export const coldObservableProvider = <T>(
  provider: () => Promise<T>,
  retryBackoffConfig: RetryBackoffConfig,
  trigger$: Observable<unknown> = of(true),
  equals: (t1: T, t2: T) => boolean = strictEquals,
  combinator = switchMap
) =>
  new Observable<T>((subscriber) => {
    const sub = trigger$
      .pipe(
        combinator(() => from(provider()).pipe(retryBackoff(retryBackoffConfig))),
        distinctUntilChanged(equals)
      )
      .subscribe(subscriber);
    return () => sub.unsubscribe();
  });
