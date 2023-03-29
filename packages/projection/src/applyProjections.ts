/* eslint-disable @typescript-eslint/no-explicit-any, prefer-spread */
import { Observable } from 'rxjs';
import { ProjectionExtraProps } from './projections';
import { ProjectorOperator } from './types';
import uniq from 'lodash/uniq';

const uniqOperators = <P extends object>(projections: P): ProjectorOperator<any, any, any, any>[] =>
  uniq(Object.values(projections).flat());

export const applyProjections =
  <E, P extends object>(projections: P) =>
  (evt$: Observable<E>) =>
    evt$.pipe.apply(evt$, uniqOperators(projections) as any) as Observable<E & ProjectionExtraProps<P>>;
