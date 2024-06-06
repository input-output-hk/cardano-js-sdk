import { concatMap, isObservable, of } from 'rxjs';
import { inferProjectorEventType } from './inferProjectorEventType.js';
import type { MaybeObservable } from './types.js';
import type { RollBackwardEvent, RollForwardEvent, WithBlock } from '../../types.js';

export type UnifiedEventHandler<PropsIn, PropsOut> = (
  evt: RollForwardEvent<PropsIn> | RollBackwardEvent<PropsIn & WithBlock>
) => MaybeObservable<RollForwardEvent<PropsOut> | RollBackwardEvent<PropsOut & WithBlock>>;

/** Convenience utility to create an operator that works the same with both RollForward and RollBackward events. */
export const unifiedProjectorOperator = <PropsIn, PropsOut = PropsIn>(
  handler: UnifiedEventHandler<PropsIn, PropsOut>
) =>
  inferProjectorEventType<PropsIn, PropsIn & WithBlock, PropsOut, PropsOut>((evt$) =>
    evt$.pipe(
      concatMap((evt) => {
        const result = handler(evt);
        return isObservable(result) ? result : of(result);
      })
    )
  );
