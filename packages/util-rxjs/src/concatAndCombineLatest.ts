import { combineLatest, concat, ignoreElements, of, share, take } from 'rxjs';
import type { Observable } from 'rxjs';

/** Subscribe to o$ after trigger$ emits its first value */
const startOnTrigger = <A, B>(trigger$: Observable<A>, o$: Observable<B>) =>
  concat(trigger$.pipe(take(1), ignoreElements()), o$);

/**
 * Creates a new observable that:
 *   - acts like `combineLatest` for the input `args` observables
 *   - unlike `combineLatest` it starts the observables in a sequence, like concat
 *   - unlike `concat`, it does not wait for the previous one to complete,
 *     instead it starts the next observable when the previous one emits the first value
 */
export const concatAndCombineLatest = <T>(obsArray: Observable<T>[]): Observable<T[]> => {
  if (obsArray.length === 0) {
    return of([]);
  }

  // Build an array of observables, where each item in the array starts only when the previous one emitted the first value
  const observableCascadeArray: Observable<T>[] = [];
  // Share the observable to be used as source and as trigger
  let sharedTrigger$ = obsArray[0].pipe(share());
  observableCascadeArray.push(sharedTrigger$);
  for (const o$ of obsArray.slice(1)) {
    // next o$ starts only after sharedTrigger$ emitted once
    const triggeredO$ = startOnTrigger(sharedTrigger$, o$);
    // triggerO$ will be a source and a trigger for the next one, thus cascading the observables
    sharedTrigger$ = triggeredO$.pipe(share());
    observableCascadeArray.push(sharedTrigger$);
  }
  return combineLatest(observableCascadeArray);
};
