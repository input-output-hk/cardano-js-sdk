import { Cardano, createSlotEpochCalc } from '@cardano-sdk/core';
import { WithNetworkInfo } from './withNetworkInfo';
import { unifiedProjectorOperator } from './utils';

export type WithEpochNo = { epochNo: Cardano.EpochNo };

/**
 * Adds current 'epochNo' of 'block' to each event
 */
export const withEpochNo = unifiedProjectorOperator<Pick<WithNetworkInfo, 'eraSummaries'>, WithEpochNo>((evt) => {
  const slotEpochCalc = createSlotEpochCalc(evt.eraSummaries);
  return { ...evt, epochNo: slotEpochCalc(evt.block.header.slot) };
});
