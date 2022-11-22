import { Cardano, ChainSyncEventType, EraSummary, createSlotEpochCalc } from '@cardano-sdk/core';
import { ProjectorOperator } from '../types';
import { map } from 'rxjs';

export type WithEpochNo = { epochNo: Cardano.EpochNo };

/**
 * Adds current 'epochNo' to each RollForward event
 */
export const withEpochNo = <ExtraRollForwardProps, ExtraRollBackwardProps>(eraSummaries: EraSummary[]) => {
  const slotEpochCalc = createSlotEpochCalc(eraSummaries);
  return ((evt$) =>
    evt$.pipe(
      map((evt) =>
        evt.eventType === ChainSyncEventType.RollForward
          ? { ...evt, epochNo: slotEpochCalc(evt.block.header.slot) }
          : evt
      )
    )) as ProjectorOperator<ExtraRollForwardProps, ExtraRollBackwardProps, WithEpochNo, {}>;
};
