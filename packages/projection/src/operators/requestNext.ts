import { map, tap } from 'rxjs';
import omit from 'lodash/omit.js';
import type { OperatorFunction } from 'rxjs';
import type { WithRequestNext } from '@cardano-sdk/core';

/** Calls event.requestNext() and emits event object without this method */
export const requestNext =
  <In extends WithRequestNext>(): OperatorFunction<In, Omit<In, 'requestNext'>> =>
  // eslint-disable-next-line unicorn/consistent-function-scoping
  (evt$) =>
    evt$.pipe(
      tap((e) => e.requestNext()),
      map((e) => omit(e, 'requestNext'))
    );
