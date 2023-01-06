import { Cardano } from '../../../src';

describe('estimateStakePoolAPY', () => {
  const rewards = {
    epochLength: 432_000_000,
    memberROI: Cardano.Percent(0.000_68)
  } as Cardano.StakePoolEpochRewards;

  it('provided no history => returns null', () => {
    expect(Cardano.util.estimateStakePoolAPY([])).toBe(null);
  });

  it('provided a single history data point => returns compounded annualized ROI %', () => {
    const apy = Cardano.util.estimateStakePoolAPY([rewards]);
    const epochLengthInDays = rewards.epochLength / 1000 / 60 / 60 / 24;
    expect(apy).toBeGreaterThan(
      // % without compounding
      (rewards.memberROI.valueOf() * 365) / epochLengthInDays
    );
    expect(apy).toBeLessThan(0.1);
  });

  // eslint-disable-next-line max-len
  it('provided multiple history data points => returns compounded annualized ROI %, assuming weighted average rewards and epoch length of the last data point', () => {
    const worseRewards = {
      // computation should assume that this is the epoch length for the year
      // since this is the last data point (as per epochNo)
      ...rewards,
      epochLength: rewards.epochLength * 2,
      // worse ROI than 'rewards': 2x the epoch length, but only 1.5x ROI
      memberROI: Cardano.Percent(rewards.memberROI.valueOf() * 1.5)
    };
    const apy1 = Cardano.util.estimateStakePoolAPY([rewards])!;
    const apy2 = Cardano.util.estimateStakePoolAPY([rewards, worseRewards])!;
    const apy3 = Cardano.util.estimateStakePoolAPY([worseRewards])!;
    expect(apy1).toBeGreaterThan(apy2.valueOf());
    expect(apy2).toBeGreaterThan(apy3.valueOf());
  });
});
