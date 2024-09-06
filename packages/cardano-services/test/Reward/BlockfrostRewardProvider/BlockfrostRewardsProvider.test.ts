import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { BlockfrostRewardsProvider } from '../../../src';
import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { logger } from '@cardano-sdk/util-dev';
jest.mock('@blockfrost/blockfrost-js');

describe('blockfrostRewardsProvider', () => {
  const apiKey = 'someapikey';

  describe('healthCheck', () => {
    it('returns ok if the service reports a healthy state', async () => {
      BlockFrostAPI.prototype.health = jest.fn().mockResolvedValue({ is_healthy: true });
      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = new BlockfrostRewardsProvider({ blockfrost, logger });
      expect(await provider.healthCheck()).toEqual({ ok: true });
    });
    it('returns not ok if the service reports an unhealthy state', async () => {
      BlockFrostAPI.prototype.health = jest.fn().mockResolvedValue({ is_healthy: false });
      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = new BlockfrostRewardsProvider({ blockfrost, logger });
      expect(await provider.healthCheck()).toEqual({ ok: false });
    });
    it('throws a typed error if caught during the service interaction', async () => {
      BlockFrostAPI.prototype.health = jest
        .fn()
        .mockRejectedValue(new ProviderError(ProviderFailure.Unknown, new Error('Some error')));
      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = new BlockfrostRewardsProvider({ blockfrost, logger });
      await expect(provider.healthCheck()).rejects.toThrowError(ProviderError);
    });
  });
  describe('rewardAccountBalance', () => {
    test('used reward account', async () => {
      const accountsMockResponse = {
        active: true,
        active_epoch: 81,
        controlled_amount: '95565690389731',
        pool_id: 'pool1y6chk7x7fup4ms9leesdr57r4qy9cwxuee0msan72x976a6u0nc',
        reserves_sum: '0',
        rewards_sum: '615803862289',
        stake_address: 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27',
        treasury_sum: '0',
        withdrawable_amount: '615803862289',
        withdrawals_sum: '0'
      };
      BlockFrostAPI.prototype.accounts = jest.fn().mockResolvedValue(accountsMockResponse);

      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = new BlockfrostRewardsProvider({ blockfrost, logger });
      const response = await provider.rewardAccountBalance({
        rewardAccount: Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
      });

      expect(response).toEqual(BigInt(accountsMockResponse.withdrawable_amount));
    });

    test('unused reward account', async () => {
      BlockFrostAPI.prototype.accounts = jest.fn().mockRejectedValue({
        error: 'Not Found',
        message: 'The requested component has not been found.',
        status_code: 404,
        url: 'some-url'
      });
      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = new BlockfrostRewardsProvider({ blockfrost, logger });
      const response = await provider.rewardAccountBalance({
        rewardAccount: Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d')
      });
      expect(response).toEqual(0n);
    });
  });

  describe('rewardsHistory', () => {
    const pool_id = 'pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy';
    const rewardAccounts = [
      'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27',
      'stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d'
    ].map(Cardano.RewardAccount);
    const generateRewardsResponse = (numEpochs: number, firstEpoch = 0): Responses['account_reward_content'] =>
      [...Array.from({ length: numEpochs }).keys()].map((epoch) => ({
        amount: '1000',
        epoch: firstEpoch + epoch,
        pool_id,
        type: 'member'
      }));
    let provider: BlockfrostRewardsProvider;

    beforeEach(() => {
      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      provider = new BlockfrostRewardsProvider({ blockfrost, logger });
    });

    test('epoch bounds & query per stake address', async () => {
      BlockFrostAPI.prototype.accountsRewards = jest.fn().mockResolvedValue(generateRewardsResponse(2, 98));

      const response = await provider.rewardsHistory({
        epochs: {
          lowerBound: Cardano.EpochNo(98),
          upperBound: Cardano.EpochNo(98)
        },
        rewardAccounts
      });

      expect(BlockFrostAPI.prototype.accountsRewards).toBeCalledTimes(2);
      expect(response).toEqual(
        new Map([
          [rewardAccounts[0], [{ epoch: 98, rewards: 1000n }]],
          [rewardAccounts[1], [{ epoch: 98, rewards: 1000n }]]
        ])
      );
    });

    test('pagination', async () => {
      BlockFrostAPI.prototype.accountsRewards = jest
        .fn()
        .mockResolvedValueOnce(generateRewardsResponse(100))
        .mockResolvedValueOnce(generateRewardsResponse(0));

      const response = await provider.rewardsHistory({
        epochs: {
          lowerBound: Cardano.EpochNo(98)
        },
        rewardAccounts: [rewardAccounts[0]]
      });

      expect(BlockFrostAPI.prototype.accountsRewards).toBeCalledTimes(2);
      expect(response).toEqual(
        new Map([
          [
            rewardAccounts[0],
            [
              { epoch: 98, rewards: 1000n },
              { epoch: 99, rewards: 1000n }
            ]
          ]
        ])
      );
    });

    const mockedError = {
      error: 'Forbidden',
      message: 'Invalid project token.',
      status_code: 403,
      url: 'test'
    };

    const mockedErrorMethod = jest.fn().mockRejectedValue(mockedError);

    test('rewardsHistory throws', async () => {
      BlockFrostAPI.prototype.accountsRewards = mockedErrorMethod;

      await expect(() =>
        provider.rewardsHistory({
          epochs: {
            lowerBound: Cardano.EpochNo(98)
          },
          rewardAccounts: [rewardAccounts[0]]
        })
      ).rejects.toThrow();
      expect(mockedErrorMethod).toBeCalledTimes(1);
    });

    test('rewardAccountBalance throws', async () => {
      mockedErrorMethod.mockClear();
      BlockFrostAPI.prototype.accounts = mockedErrorMethod;

      await expect(() =>
        provider.rewardAccountBalance({
          rewardAccount: Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d')
        })
      ).rejects.toThrow();
      expect(mockedErrorMethod).toBeCalledTimes(1);
    });
  });
});
