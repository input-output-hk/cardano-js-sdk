import { EMPTY, Observable, combineLatest, map, mergeMap, of, pairwise, startWith } from 'rxjs';
import { Equals } from './equals';

const START = {};

/**
 * Mirrors source observable, but delays 1 emission after each `trigger$`
 * until 'source$' emits an updated value (equality determined by `equals` arg).
 *
 * @param trigger$ each emission is a marker of when to expect a distinct value
 * @param equals previous value (at the time of trigger$) is the 1st argument
 * @returns rxjs operator
 */
export const oneDistinctAfterTrigger =
  <T>(trigger$: Observable<unknown>, equals: Equals<T>) =>
  (source$: Observable<T>) => {
    let lastTrigger: { triggerNo: number; value: T } | undefined;
    return combineLatest([
      source$.pipe(startWith(START as unknown as T)),
      trigger$.pipe(
        startWith(null),
        map((_, i) => i)
      )
    ]).pipe(
      pairwise(),
      mergeMap(([[prevValue, prevTriggerNo], [value, triggerNo]]) => {
        if (value === START) return EMPTY;
        if (prevValue !== START && triggerNo !== prevTriggerNo) {
          lastTrigger = { triggerNo, value };
        }
        if (lastTrigger) {
          if (equals(lastTrigger.value, value)) return EMPTY;
          lastTrigger = undefined;
        }

        return of(value);
      })
    );
  };
