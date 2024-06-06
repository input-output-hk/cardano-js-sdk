import { Percent } from '@cardano-sdk/util';
import type { StakePoolEpochRewards } from '../types/index.js';

const MILLISECONDS_PER_DAY = 1000 * 60 * 60 * 24;

/**
 * Estimates annualized percentage yield given past stake pool rewards.
 * Assumes 365 day year.
 *
 * @param rewardsHistory The list of `StakePoolEpochRewards` to estimate the APY
 * @returns `null` if provided an empty `rewardsHistory` or the estimated APY otherwise
 */
export const estimateStakePoolAPY = (rewardsHistory: StakePoolEpochRewards[]): Percent | null => {
  if (rewardsHistory.length === 0) return null;

  const { activeStake, epochLength, memberRewards, pledge } = rewardsHistory.reduce(
    (previous, current) =>
      ({
        activeStake: previous.activeStake + current.activeStake,
        epochLength: previous.epochLength + current.epochLength,
        memberRewards: previous.memberRewards + current.memberRewards,
        pledge: previous.pledge + current.activeStake
      } as StakePoolEpochRewards)
  );

  return Percent((Number(memberRewards) / Number(activeStake - pledge) / (epochLength / MILLISECONDS_PER_DAY)) * 365);
};
