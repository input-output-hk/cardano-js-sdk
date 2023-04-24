import { ChainSyncEventType } from '@cardano-sdk/core';
import { MaybeObservable } from './types';
import { RollBackwardEvent, RollForwardEvent } from '../../types';
import { concatMap, isObservable, of } from 'rxjs';
import { inferProjectorEventType } from './inferProjectorEventType';

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
export const projectorOperator = <
  ExtraRollForwardPropsIn,
  ExtraRollBackwardPropsIn,
  ExtraRollForwardPropsOut,
  ExtraRollBackwardPropsOut
>({
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
  );
