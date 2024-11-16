import { BlockfrostClient, BlockfrostNetworkInfoProvider } from '../../src';
import { Cardano, EraSummary, Milliseconds, Seconds, StakeSummary, SupplySummary } from '@cardano-sdk/core';
import { Responses } from '@blockfrost/blockfrost-js';
import { logger } from '@cardano-sdk/util-dev';
import { mockResponses } from '../util';

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

const mockedNetworkResponse = {
  stake: {
    active: '1060378314781343',
    live: '15001884895856815'
  },
  supply: {
    circulating: '42064399450423723',
    locked: '6161981104458',
    max: '45000000000000000',
    total: '40267211394073980'
  }
} as Responses['network'];

const mockedGenesisResponse = {
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
} as Responses['genesis_content'];

const expectedGenesisResponse: Cardano.CompactGenesis = {
  activeSlotsCoefficient: 0.05,
  epochLength: 432_000,
  maxKesEvolutions: 62,
  maxLovelaceSupply: 45_000_000_000_000_000n,
  networkId: Cardano.NetworkId.Mainnet,
  networkMagic: 764_824_073,
  securityParameter: 2160,
  slotLength: Seconds(1),
  slotsPerKesPeriod: 129_600,
  systemStart: new Date('2017-09-23T21:44:51.000Z'),
  updateQuorum: 5
};

describe('BlockfrostNetworkInfoProvider', () => {
  let request: jest.Mock;
  let provider: BlockfrostNetworkInfoProvider;

  beforeEach(async () => {
    request = jest.fn();
    const client = { request } as unknown as BlockfrostClient;
    provider = new BlockfrostNetworkInfoProvider(client, logger);
  });

  test('stake', async () => {
    mockResponses(request, [['network', mockedNetworkResponse]]);
    const response = await provider.stake();

    expect(response).toMatchObject<StakeSummary>({
      active: 1_060_378_314_781_343n,
      live: 15_001_884_895_856_815n
    });
  });

  test('lovelaceSupply', async () => {
    mockResponses(request, [['network', mockedNetworkResponse]]);
    const response = await provider.lovelaceSupply();

    expect(response).toMatchObject<SupplySummary>({
      circulating: 42_064_399_450_423_723n,
      total: 40_267_211_394_073_980n
    });
  });

  test('eraSummaries', async () => {
    const blockfrostResponseBody = [
      {
        end: {
          epoch: 4,
          slot: 86_400,
          time: 1_728_000
        },
        parameters: {
          epoch_length: 21_600,
          safe_zone: 4320,
          slot_length: 20
        },
        start: {
          epoch: 0,
          slot: 0,
          time: 0
        }
      },
      {
        end: {
          epoch: 5,
          slot: 518_400,
          time: 2_160_000
        },
        parameters: {
          epoch_length: 432_000,
          safe_zone: 129_600,
          slot_length: 1
        },
        start: {
          epoch: 4,
          slot: 86_400,
          time: 1_728_000
        }
      },
      {
        end: {
          epoch: 6,
          slot: 950_400,
          time: 2_592_000
        },
        parameters: {
          epoch_length: 432_000,
          safe_zone: 129_600,
          slot_length: 1
        },
        start: {
          epoch: 5,
          slot: 518_400,
          time: 2_160_000
        }
      },
      {
        end: {
          epoch: 7,
          slot: 1_382_400,
          time: 3_024_000
        },
        parameters: {
          epoch_length: 432_000,
          safe_zone: 129_600,
          slot_length: 1
        },
        start: {
          epoch: 6,
          slot: 950_400,
          time: 2_592_000
        }
      },
      {
        end: {
          epoch: 12,
          slot: 3_542_400,
          time: 5_184_000
        },
        parameters: {
          epoch_length: 432_000,
          safe_zone: 129_600,
          slot_length: 1
        },
        start: {
          epoch: 7,
          slot: 1_382_400,
          time: 3_024_000
        }
      },
      {
        end: {
          epoch: 163,
          slot: 68_774_400,
          time: 70_416_000
        },
        parameters: {
          epoch_length: 432_000,
          safe_zone: 129_600,
          slot_length: 1
        },
        start: {
          epoch: 12,
          slot: 3_542_400,
          time: 5_184_000
        }
      }
    ];
    const expected: EraSummary[] = [
      {
        parameters: {
          epochLength: 21_600,
          slotLength: Milliseconds(20_000)
        },
        start: {
          slot: 0,
          time: new Date('2017-09-23T21:44:51.000Z')
        }
      },
      {
        parameters: {
          epochLength: 432_000,
          slotLength: Milliseconds(1000)
        },
        start: {
          slot: 86_400,
          time: new Date('2017-10-13T21:44:51.000Z')
        }
      },
      {
        parameters: {
          epochLength: 432_000,
          slotLength: Milliseconds(1000)
        },
        start: {
          slot: 518_400,
          time: new Date('2017-10-18T21:44:51.000Z')
        }
      },
      {
        parameters: {
          epochLength: 432_000,
          slotLength: Milliseconds(1000)
        },
        start: {
          slot: 950_400,
          time: new Date('2017-10-23T21:44:51.000Z')
        }
      },
      {
        parameters: {
          epochLength: 432_000,
          slotLength: Milliseconds(1000)
        },
        start: {
          slot: 1_382_400,
          time: new Date('2017-10-28T21:44:51.000Z')
        }
      },
      {
        parameters: {
          epochLength: 432_000,
          slotLength: Milliseconds(1000)
        },
        start: {
          slot: 3_542_400,
          time: new Date('2017-11-22T21:44:51.000Z')
        }
      }
    ];

    mockResponses(request, [
      ['network/eras', blockfrostResponseBody],
      ['genesis', mockedGenesisResponse]
    ]);
    const response = await provider.eraSummaries();
    expect(response).toMatchObject<EraSummary[]>(expected);
  });

  test('genesisParameters', async () => {
    mockResponses(request, [['genesis', mockedGenesisResponse]]);
    const response = await provider.genesisParameters();
    expect(response).toMatchObject(expectedGenesisResponse);
  });

  test('protocolParameters', async () => {
    const mockedResponse = {
      a0: 0.3,
      coins_per_utxo_word: '0',
      cost_models: {
        PlutusV1: {
          'addInteger-cpu-arguments-intercept': 197_209,
          'addInteger-cpu-arguments-slope': 0
        },
        PlutusV2: {
          'addInteger-cpu-arguments-intercept': 197_209,
          'addInteger-cpu-arguments-slope': 0
        }
      },
      decentralisation_param: 0.5,
      key_deposit: '2000000',
      max_collateral_inputs: 1,
      max_tx_size: '16384',
      max_val_size: '1000',
      min_fee_a: 44,
      min_fee_b: 155_381,
      min_pool_cost: '340000000',
      pool_deposit: '500000000',
      protocol_major_ver: 5,
      protocol_minor_ver: 0,
      rho: 0.003,
      tau: 0.2
    };
    mockResponses(request, [['epochs/latest/parameters', mockedResponse]]);
    const response = await provider.protocolParameters();

    expect(response).toMatchObject({
      coinsPerUtxoByte: 0,
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
    mockResponses(request, [['blocks/latest', blockResponse]]);
    const response = await provider.ledgerTip();

    expect(response).toMatchObject({
      blockNo: 2_927_618,
      hash: '86e837d8a6cdfddaf364525ce9857eb93430b7e59a5fd776f0a9e11df476a7e5',
      slot: 37_767_194
    });
  });
});
