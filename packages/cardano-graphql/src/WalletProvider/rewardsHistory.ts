import { BigIntMath, EpochRewards, WalletProvider, util } from '@cardano-sdk/core';
import { WalletProviderFnProps } from './WalletProviderFnProps';
import { groupBy } from 'lodash-es';

export const rewardsHistoryProvider =
  ({ sdk }: WalletProviderFnProps): WalletProvider['rewardsHistory'] =>
  async ({ stakeAddresses, epochs }) => {
    const { queryRewardAccount } = await sdk.RewardsHistory({ rewardAccounts: stakeAddresses as unknown as string[] });
    const rawRewards = queryRewardAccount?.filter(util.isNotNil) || [];
    const rewardsByEpoch = groupBy(
      rawRewards.flatMap(({ activeStake }): EpochRewards[] => {
        const filteredActiveStake = epochs
          ? activeStake?.filter(
              ({ epoch }) =>
                epoch.number >= (epochs.lowerBound || Number.NEGATIVE_INFINITY) &&
                epoch.number <= (epochs.upperBound || Number.POSITIVE_INFINITY)
            )
          : activeStake;
        return filteredActiveStake.map(({ epoch: { number }, quantity }) => ({ epoch: number, rewards: quantity }));
      }),
      ({ epoch }) => epoch
    );
    return Object.keys(rewardsByEpoch).map(
      (epoch): EpochRewards => ({
        epoch: Number.parseInt(epoch),
        rewards: BigIntMath.sum(rewardsByEpoch[epoch].map(({ rewards }) => rewards))
      })
    );
  };
