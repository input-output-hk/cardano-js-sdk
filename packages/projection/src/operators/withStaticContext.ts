import { ExtChainSyncOperator } from '../types';
import { Observable, isObservable, of } from 'rxjs';
import { blockingWithLatestFrom } from '@cardano-sdk/util-rxjs';

/** Extend events with custom context (created before the 1st event is emitted) */
export const withStaticContext = <TContext, ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn>(
  context: TContext | Observable<TContext>
): ExtChainSyncOperator<ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn, TContext, TContext> => {
  const context$ = isObservable(context) ? context : of(context);
  return (evt$) => evt$.pipe(blockingWithLatestFrom(context$, (evt, ctx) => ({ ...evt, ...ctx })));
};
