import { rewardAccountBalance, rewardAccountBalance2, rewardsHistory, rewardsHistory2 } from './mockData';
import delay from 'delay';

export const mockRewardsProvider = () => ({
  healthCheck: jest.fn().mockResolvedValue({ ok: true }),
  rewardAccountBalance: jest.fn().mockResolvedValue(rewardAccountBalance),
  rewardsHistory: jest.fn().mockResolvedValue(rewardsHistory)
});

export const mockRewardsProvider2 = (delayMs: number) => {
  const delayedJestFn = <T>(resolvedValue: T) =>
    jest.fn().mockImplementation(() => delay(delayMs).then(() => resolvedValue));
  return {
    healthCheck: delayedJestFn({ ok: true }),
    rewardAccountBalance: delayedJestFn(rewardAccountBalance2),
    rewardsHistory: delayedJestFn(rewardsHistory2)
  };
};

export type RewardsProviderStub = ReturnType<typeof mockRewardsProvider>;
