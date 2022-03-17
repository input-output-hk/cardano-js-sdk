import { Cardano, WalletProvider, util } from '@cardano-sdk/core';
import { WalletProviderFnProps } from './WalletProviderFnProps';
import { groupBy } from 'lodash-es';

export const rewardsHistoryProvider =
  ({ sdk }: WalletProviderFnProps): WalletProvider['rewardsHistory'] =>
  async ({ rewardAccounts, epochs }) => {
    const { queryRewardAccount } = await sdk.MemberRewardsHistory({
      fromEpochNo: epochs?.lowerBound,
      rewardAccounts: rewardAccounts as unknown as string[],
      toEpochNo: epochs?.upperBound
    });
    const rawRewards = queryRewardAccount?.filter(util.isNotNil) || [];
    const rewardsByAddress = groupBy(
      rawRewards.flatMap(({ rewards, address }) =>
        rewards.map(({ epochNo, quantity }) => ({ address, epoch: epochNo, rewards: BigInt(quantity) }))
      ),
      ({ address }) => address
    );
    return new Map(
      Object.keys(rewardsByAddress).map((rewardAccount) => [
        Cardano.RewardAccount(rewardAccount),
        rewardsByAddress[rewardAccount].map(({ epoch, rewards }) => ({ epoch, rewards }))
      ])
    );
  };
