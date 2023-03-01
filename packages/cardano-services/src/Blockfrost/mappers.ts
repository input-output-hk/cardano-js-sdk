import { FirstUpdateAfterBlock, FirstUpdateAfterBlockModel } from './types';

export const mapFirstUpdateAfterBlock = ({ active_epoch_no }: FirstUpdateAfterBlockModel): FirstUpdateAfterBlock => ({
  epoch_no: Number(active_epoch_no)
});
