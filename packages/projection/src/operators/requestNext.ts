import { OperatorFunction, map, tap } from 'rxjs';
import { RequestNext } from '@cardano-sdk/core';
import omit from 'lodash/omit';

export interface WithRequestNext {
  requestNext: RequestNext;
}

/**
 * Calls event.requestNext() and emits event object without this method
 */
export const requestNext =
  <In extends WithRequestNext>(): OperatorFunction<In, Omit<In, 'requestNext'>> =>
  // eslint-disable-next-line unicorn/consistent-function-scoping
  (evt$) =>
    evt$.pipe(
      tap((e) => e.requestNext()),
      map((e) => omit(e, 'requestNext'))
    );
