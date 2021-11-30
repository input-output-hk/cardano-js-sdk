import { Lovelace, PoolId } from '.';

export interface DelegationsAndRewards {
  delegate?: PoolId;
  rewards: Lovelace;
}
