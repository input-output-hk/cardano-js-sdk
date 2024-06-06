/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable func-style */
import {
  combineLatest,
  defaultIfEmpty,
  delay,
  distinctUntilKeyChanged,
  filter,
  from,
  last,
  map,
  mergeScan,
  of,
  share,
  startWith,
  takeUntil
} from 'rxjs';
import { isNotNil } from '@cardano-sdk/util';
import type { Observable, OperatorFunction } from 'rxjs';

const EMPTY_DEPENDENCY = Symbol('EMPTY');

export function blockingWithLatestFrom<T, O>(dependency$: Observable<O>): OperatorFunction<T, [T, O]>;
export function blockingWithLatestFrom<T, O, R>(
  dependency$: Observable<O>,
  combinator: (...value: [T, O]) => R
): OperatorFunction<T, R>;

/** Like withLatestFrom, but waits for first emission from `dependency$` in order to not lose any emissions from source. */
export function blockingWithLatestFrom<T, R>(
  dependency$: Observable<any>,
  combinator = (a: any, b: any) => [a, b]
): OperatorFunction<T, R | any[]> {
  const accumulator = {
    buffer: [] as T[],
    output: null as [T, any] | null
  };
  type Accumulator = typeof accumulator;

  return (source$: Observable<T>) => {
    const sharedSource$ = source$.pipe(share());
    return combineLatest([
      sharedSource$,
      dependency$.pipe(
        startWith(EMPTY_DEPENDENCY),
        takeUntil(sharedSource$.pipe(defaultIfEmpty(null), delay(1), last()))
      )
    ]).pipe(
      mergeScan(
        ({ buffer }: Accumulator, output): Observable<Accumulator> => {
          // add source values to buffer until dependency$ emits
          if (output[1] === EMPTY_DEPENDENCY) {
            return of({
              buffer: [...buffer, output[0]],
              output: null
            });
          }
          if (buffer.length > 0) {
            const lastItem = buffer[buffer.length - 1];
            const items = lastItem === output[0] ? buffer : [...buffer, output[0]];
            // emit values from buffer and the current value
            return from(
              items.map((sourceValue) => ({
                buffer: [],
                output: [sourceValue, output[1]] as [T, any]
              }))
            );
          }
          return of({
            buffer: [],
            output
          });
        },
        accumulator,
        // Unlimited concurrency can mess up the order of source values:
        // if source emits during emission of from(buffer), then the new
        // item from source can end up being emitted in-between buffer items.
        1
      ),
      map(({ output }) => output),
      filter(isNotNil),
      // only emitting when source item changes
      distinctUntilKeyChanged(0),
      map(([sourceValue, dependency]) => combinator(sourceValue, dependency))
    );
  };
}
