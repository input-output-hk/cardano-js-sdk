/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable func-style */
import {
  Observable,
  OperatorFunction,
  buffer,
  delay,
  merge,
  mergeAll,
  share,
  skipUntil,
  take,
  withLatestFrom
} from 'rxjs';

export function blockingWithLatestFrom<T, O>(dependency$: Observable<O>): OperatorFunction<T, [T, O]>;
export function blockingWithLatestFrom<T, O, R>(
  dependency$: Observable<O>,
  combinator: (...value: [T, O]) => R
): OperatorFunction<T, R>;

/**
 * Like withLatestFrom, but waits for first emission from `dependency$`
 * in order to not lose any emissions from source.
 */
export function blockingWithLatestFrom<T, R>(
  dependency$: Observable<any>,
  combinator = (a: any, b: any) => [a, b]
): OperatorFunction<T, R | any[]> {
  return (source$: Observable<T>) => {
    const sharedDependency$ = dependency$.pipe(share());
    // delay(1) is needed in case dependency$ resolves instantly.
    // in that case both merge() items emit.
    const firstDependency$ = sharedDependency$.pipe(delay(1), take(1));
    const sharedSource$ = source$.pipe(share());
    return merge(
      // Emit values up until dependency$ first emits
      // 'buffer' will emit once and complete, also completing source subscription
      // 'mergeAll' is equivalent to mergeMap((array) => from(array))
      sharedSource$.pipe(buffer(firstDependency$), mergeAll()),
      // Emit values since dependency$ first emission
      sharedSource$.pipe(skipUntil(firstDependency$))
    ).pipe(withLatestFrom(sharedDependency$, combinator));
  };
}
