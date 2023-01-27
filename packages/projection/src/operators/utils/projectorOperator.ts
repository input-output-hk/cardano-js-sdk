import { ChainSyncEventType } from '@cardano-sdk/core';
import { MaybeObservable } from './types';
import { RollBackwardEvent, RollForwardEvent } from '../../types';
import { concatMap, isObservable, of } from 'rxjs';
import { inferProjectorEventType } from './inferProjectorEventType';
import memoize from 'lodash/memoize';

export interface ProjectorEventHandlers<
  ExtraRollForwardPropsIn,
  ExtraRollBackwardPropsIn,
  ExtraRollForwardPropsOut = ExtraRollForwardPropsIn,
  ExtraRollBackwardPropsOut = ExtraRollBackwardPropsIn
> {
  rollForward: (
    evt: RollForwardEvent<ExtraRollForwardPropsIn>
  ) => MaybeObservable<RollForwardEvent<ExtraRollForwardPropsOut>>;
  rollBackward: (
    evt: RollBackwardEvent<ExtraRollBackwardPropsIn>
  ) => MaybeObservable<RollBackwardEvent<ExtraRollBackwardPropsOut>>;
}

/**
 * Convenience utility to create an operator with separate 'rollForward' and 'rollBackward' handlers
 */
export const projectorOperator = memoize(
  <ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn, ExtraRollForwardPropsOut, ExtraRollBackwardPropsOut>({
    rollForward,
    rollBackward
  }: ProjectorEventHandlers<
    ExtraRollForwardPropsIn,
    ExtraRollBackwardPropsIn,
    ExtraRollForwardPropsOut,
    ExtraRollBackwardPropsOut
  >) =>
    inferProjectorEventType<
      ExtraRollForwardPropsIn,
      ExtraRollBackwardPropsIn,
      ExtraRollForwardPropsOut,
      ExtraRollBackwardPropsOut
    >((evt$) =>
      evt$.pipe(
        concatMap((evt) => {
          const result = evt.eventType === ChainSyncEventType.RollForward ? rollForward(evt) : rollBackward(evt);
          return isObservable(result) ? result : of(result);
        })
      )
    )
);
