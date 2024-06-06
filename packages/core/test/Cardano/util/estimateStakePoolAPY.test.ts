import { Cardano } from '../../../src/index.js';
import { Percent } from '@cardano-sdk/util';

describe('estimateStakePoolAPY', () => {
  const rewards = {
    activeStake: 10_365_739_303_707n,
    epochLength: 432_000_000,
    memberROI: Percent(0.000_829_950_248_854_788),
    memberRewards: 8_579_404_603n,
    pledge: 28_487_625_262n
  } as Cardano.StakePoolEpochRewards;

  it('provided no history => returns null', () => {
    expect(Cardano.util.estimateStakePoolAPY([])).toBe(null);
  });

  it('provided a single history data point => returns compounded annualized APY %', () => {
    const apy = Cardano.util.estimateStakePoolAPY([rewards]);
    const epochLengthInDays = rewards.epochLength / 1000 / 60 / 60 / 24;
    expect(apy).toBeCloseTo((rewards.memberROI! * 365) / epochLengthInDays);
    expect(apy).toBeLessThan(0.1);
  });

  // eslint-disable-next-line max-len
  it('provided multiple history data points => returns compounded annualized APY %', () => {
    const worseRewards = {
      ...rewards,
      epochLength: rewards.epochLength * 3,
      // worse APY than 'reward': 3x the epoch length, but only 2x memberRewards
      memberRewards: rewards.memberRewards * 2n
    };
    const apy1 = Cardano.util.estimateStakePoolAPY([rewards])!;
    const apy2 = Cardano.util.estimateStakePoolAPY([rewards, worseRewards])!;
    const apy3 = Cardano.util.estimateStakePoolAPY([worseRewards])!;
    expect(apy1).toBeGreaterThan(apy2);
    expect(apy2).toBeGreaterThan(apy3);
  });
});
