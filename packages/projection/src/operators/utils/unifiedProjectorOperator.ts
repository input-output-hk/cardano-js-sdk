import { MaybeObservable } from './types';
import { RollBackwardEvent, RollForwardEvent, WithBlock } from '../../types';
import { concatMap, isObservable, of } from 'rxjs';
import { inferProjectorEventType } from './inferProjectorEventType';
import memoize from 'lodash/memoize';

export type UnifiedEventHandler<PropsIn, PropsOut> = (
  evt: RollForwardEvent<PropsIn> | RollBackwardEvent<PropsIn & WithBlock>
) => MaybeObservable<RollForwardEvent<PropsOut> | RollBackwardEvent<PropsOut & WithBlock>>;

/**
 * Convenience utility to create an operator that works the same with both RollForward and RollBackward events.
 */
export const unifiedProjectorOperator = memoize(<PropsIn, PropsOut>(handler: UnifiedEventHandler<PropsIn, PropsOut>) =>
  inferProjectorEventType<PropsIn, PropsIn & WithBlock, PropsOut, PropsOut>((evt$) =>
    evt$.pipe(
      concatMap((evt) => {
        const result = handler(evt);
        return isObservable(result) ? result : of(result);
      })
    )
  )
);
