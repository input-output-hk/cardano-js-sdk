import { Cardano, EpochRewards } from '@cardano-sdk/core';
import { RewardEpochModel } from './types';

export const rewardsToCore = (rewards: RewardEpochModel[]): Map<Cardano.RewardAccount, EpochRewards[]> =>
  rewards.reduce((_rewards, current) => {
    const coreReward = current.address as unknown as Cardano.RewardAccount;
    const epochRewards = _rewards.get(coreReward);
    const currentEpochReward = { epoch: Cardano.EpochNo(current.epoch), rewards: BigInt(current.quantity) };
    if (epochRewards) {
      _rewards.set(coreReward, [...epochRewards, currentEpochReward]);
    } else {
      _rewards.set(coreReward, [currentEpochReward]);
    }
    return _rewards;
  }, new Map<Cardano.RewardAccount, EpochRewards[]>());
