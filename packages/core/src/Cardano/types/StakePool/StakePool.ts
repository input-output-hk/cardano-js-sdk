import { Epoch, Lovelace, TransactionId } from '..';
import { PoolIdHex } from './primitives';
import { PoolParameters } from './PoolParameters';

/**
 * Within range [0; 1]
 */
export type Percent = number;

export interface StakePoolMetricsStake {
  live: Lovelace;
  active: Lovelace;
}

export interface StakePoolMetricsSize {
  live: Percent;
  active: Percent;
}
export interface StakePoolMetrics {
  /**
   * Total blocks created by the pool
   */
  blocksCreated: number;
  livePledge: Lovelace;
  /**
   * Stake quantity
   */
  stake: StakePoolMetricsStake;
  /**
   * Percentage of total stake
   */
  size: StakePoolMetricsSize;
  saturation: Percent;
  delegators: number;
  /**
   * Annual Percentage Yield (APY)
   */
  apy?: Percent;
}

export interface StakePoolTransactions {
  registration: TransactionId[];
  retirement: TransactionId[];
}

export enum StakePoolStatus {
  Activating = 'activating',
  Active = 'active',
  Retired = 'retired',
  Retiring = 'retiring'
}

/**
 * Stake pool performance per epoch, taken at epoch rollover
 */
export class StakePoolEpochRewards {
  /**
   * Epoch length in milliseconds
   */
  epochLength: number;
  epoch: Epoch;
  activeStake: Lovelace;
  totalRewards: Lovelace;
  operatorFees: Lovelace;
  /**
   * (rewards-operatorFees)/activeStake, not annualized
   */
  memberROI: Percent;
}

export interface StakePool extends PoolParameters {
  /**
   * Stake pool ID as a hex string
   */
  hexId: PoolIdHex;
  /**
   * Stake pool metrics
   */
  metrics: StakePoolMetrics;
  /**
   * Stake pool status
   */
  status: StakePoolStatus;
  /**
   * Transactions provisioning the stake pool
   */
  transactions: StakePoolTransactions;
  /**
   * Stake pool rewards history per epoch.
   * Sorted by epoch in ascending order.
   */
  epochRewards: StakePoolEpochRewards[];
}
