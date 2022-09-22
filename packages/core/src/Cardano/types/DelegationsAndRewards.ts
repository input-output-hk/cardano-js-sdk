import { Lovelace } from './Value';
import { PoolId } from './StakePool';

export interface DelegationsAndRewards {
  delegate?: PoolId;
  rewards: Lovelace;
}
