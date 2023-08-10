export interface AccountBalanceModel {
  balance: string;
}

export interface RewardEpochModel {
  quantity: string;
  address: string;
  epoch: number;
  pool_id?: string;
}
