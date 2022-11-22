import { Observable, isObservable, map, mergeMap, of } from 'rxjs';
import { ProjectorEvent, ProjectorOperator } from '../types';
import memoize from 'lodash/memoize';

/**
 * Extend events with custom context (created per event)
 */
export const withEventContext = memoize(
  <TContext, ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn>(
      createContext: (
        evt: ProjectorEvent<ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn>
      ) => TContext | Observable<TContext>
    ): ProjectorOperator<ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn, TContext, TContext> =>
    (evt$) =>
      evt$.pipe(
        mergeMap((evt) => {
          let context$ = createContext(evt);
          if (!isObservable(context$)) {
            context$ = of(context$);
          }
          return context$.pipe(map((ctx) => ({ ...evt, ...ctx })));
        })
      )
);
