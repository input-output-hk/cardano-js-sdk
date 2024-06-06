import { isObservable, map, mergeMap, of } from 'rxjs';
import type { ExtChainSyncEvent, ExtChainSyncOperator } from '../types.js';
import type { Observable } from 'rxjs';

/** Extend events with custom context (created per event) */
export const withEventContext =
  <TContext, ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn>(
    createContext: (
      evt: ExtChainSyncEvent<ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn>
    ) => TContext | Observable<TContext>
  ): ExtChainSyncOperator<ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn, TContext, TContext> =>
  (evt$) =>
    evt$.pipe(
      mergeMap((evt) => {
        let context$ = createContext(evt);
        if (!isObservable(context$)) {
          context$ = of(context$);
        }
        return context$.pipe(map((ctx) => ({ ...evt, ...ctx })));
      })
    );
