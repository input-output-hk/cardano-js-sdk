import { tap } from 'rxjs';
import type { OperatorFunction } from 'rxjs';
import type { ProjectionEvent } from '../../types.js';
import type { WithInMemoryStore } from '../types.js';

export const inMemoryStoreOperator =
  <ExtraProps>(op: (evt: ProjectionEvent<ExtraProps & WithInMemoryStore>) => void) =>
  <E extends ProjectionEvent<ExtraProps & WithInMemoryStore>>(): OperatorFunction<E, E> =>
  // eslint-disable-next-line unicorn/consistent-function-scoping
  (evt$) =>
    evt$.pipe(tap((e) => op(e)));
