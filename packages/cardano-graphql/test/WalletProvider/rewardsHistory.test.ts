/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano, EpochRewards, WalletProvider } from '@cardano-sdk/core';
import { MemberRewardsHistoryQuery, Sdk } from '../../src/sdk';
import { createGraphQLWalletProviderFromSdk } from '../../src/WalletProvider/CardanoGraphQLWalletProvider';

describe('CardanoGraphQLWalletProvider.rewardsHistory', () => {
  let provider: WalletProvider;
  const addresses: Cardano.RewardAccount[] = [];
  const sdk = { MemberRewardsHistory: jest.fn() };
  const rawRewards = [
    {
      rewards: [
        {
          epochNo: 2,
          quantity: 1n
        },
        {
          epochNo: 3,
          quantity: 1n
        }
      ]
    },
    {
      rewards: [
        {
          epochNo: 1,
          quantity: 2n
        },
        {
          epochNo: 2,
          quantity: 2n
        }
      ]
    }
  ] as NonNullable<NonNullable<MemberRewardsHistoryQuery['queryRewardAccount']>>;

  beforeEach(() => (provider = createGraphQLWalletProviderFromSdk(sdk as unknown as Sdk)));

  it('sums rewards of all addresses per epoch', async () => {
    sdk.MemberRewardsHistory.mockResolvedValueOnce({
      queryRewardAccount: rawRewards
    });
    const rewardsHistory = await provider.rewardsHistory({
      stakeAddresses: addresses
    });
    expect(rewardsHistory).toEqual([
      { epoch: 1, rewards: 2n },
      { epoch: 2, rewards: 3n },
      { epoch: 3, rewards: 1n }
    ] as EpochRewards[]);
  });

  it('filters results by provided epoch range', async () => {
    sdk.MemberRewardsHistory.mockResolvedValueOnce({
      queryRewardAccount: rawRewards
    });
    await provider.rewardsHistory({
      epochs: { lowerBound: 2, upperBound: 3 },
      stakeAddresses: addresses
    });
    expect(sdk.MemberRewardsHistory).toBeCalledWith({
      fromEpochNo: 2,
      rewardAccounts: addresses,
      toEpochNo: 3
    });
  });

  it('returns an empty array on undefined response', async () => {
    sdk.MemberRewardsHistory.mockResolvedValueOnce({});
    expect(await provider.rewardsHistory({ stakeAddresses: addresses })).toEqual([]);
  });
});
