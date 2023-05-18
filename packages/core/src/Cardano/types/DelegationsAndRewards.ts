import { Lovelace } from './Value';
import { PoolId, StakePool } from './StakePool';
import { RewardAccount } from '../Address';

export interface DelegationsAndRewards {
  delegate?: PoolId;
  rewards: Lovelace;
}

export interface Delegatee {
  /**
   * Rewards at the end of current epoch will
   * be from this stake pool
   */
  currentEpoch?: StakePool;
  nextEpoch?: StakePool;
  nextNextEpoch?: StakePool;
}

export enum StakeKeyStatus {
  Registering = 'REGISTERING',
  Registered = 'REGISTERED',
  Unregistering = 'UNREGISTERING',
  Unregistered = 'UNREGISTERED'
}

export interface RewardAccountInfo {
  address: RewardAccount;
  keyStatus: StakeKeyStatus;
  delegatee?: Delegatee;
  rewardBalance: Lovelace;
  // Maybe add rewardsHistory for each reward account too
}
