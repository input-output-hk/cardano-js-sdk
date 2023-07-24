import { Lovelace } from './Value';
import { PoolId, PoolIdHex, StakePool } from './StakePool';
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

export interface Cip17Pool {
  id: PoolIdHex;
  weight: number;
  name?: string;
  ticker?: string;
}
export interface Cip17DelegationPortfolio {
  name: string;
  pools: Cip17Pool[];
  description?: string;
  author?: string;
}
