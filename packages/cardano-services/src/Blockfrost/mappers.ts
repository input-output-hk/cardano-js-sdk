import type { FirstUpdateAfterBlock, FirstUpdateAfterBlockModel } from './types.js';

export const mapFirstUpdateAfterBlock = ({ active_epoch_no }: FirstUpdateAfterBlockModel): FirstUpdateAfterBlock => ({
  epoch_no: Number(active_epoch_no)
});
