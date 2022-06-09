/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */

import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { Cardano } from '@cardano-sdk/core';
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
});
