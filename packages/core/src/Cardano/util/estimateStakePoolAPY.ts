import { Cardano } from '../..';
import sum from 'lodash/sum';

const MILLISECONDS_PER_DAY = 1000 * 60 * 60 * 24;

/**
 * Estimates annualized percentage yield given past stake pool rewards.
 * Assumes 365 day year, average historical yield "per time" and epoch length of last rewardsHistory data point.
 *
 * @param {Cardano.StakePoolEpochRewards[]} rewardsHistory sorted by epoch in ascending order
 */
export const estimateStakePoolAPY = (rewardsHistory: Cardano.StakePoolEpochRewards[]): Cardano.Percent | null => {
  if (rewardsHistory.length === 0) return null;
  const roisPerDay = rewardsHistory.map(
    ({ epochLength, memberROI }) => memberROI / (epochLength / MILLISECONDS_PER_DAY)
  );
  const epochLengthInDays = rewardsHistory[rewardsHistory.length - 1].epochLength / MILLISECONDS_PER_DAY;
  const averageDailyROI = sum(roisPerDay) / roisPerDay.length;
  const roiPerEpoch = averageDailyROI * epochLengthInDays;
  const numEpochs = 365 / epochLengthInDays;
  // Compound interest formula
  return Math.pow(1 + roiPerEpoch, numEpochs) - 1;
};
