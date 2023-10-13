import { Observable } from 'rxjs';

/**
 * @returns an Observable that proxies subscriptions to observables provided as arguments.
 * Arguments are subscribed to in order they are provided.
 */
export const createStubObservable = <T>(...calls: Observable<T>[]) => {
  let numCall = 0;
  return new Observable<T>((subscriber) => {
    const sub = calls[numCall++].subscribe(subscriber);
    return () => sub.unsubscribe();
  });
};
