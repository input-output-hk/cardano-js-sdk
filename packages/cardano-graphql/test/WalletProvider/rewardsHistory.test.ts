/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano, EpochRewards, WalletProvider } from '@cardano-sdk/core';
import { MemberRewardsHistoryQuery, Sdk } from '../../src/sdk';
import { createGraphQLWalletProviderFromSdk } from '../../src/WalletProvider/CardanoGraphQLWalletProvider';

describe('CardanoGraphQLWalletProvider.rewardsHistory', () => {
  let provider: WalletProvider;
  const addresses: Cardano.RewardAccount[] = [
    Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27'),
    Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d')
  ];
  const sdk = { MemberRewardsHistory: jest.fn() };
  const rawRewards = [
    {
      address: addresses[0],
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
      address: addresses[1].toString(),
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

  it('groups rewards by reward account address', async () => {
    sdk.MemberRewardsHistory.mockResolvedValueOnce({
      queryRewardAccount: rawRewards
    });
    const rewardsHistory = await provider.rewardsHistory({
      rewardAccounts: addresses
    });
    expect(rewardsHistory).toEqual(
      new Map<Cardano.RewardAccount, EpochRewards[]>([
        [
          addresses[0],
          [
            { epoch: 2, rewards: 1n },
            { epoch: 3, rewards: 1n }
          ]
        ],
        [
          addresses[1],
          [
            { epoch: 1, rewards: 2n },
            { epoch: 2, rewards: 2n }
          ]
        ]
      ])
    );
  });

  it('filters results by provided epoch range', async () => {
    sdk.MemberRewardsHistory.mockResolvedValueOnce({
      queryRewardAccount: rawRewards
    });
    await provider.rewardsHistory({
      epochs: { lowerBound: 2, upperBound: 3 },
      rewardAccounts: addresses
    });
    expect(sdk.MemberRewardsHistory).toBeCalledWith({
      fromEpochNo: 2,
      rewardAccounts: addresses,
      toEpochNo: 3
    });
  });

  it('returns an empty map on undefined response', async () => {
    sdk.MemberRewardsHistory.mockResolvedValueOnce({});
    expect(await provider.rewardsHistory({ rewardAccounts: addresses })).toEqual(new Map());
  });
});
