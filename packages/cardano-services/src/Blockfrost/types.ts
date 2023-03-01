export interface CurrentEpochModel {
  epoch_no: number;
}

export interface FirstUpdateAfterBlock {
  epoch_no: number;
}

export interface FirstUpdateAfterBlockModel {
  active_epoch_no: string;
}

export interface LastRetireModel {
  block_no: number;
  retiring_epoch: number;
}

export interface PoolsModel {
  id: string;
  view: string;
}
