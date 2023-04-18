import { OperatorFunction, tap } from 'rxjs';
import { ProjectionEvent } from '../../types';
import { WithInMemoryStore } from '../types';

export const inMemoryStoreOperator =
  <ExtraProps>(op: (evt: ProjectionEvent<ExtraProps & WithInMemoryStore>) => void) =>
  <E extends ProjectionEvent<ExtraProps & WithInMemoryStore>>(): OperatorFunction<E, E> =>
  // eslint-disable-next-line unicorn/consistent-function-scoping
  (evt$) =>
    evt$.pipe(tap((e) => op(e)));
