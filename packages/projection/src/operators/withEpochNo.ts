import { createSlotEpochCalc } from '@cardano-sdk/core';
import { unifiedProjectorOperator } from './utils/index.js';
import type { WithEpochNo, WithNetworkInfo } from '../types.js';

/** Adds current 'epochNo' of 'block' to each event */
export const withEpochNo = unifiedProjectorOperator<Pick<WithNetworkInfo, 'eraSummaries'>, WithEpochNo>((evt) => {
  const slotEpochCalc = createSlotEpochCalc(evt.eraSummaries);
  return { ...evt, epochNo: slotEpochCalc(evt.block.header.slot) };
});
