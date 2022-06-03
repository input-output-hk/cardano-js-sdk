/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */

import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { Cardano, WalletProvider } from '@cardano-sdk/core';
import { blockfrostWalletProvider } from '../src';

jest.mock('@blockfrost/blockfrost-js');

const blockResponse = {
  block_vrf: 'vrf_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4s99zvg8',
  confirmations: 0,
  epoch: 157,
  epoch_slot: 312_794,
  fees: '513839',
  hash: '86e837d8a6cdfddaf364525ce9857eb93430b7e59a5fd776f0a9e11df476a7e5',
  height: 2_927_618,
  next_block: null,
  output: '9249073880',
  previous_block: 'da56fa53483a3a087c893b41aa0d73a303148c2887b3f7535e0b505ea5dc10aa',
  size: 1050,
  slot: 37_767_194,
  slot_leader: 'pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh',
  time: 1_632_136_410,
  tx_count: 3
} as Responses['block_content'];

describe('blockfrostWalletProvider', () => {
  const apiKey = 'someapikey';

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

      const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
      const client = blockfrostWalletProvider(blockfrost);
      const response = await client.rewardAccountBalance(
        Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
      );

      expect(response).toEqual(BigInt(accountsMockResponse.withdrawable_amount));
    });

    test('unused reward account', async () => {
      const notFoundBody = {
        error: 'Not Found',
        message: 'The requested component has not been found.',
        status_code: 404
      };
      BlockFrostAPI.prototype.accounts = jest.fn().mockRejectedValue(notFoundBody);

      const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
      const client = blockfrostWalletProvider(blockfrost);
      const response = await client.rewardAccountBalance(
        Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d')
      );
      expect(response).toEqual(0n);
    });
  });

  test('genesisParameters', async () => {
    const mockedResponse = {
      active_slots_coefficient: 0.05,
      epoch_length: 432_000,
      max_kes_evolutions: 62,
      max_lovelace_supply: '45000000000000000',
      network_magic: 764_824_073,
      security_param: 2160,
      slot_length: 1,
      slots_per_kes_period: 129_600,
      system_start: 1_506_203_091,
      update_quorum: 5
    };
    BlockFrostAPI.prototype.genesis = jest.fn().mockResolvedValue(mockedResponse);

    const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
    const client = blockfrostWalletProvider(blockfrost);
    const response = await client.genesisParameters();

    expect(response).toMatchObject({
      activeSlotsCoefficient: 0.05,
      epochLength: 432_000,
      maxKesEvolutions: 62,
      maxLovelaceSupply: 45_000_000_000_000_000n,
      networkMagic: 764_824_073,
      securityParameter: 2160,
      slotLength: 1,
      slotsPerKesPeriod: 129_600,
      systemStart: new Date(1_506_203_091_000),
      updateQuorum: 5
    } as Cardano.CompactGenesis);
  });

  test('currentWalletProtocolParameters', async () => {
    const mockedResponse = {
      data: {
        coins_per_utxo_word: '0',
        key_deposit: '2000000',
        max_collateral_inputs: 1,
        max_tx_size: '16384',
        max_val_size: '1000',
        min_fee_a: 44,
        min_fee_b: 155_381,
        min_pool_cost: '340000000',
        pool_deposit: '500000000',
        protocol_major_ver: 5,
        protocol_minor_ver: 0
      }
    };
    BlockFrostAPI.prototype.axiosInstance = jest.fn().mockResolvedValue(mockedResponse) as any;

    const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
    const client = blockfrostWalletProvider(blockfrost);
    const response = await client.currentWalletProtocolParameters();

    expect(response).toMatchObject({
      coinsPerUtxoWord: 0,
      maxCollateralInputs: 1,
      maxTxSize: 16_384,
      maxValueSize: 1000,
      minFeeCoefficient: 44,
      minFeeConstant: 155_381,
      minPoolCost: 340_000_000,
      poolDeposit: 500_000_000,
      protocolVersion: { major: 5, minor: 0 },
      stakeKeyDeposit: 2_000_000
    });
  });

  test('ledgerTip', async () => {
    BlockFrostAPI.prototype.blocksLatest = jest.fn().mockResolvedValue(blockResponse);

    const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
    const client = blockfrostWalletProvider(blockfrost);
    const response = await client.ledgerTip();

    expect(response).toMatchObject({
      blockNo: 2_927_618,
      hash: '86e837d8a6cdfddaf364525ce9857eb93430b7e59a5fd776f0a9e11df476a7e5',
      slot: 37_767_194
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
        pool_id
      }));
    let client: WalletProvider;

    beforeEach(() => {
      const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
      client = blockfrostWalletProvider(blockfrost);
    });

    test('epoch bounds & query per stake address', async () => {
      BlockFrostAPI.prototype.accountsRewards = jest.fn().mockResolvedValue(generateRewardsResponse(2, 98));

      const response = await client.rewardsHistory({
        epochs: {
          lowerBound: 98,
          upperBound: 98
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

      const response = await client.rewardsHistory({
        epochs: {
          lowerBound: 98
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
  });
});
