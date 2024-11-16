import { BlockfrostClient, BlockfrostRewardsProvider } from '../../src';
import { Cardano } from '@cardano-sdk/core';
import { Responses } from '@blockfrost/blockfrost-js';
import { logger } from '@cardano-sdk/util-dev';
import { mockResponses } from '../util';
jest.mock('@blockfrost/blockfrost-js');

describe('blockfrostRewardsProvider', () => {
  let request: jest.Mock;
  let provider: BlockfrostRewardsProvider;

  beforeEach(async () => {
    request = jest.fn();
    const client = { request } as unknown as BlockfrostClient;
    provider = new BlockfrostRewardsProvider(client, logger);
  });

  describe('rewardAccountBalance', () => {
    test('used reward account', async () => {
      const mockedAccountsResponse = {
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
      mockResponses(request, [
        ['accounts/stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27', mockedAccountsResponse]
      ]);

      const response = await provider.rewardAccountBalance({
        rewardAccount: Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
      });

      expect(response).toEqual(BigInt(mockedAccountsResponse.withdrawable_amount));
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

    test('epoch bounds & query per stake address', async () => {
      mockResponses(request, [
        [`accounts/${rewardAccounts[0]}/rewards?count=100?page=1`, generateRewardsResponse(2, 98)],
        [`accounts/${rewardAccounts[1]}/rewards?count=100?page=1`, generateRewardsResponse(2, 98)]
      ]);

      const response = await provider.rewardsHistory({
        epochs: {
          lowerBound: Cardano.EpochNo(98),
          upperBound: Cardano.EpochNo(98)
        },
        rewardAccounts
      });

      expect(response).toEqual(
        new Map([
          [rewardAccounts[0], [{ epoch: 98, rewards: 1000n }]],
          [rewardAccounts[1], [{ epoch: 98, rewards: 1000n }]]
        ])
      );
    });

    test('pagination', async () => {
      mockResponses(request, [
        [`accounts/${rewardAccounts[0]}/rewards?count=100?page=1`, generateRewardsResponse(100)],
        [`accounts/${rewardAccounts[0]}/rewards?count=100?page=2`, generateRewardsResponse(0)]
      ]);

      const response = await provider.rewardsHistory({
        epochs: {
          lowerBound: Cardano.EpochNo(98)
        },
        rewardAccounts: [rewardAccounts[0]]
      });

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
  });
});
