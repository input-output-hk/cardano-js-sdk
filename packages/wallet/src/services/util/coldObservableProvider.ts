import { Observable, from } from 'rxjs';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';

// TODO: use this when converting providers from functions to cold observables
export const coldObservableProvider = <T>(provider: () => Promise<T>, retryBackoffConfig: RetryBackoffConfig) =>
  new Observable<T>((subscriber) => {
    const promise = provider();
    const sub = from(promise).pipe(retryBackoff(retryBackoffConfig)).subscribe(subscriber);
    return () => sub.unsubscribe();
  });
