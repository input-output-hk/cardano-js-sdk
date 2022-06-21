import { Cardano } from '@cardano-sdk/core';
import { Pool } from 'pg';
import { RewardsBuilder } from '../../../src';

describe('RewardsBuilder', () => {
  const dbConnection = new Pool({ connectionString: process.env.DB_CONNECTION_STRING });
  const builder = new RewardsBuilder(dbConnection);
  const rewardAccWithBalance = Cardano.RewardAccount(
    'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27'
  );

  afterAll(async () => {
    await dbConnection.end();
  });

  describe('getAccountBalance', () => {
    it('returns AccountBalanceModel', async () => {
      const result = await builder.getAccountBalance(rewardAccWithBalance);
      expect(result).toMatchSnapshot();
    });
    it('returns 0 balance', async () => {
      const stakeAddressWithNoRewardsBalance = Cardano.RewardAccount(
        'stake_test1uzxvhl83q8ujv2yvpy6n2krvpdlqqx28h7e9vsk6re43h3c3kufy6'
      );
      const result = await builder.getAccountBalance(stakeAddressWithNoRewardsBalance);
      expect(result).toMatchSnapshot();
    });
  });
  describe('getRewardsHistory', () => {
    it('returns RewardEpochModel when there is no epochs field', async () => {
      const result = await builder.getRewardsHistory([rewardAccWithBalance]);
      expect(result.length).toBeGreaterThan(0);
    });
    it('returns RewardEpochModel when there is no epochs field and empty accounts', async () => {
      const result = await builder.getRewardsHistory([]);
      expect(result).toHaveLength(0);
    });
    it('returns RewardEpochModel when there is epochs field', async () => {
      const epochs = { lowerBound: 80, upperBound: 90 };
      const result = await builder.getRewardsHistory([rewardAccWithBalance], epochs);
      expect(result).toHaveLength(2);
      for (const reward of result) {
        expect(Number(reward.epoch)).toBeGreaterThanOrEqual(epochs.lowerBound);
        expect(Number(reward.epoch)).toBeLessThanOrEqual(epochs.upperBound);
      }
    });
    it('returns RewardEpochModel when there is partially epochs field with lowerBound', async () => {
      const epochs = { lowerBound: 10 };
      const result = await builder.getRewardsHistory([rewardAccWithBalance], epochs);
      expect(result.length).toBeGreaterThan(0);
      for (const reward of result) expect(Number(reward.epoch)).toBeGreaterThanOrEqual(epochs.lowerBound);
    });
    it('returns RewardEpochModel when there is partially epochs field with upperBound', async () => {
      const epochs = { upperBound: 90 };
      const result = await builder.getRewardsHistory([rewardAccWithBalance], epochs);
      expect(result).toHaveLength(2);
      for (const reward of result) expect(Number(reward.epoch)).toBeLessThanOrEqual(epochs.upperBound);
    });
  });
});
