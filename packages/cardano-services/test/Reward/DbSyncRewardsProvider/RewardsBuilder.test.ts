import { Cardano } from '@cardano-sdk/core';
import { Pool } from 'pg';
import { RewardsBuilder } from '../../../src/index.js';
import { RewardsFixtureBuilder } from '../fixtures/FixtureBuilder.js';
import { logger } from '@cardano-sdk/util-dev';

describe('RewardsBuilder', () => {
  const dbConnection = new Pool({
    connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC
  });
  const builder = new RewardsBuilder(dbConnection, logger);
  const fixtureBuilder = new RewardsFixtureBuilder(dbConnection, logger);

  afterAll(async () => {
    await dbConnection.end();
  });

  describe('getAccountBalance', () => {
    it('returns AccountBalanceModel', async () => {
      const rewardAccWithBalance = (await fixtureBuilder.getRewardAccounts(1))[0];
      const result = await builder.getAccountBalance(rewardAccWithBalance);
      expect(result).toMatchShapeOf({ balance: '0' });
      expect(Number(result?.balance)).toBeGreaterThan(0);
    });
    it('returns 0 balance', async () => {
      const stakeAddressWithNoRewardsBalance = Cardano.RewardAccount(
        'stake_test1uzxvhl83q8ujv2yvpy6n2krvpdlqqx28h7e9vsk6re43h3c3kufy6'
      );
      const result = await builder.getAccountBalance(stakeAddressWithNoRewardsBalance);
      expect(result).toMatchShapeOf({ balance: '0' });
      expect(Number(result?.balance)).toEqual(0);
    });
  });
  describe('getRewardsHistory', () => {
    it('returns RewardEpochModel when there is no epochs field', async () => {
      const rewardAccWithBalance = (await fixtureBuilder.getRewardAccounts(1))[0];
      const result = await builder.getRewardsHistory([rewardAccWithBalance]);
      expect(result.length).toBeGreaterThan(0);
    });
    it('returns RewardEpochModel when there is no epochs field and empty accounts', async () => {
      const result = await builder.getRewardsHistory([]);
      expect(result).toHaveLength(0);
    });
    it('returns RewardEpochModel when there is epochs field', async () => {
      const rewardAccWithBalance = (await fixtureBuilder.getRewardAccounts(1))[0];
      const epochs = { lowerBound: Cardano.EpochNo(2), upperBound: Cardano.EpochNo(4) };
      const result = await builder.getRewardsHistory([rewardAccWithBalance], epochs);
      expect(result.length).toBeGreaterThan(0);
      for (const reward of result) {
        expect(Number(reward.epoch)).toBeGreaterThanOrEqual(epochs.lowerBound);
        expect(Number(reward.epoch)).toBeLessThanOrEqual(epochs.upperBound);
      }
    });
    it('returns RewardEpochModel when there is partially epochs field with lowerBound', async () => {
      const rewardAccWithBalance = (await fixtureBuilder.getRewardAccounts(1))[0];
      const epochs = { lowerBound: Cardano.EpochNo(1) };
      const result = await builder.getRewardsHistory([rewardAccWithBalance], epochs);
      expect(result.length).toBeGreaterThan(0);
      for (const reward of result) expect(Number(reward.epoch)).toBeGreaterThanOrEqual(epochs.lowerBound);
    });
    it('returns RewardEpochModel when there is partially epochs field with upperBound', async () => {
      const rewardAccWithBalance = (await fixtureBuilder.getRewardAccounts(1))[0];
      const epochs = { upperBound: Cardano.EpochNo(90) };
      const result = await builder.getRewardsHistory([rewardAccWithBalance], epochs);
      expect(result.length).toBeGreaterThan(0);
      for (const reward of result) expect(Number(reward.epoch)).toBeLessThanOrEqual(epochs.upperBound);
    });
  });
});
