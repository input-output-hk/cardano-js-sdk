import { WithEpochNo, WithNetworkInfo } from '../types';
import { createSlotEpochCalc } from '@cardano-sdk/core';
import { unifiedProjectorOperator } from './utils';

/**
 * Adds current 'epochNo' of 'block' to each event
 */
export const withEpochNo = unifiedProjectorOperator<Pick<WithNetworkInfo, 'eraSummaries'>, WithEpochNo>((evt) => {
  const slotEpochCalc = createSlotEpochCalc(evt.eraSummaries);
  return { ...evt, epochNo: slotEpochCalc(evt.block.header.slot) };
});
