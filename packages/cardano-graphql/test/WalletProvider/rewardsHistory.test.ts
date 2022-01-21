/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano, EpochRewards, WalletProvider } from '@cardano-sdk/core';
import { RewardsHistoryQuery, Sdk } from '../../src/sdk';
import { createGraphQLWalletProviderFromSdk } from '../../src/WalletProvider/CardanoGraphQLWalletProvider';

describe('CardanoGraphQLWalletProvider.rewardsHistory', () => {
  let provider: WalletProvider;
  const addresses: Cardano.RewardAccount[] = [];
  const sdk = { RewardsHistory: jest.fn() };
  const rawRewards = [
    {
      activeStake: [
        {
          epoch: { number: 2 },
          quantity: 1n
        },
        {
          epoch: { number: 3 },
          quantity: 1n
        }
      ]
    },
    {
      activeStake: [
        {
          epoch: { number: 1 },
          quantity: 2n
        },
        {
          epoch: { number: 2 },
          quantity: 2n
        }
      ]
    }
  ] as NonNullable<NonNullable<RewardsHistoryQuery['queryRewardAccount']>>;

  beforeEach(() => (provider = createGraphQLWalletProviderFromSdk(sdk as unknown as Sdk)));

  it('sums rewards of all addresses per epoch', async () => {
    sdk.RewardsHistory.mockResolvedValueOnce({
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
    sdk.RewardsHistory.mockResolvedValueOnce({
      queryRewardAccount: rawRewards
    });
    const rewardsHistory = await provider.rewardsHistory({
      epochs: { lowerBound: 2, upperBound: 2 },
      stakeAddresses: addresses
    });
    expect(rewardsHistory).toEqual([{ epoch: 2, rewards: 3n }] as EpochRewards[]);
  });

  it('returns an empty array on undefined response', async () => {
    sdk.RewardsHistory.mockResolvedValueOnce({});
    expect(await provider.rewardsHistory({ stakeAddresses: addresses })).toEqual([]);
  });
});
