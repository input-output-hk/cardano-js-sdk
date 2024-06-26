import { EpochNo } from '../Block';
import { Lovelace } from '../Value';
import { Percent } from '@cardano-sdk/util';
import { PoolIdHex } from './primitives';
import { PoolParameters } from './PoolParameters';

/** Stake quantities for a Stake Pool. */
export interface StakePoolMetricsStake {
  /** The total amount of stake currently delegated to the pool. This will be snapshotted at the end of the epoch. */
  live: Lovelace;

  /** A snapshot from 2 epochs ago, used in the current epoch as part of the block leadership schedule. */
  active: Lovelace;
}

/** Stake percentages for a Stake Pool. */
export interface StakePoolMetricsSize {
  /** The percentage of stake currently delegated to the pool. This will be snapshotted at the end of the epoch. */
  live: Percent;

  /**
   * Percentage of stake as a snapshot from 2 epochs ago, used in the current epoch as part of the
   * block leadership schedule.
   */
  active: Percent;
}

/** Stake pool performance metrics. */
export interface StakePoolMetrics {
  /** Total blocks created by the pool. */
  blocksCreated: number;

  /** This can be used to determine the likelihood of the pool meeting its pledge at the next snapshot. */
  livePledge: Lovelace;

  /** Quantity of stake being controlled by the pool. */
  stake: StakePoolMetricsStake;

  /** Percentage of stake being controlled by the pool. */
  size: StakePoolMetricsSize;

  /**
   * The current saturation of the pool. The amount of rewards generated by the pool gets capped at a pool saturation
   * of 100%; This is part of the protocol to promote decentralization of the stake.
   */
  saturation: Percent;

  /** Number of stakeholders, represented by a stake key, delegating to this pool. */
  delegators: number;

  /**
   * The Annual Percentage Yield (APY) from a delegator's perspective in the given period.
   *
   * The given period is defined by all requested spendable epochs: all requested epochs except
   * the current and previous.
   *
   * Formula: (memberRewards / (activeStake - pledge)) / days_per_epoch * 365
   *
   * Where: memberRewards, activeStake and pledge are the sum of the respective data from all
   * epochs in the given period.
   *
   * @deprecated Use `ros` instead
   */
  apy?: Percent;

  /** The annualized **Return Of Stake** for the last `LAST_ROS_EPOCHS` epochs _from member perspective_. */
  lastRos: Percent;

  /**
   * The annualized **Return Of Stake** for the _life time_ of the pool _from member perspective_.
   *
   * The period of **ROS** computation depends on requested `QueryStakePoolsArgs.epochsLength`:
   * if provided, **ROS** is computed on the last requested epochs, otherwise for the life time of the pool.
   */
  ros: Percent;
}

/** Pool status. */
export enum StakePoolStatus {
  Activating = 'activating',
  Active = 'active',
  Retired = 'retired',
  Retiring = 'retiring'
}

/** Stake pool epoch stats. */
export class StakePoolEpochRewards {
  /**
   * Active stake is a stake snapshot from 2 epochs ago and is used in the current era
   * as part of the block leadership schedule.
   */
  activeStake: Lovelace;

  /**
   * The epoch number at which these rewards were calculated.
   *
   * @deprecated Use `epochNo` instead
   */
  epoch?: EpochNo;

  /** Epoch length in milliseconds. */
  epochLength: number;

  /** The epoch number at which these rewards were calculated. */
  epochNo: EpochNo;

  /** The rewards generated by the pool that leaders have access to in the current epoch. */
  leaderRewards: Lovelace;

  /** The part of the active stake delegated by members. */
  memberActiveStake: Lovelace;

  /**
   * The Return Of Investment (ROI) from a delegator's perspective in the given epoch. Not annualized.
   *
   * Formula: memberRewards / (activeStake - pledge)
   *
   * Incomplete for last two epochs.
   *
   * @deprecated No longer supported
   */
  memberROI?: Percent;

  /** The rewards generated by the pool that members have access to in the current epoch. */
  memberRewards: Lovelace;

  /** The amount pledged by the pool owners. */
  pledge: Lovelace;

  /** The rewards generated by the pool in the current epoch. */
  rewards: Lovelace;
}

/** Stake pool information about the performance, status, transaction, rewards and pool parameters. */
export interface StakePool extends PoolParameters {
  /** Stake pool ID as a hex string. */
  hexId: PoolIdHex;

  /** Stake pool metrics. */
  metrics?: StakePoolMetrics;

  /** Stake pool status. */
  status: StakePoolStatus;

  /** The last portion of epoch rewards history. */
  rewardHistory?: StakePoolEpochRewards[];
}
