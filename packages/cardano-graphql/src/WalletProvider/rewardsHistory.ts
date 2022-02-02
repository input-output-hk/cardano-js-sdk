import { BigIntMath, EpochRewards, WalletProvider, util } from '@cardano-sdk/core';
import { WalletProviderFnProps } from './WalletProviderFnProps';
import { groupBy } from 'lodash-es';

export const rewardsHistoryProvider =
  ({ sdk }: WalletProviderFnProps): WalletProvider['rewardsHistory'] =>
  async ({ stakeAddresses, epochs }) => {
    const { queryRewardAccount } = await sdk.MemberRewardsHistory({
      fromEpochNo: epochs?.lowerBound,
      rewardAccounts: stakeAddresses as unknown as string[],
      toEpochNo: epochs?.upperBound
    });
    const rawRewards = queryRewardAccount?.filter(util.isNotNil) || [];
    const rewardsByEpoch = groupBy(
      rawRewards.flatMap(({ rewards }): EpochRewards[] =>
        rewards.map(({ epochNo, quantity }) => ({ epoch: epochNo, rewards: quantity }))
      ),
      ({ epoch }) => epoch
    );
    return Object.keys(rewardsByEpoch).map(
      (epoch): EpochRewards => ({
        epoch: Number.parseInt(epoch),
        rewards: BigIntMath.sum(rewardsByEpoch[epoch].map(({ rewards }) => rewards))
      })
    );
  };
