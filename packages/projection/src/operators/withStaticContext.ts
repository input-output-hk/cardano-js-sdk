import { Observable, isObservable, of } from 'rxjs';
import { ProjectorOperator } from '../types';
import { blockingWithLatestFrom } from '@cardano-sdk/util-rxjs';
import memoize from 'lodash/memoize';

/**
 * Extend events with custom context (created before the 1st event is emitted)
 */
export const withStaticContext = memoize(
  <TContext, ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn>(
    context: TContext | Observable<TContext>
  ): ProjectorOperator<ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn, TContext, TContext> => {
    const context$ = isObservable(context) ? context : of(context);
    return (evt$) => evt$.pipe(blockingWithLatestFrom(context$, (evt, ctx) => ({ ...evt, ...ctx })));
  }
);
