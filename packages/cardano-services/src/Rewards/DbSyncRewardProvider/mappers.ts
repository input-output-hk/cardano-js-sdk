import { Cardano, Reward } from '@cardano-sdk/core';
import { RewardEpochModel } from './types';

export const rewardsToCore = (rewards: RewardEpochModel[]): Map<Cardano.RewardAccount, Reward[]> =>
  rewards.reduce((_rewards, current) => {
    const coreReward = current.address as unknown as Cardano.RewardAccount;
    const poolId = current.pool_id ? (current.pool_id as unknown as Cardano.PoolId) : undefined;
    const epochRewards = _rewards.get(coreReward);
    const currentEpochReward = {
      epoch: Cardano.EpochNo(current.epoch),
      poolId,
      rewards: BigInt(current.quantity)
    };
    if (epochRewards) {
      _rewards.set(coreReward, [...epochRewards, currentEpochReward]);
    } else {
      _rewards.set(coreReward, [currentEpochReward]);
    }
    return _rewards;
  }, new Map<Cardano.RewardAccount, Reward[]>());
