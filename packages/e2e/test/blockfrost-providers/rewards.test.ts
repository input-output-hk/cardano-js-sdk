import { Cardano, RewardsProvider } from '@cardano-sdk/core';
import { getEnv, rewardsProviderFactory, walletVariables } from '../../src';
import { logger } from '@cardano-sdk/util-dev';

const env = getEnv(['BLOCKFROST_API_KEY', ...walletVariables]);

describe('BlockfrostRewardsProvider', () => {
  let factory: Promise<RewardsProvider>;

  beforeAll(() => {
    if (env.TEST_CLIENT_REWARDS_PROVIDER !== 'blockfrost')
      throw new Error('TEST_CLIENT_REWARDS_PROVIDER must be "blockfrost" to run these tests');
    factory = rewardsProviderFactory.create(
      'blockfrost',
      {
        baseUrl: 'https://cardano-preprod.blockfrost.io',
        projectId: env.BLOCKFROST_API_KEY
      },
      logger
    );
  });

  test('rewardAccountBalance', async () => {
    const provider = await factory;
    const lookupAddress = Cardano.RewardAccount('stake_test1uzea5zexl4kx3nc2wzjc7eqdpr200zqf0c7ytl8ueeu2suc42ljlk');
    const response = await provider.rewardAccountBalance({
      rewardAccount: lookupAddress
    });
    expect(typeof response).toBe('bigint');
  });

  test('rewardsHistory', async () => {
    const provider = await factory;
    // Known address with rewards history
    const lookupAddress = Cardano.RewardAccount('stake_test1uzea5zexl4kx3nc2wzjc7eqdpr200zqf0c7ytl8ueeu2suc42ljlk');
    const response = await provider.rewardsHistory({
      epochs: { lowerBound: Cardano.EpochNo(179), upperBound: Cardano.EpochNo(181) },
      rewardAccounts: [lookupAddress]
    });
    expect(response.size).toBeLessThanOrEqual(3);
    expect(typeof response.get(lookupAddress)![0].rewards).toBe('bigint');
  });
});
