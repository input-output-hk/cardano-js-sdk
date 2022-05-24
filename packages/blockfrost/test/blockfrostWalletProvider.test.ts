/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */

import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { Cardano, StakePoolStats, WalletProvider } from '@cardano-sdk/core';
import { blockfrostWalletProvider } from '../src';

jest.mock('@blockfrost/blockfrost-js');

const generatePoolsResponseMock = (qty: number) =>
  [...Array.from({ length: qty }).keys()].map((num) => String(Math.random() * num)) as Responses['pool_list'];

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

  test('stakePoolStats', async () => {
    // Simulate batch fetching
    BlockFrostAPI.prototype.pools = jest
      .fn()
      .mockReturnValueOnce(generatePoolsResponseMock(100))
      .mockReturnValueOnce(generatePoolsResponseMock(100))
      .mockReturnValueOnce(generatePoolsResponseMock(100))
      .mockReturnValueOnce(generatePoolsResponseMock(100))
      .mockReturnValueOnce(generatePoolsResponseMock(89));

    BlockFrostAPI.prototype.poolsRetired = jest
      .fn()
      .mockReturnValueOnce(generatePoolsResponseMock(100))
      .mockReturnValueOnce(generatePoolsResponseMock(100))
      .mockReturnValueOnce(generatePoolsResponseMock(36));

    BlockFrostAPI.prototype.poolsRetiring = jest
      .fn()
      .mockReturnValueOnce(generatePoolsResponseMock(100))
      .mockReturnValueOnce(generatePoolsResponseMock(77));

    const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
    const client = blockfrostWalletProvider(blockfrost);
    const response = await client.stakePoolStats!();

    expect(response).toMatchObject<StakePoolStats>({
      qty: {
        active: 489,
        retired: 236,
        retiring: 177
      }
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

  test.todo('transactionsByAddresses (same implementation as querying by hashes)');

  describe('transactionsByHashes', () => {
    const txsUtxosResponse = {
      hash: '4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6',
      inputs: [
        {
          address:
            'addr_test1qr05llxkwg5t6c4j3ck5mqfax9wmz35rpcgw3qthrn9z7xcxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknstdz3k2',
          amount: [
            {
              quantity: '9732978705764',
              unit: 'lovelace'
            }
          ],
          output_index: 1,
          tx_hash: '6d50c330a6fba79de6949a8dcd5e4b7ffa3f9442f0c5bed7a78fa6d786c6c863'
        }
      ],
      outputs: [
        {
          address:
            'addr_test1qzx9hu8j4ah3auytk0mwcupd69hpc52t0cw39a65ndrah86djs784u92a3m5w475w3w35tyd6v3qumkze80j8a6h5tuqq5xe8y',
          amount: [
            {
              quantity: '1000000000',
              unit: 'lovelace'
            },
            {
              quantity: '63',
              unit: '06f8c5655b4e2b5911fee8ef2fc66b4ce64c8835642695c730a3d108617364'
            },
            {
              quantity: '22',
              unit: '06f8c5655b4e2b5911fee8ef2fc66b4ce64c8835642695c730a3d108646464'
            }
          ]
        },
        {
          address:
            'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x',
          amount: [
            {
              quantity: '9731978536963',
              unit: 'lovelace'
            }
          ]
        }
      ]
    };
    const protocolParametersResponse = {
      data: {
        key_deposit: '2000000',
        pool_deposit: '500000000'
      }
    };
    BlockFrostAPI.prototype.axiosInstance = jest.fn().mockResolvedValue(protocolParametersResponse) as any;
    BlockFrostAPI.prototype.txsUtxos = jest.fn().mockResolvedValue(txsUtxosResponse);

    it('without extra tx properties', async () => {
      const mockedTxResponse = {
        asset_mint_or_burn_count: 0,
        block: '356b7d7dbb696ccd12775c016941057a9dc70898d87a63fc752271bb46856940',
        block_height: 123_456,
        delegation_count: 0,
        fees: '182485',
        hash: '1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477',
        index: 1,
        invalid_before: null,
        invalid_hereafter: '13885913',
        mir_cert_count: 0,
        output_amount: [
          {
            quantity: '42000000',
            unit: 'lovelace'
          },
          {
            quantity: '12',
            unit: 'b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e'
          }
        ],
        pool_retire_count: 0,
        pool_update_count: 0,
        redeemer_count: 0,
        size: 433,
        slot: 42_000_000,
        stake_cert_count: 0,
        utxo_count: 2,
        valid_contract: true,
        withdrawal_count: 0
      };
      const mockedMetadataResponse = [
        {
          json_metadata: {
            hash: '6bf124f217d0e5a0a8adb1dbd8540e1334280d49ab861127868339f43b3948af',
            metadata: 'https://nut.link/metadata.json'
          },
          label: '1967'
        },
        {
          json_metadata: {
            ADAUSD: [
              {
                source: 'ergoOracles',
                value: 3
              }
            ]
          },
          label: '1968'
        }
      ];
      BlockFrostAPI.prototype.txs = jest.fn().mockResolvedValue(mockedTxResponse);
      BlockFrostAPI.prototype.txsMetadata = jest.fn().mockResolvedValue(mockedMetadataResponse);
      const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
      const client = blockfrostWalletProvider(blockfrost);
      const response = await client.transactionsByHashes(
        ['4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6'].map(Cardano.TransactionId)
      );

      expect(response).toHaveLength(1);
      expect(response[0]).toMatchObject({
        auxiliaryData: {
          body: {
            blob: new Map<bigint, Cardano.Metadatum>([
              [
                1967n,
                new Map([
                  ['hash', '6bf124f217d0e5a0a8adb1dbd8540e1334280d49ab861127868339f43b3948af'],
                  ['metadata', 'https://nut.link/metadata.json']
                ])
              ],
              [
                1968n,
                new Map([
                  [
                    'ADAUSD',
                    [
                      new Map<Cardano.Metadatum, Cardano.Metadatum>([
                        ['source', 'ergoOracles'],
                        ['value', 3n]
                      ])
                    ]
                  ]
                ])
              ]
            ])
          }
        },
        blockHeader: {
          blockNo: 123_456,
          hash: Cardano.BlockId('356b7d7dbb696ccd12775c016941057a9dc70898d87a63fc752271bb46856940'),
          slot: 42_000_000
        },
        body: {
          fee: 182_485n,
          inputs: [
            {
              address: Cardano.Address(
                'addr_test1qr05llxkwg5t6c4j3ck5mqfax9wmz35rpcgw3qthrn9z7xcxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknstdz3k2'
              ),
              index: 1,
              txId: Cardano.TransactionId('6d50c330a6fba79de6949a8dcd5e4b7ffa3f9442f0c5bed7a78fa6d786c6c863')
            }
          ],
          outputs: [
            {
              address: Cardano.Address(
                'addr_test1qzx9hu8j4ah3auytk0mwcupd69hpc52t0cw39a65ndrah86djs784u92a3m5w475w3w35tyd6v3qumkze80j8a6h5tuqq5xe8y'
              ),
              value: {
                assets: new Map([
                  [Cardano.AssetId('06f8c5655b4e2b5911fee8ef2fc66b4ce64c8835642695c730a3d108617364'), 63n],
                  [Cardano.AssetId('06f8c5655b4e2b5911fee8ef2fc66b4ce64c8835642695c730a3d108646464'), 22n]
                ]),
                coins: 1_000_000_000n
              }
            },
            {
              address: Cardano.Address(
                'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
              ),
              value: {
                assets: {},
                coins: 9_731_978_536_963n
              }
            }
          ],
          validityInterval: {
            invalidHereafter: 13_885_913
          }
        },
        id: Cardano.TransactionId('4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6'),
        implicitCoin: {
          deposit: 0n,
          input: 0n
        },
        index: 1,
        txSize: 433
      } as Cardano.TxAlonzo);
    });
    it.todo('with withdrawals');
    it.todo('with redeemer');
    it.todo('with mint');
    it.todo('with MIR cert');
    it.todo('with delegation cert');
    it.todo('with stake certs');
    it.todo('with pool update certs');
    it.todo('with pool retire certs');
    it.todo('with metadata');
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

  test('blocksByHashes', async () => {
    BlockFrostAPI.prototype.blocks = jest.fn().mockResolvedValue(blockResponse);

    const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
    const client = blockfrostWalletProvider(blockfrost);
    const response = await client.blocksByHashes([
      Cardano.BlockId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed')
    ]);

    expect(response).toMatchObject([
      {
        confirmations: 0,
        date: new Date(1_632_136_410_000),
        epoch: 157,
        epochSlot: 312_794,
        fees: 513_839n,
        header: {
          blockNo: 2_927_618,
          hash: Cardano.BlockId('86e837d8a6cdfddaf364525ce9857eb93430b7e59a5fd776f0a9e11df476a7e5'),
          slot: 37_767_194
        },
        nextBlock: undefined,
        previousBlock: Cardano.BlockId('da56fa53483a3a087c893b41aa0d73a303148c2887b3f7535e0b505ea5dc10aa'),
        size: 1050,
        slotLeader: Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh'),
        totalOutput: 9_249_073_880n,
        txCount: 3,
        vrf: Cardano.VrfVkBech32('vrf_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4s99zvg8')
      } as Cardano.Block
    ]);
  });

  test('blocksByHashes, genesis delegate slot leader', async () => {
    const slotLeader = 'ShelleyGenesis-eff1b5b26e65b791';
    BlockFrostAPI.prototype.blocks = jest.fn().mockResolvedValue({ ...blockResponse, slot_leader: slotLeader });

    const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
    const client = blockfrostWalletProvider(blockfrost);
    const response = await client.blocksByHashes([
      Cardano.BlockId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed')
    ]);

    expect(response[0].slotLeader).toBe(slotLeader);
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
