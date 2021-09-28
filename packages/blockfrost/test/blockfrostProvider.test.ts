/* eslint-disable max-len */

import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { blockfrostProvider } from '../src';
import { Schema as Cardano } from '@cardano-ogmios/client';
import { NetworkInfo, StakePoolStats, Transaction } from '@cardano-sdk/core';
jest.mock('@blockfrost/blockfrost-js');

describe('blockfrostProvider', () => {
  const apiKey = 'someapikey';

  test('networkInfo', async () => {
    const mockedEpochsLatestResponse = {
      epoch: 158,
      start_time: 1_632_255_616,
      end_time: 1_632_687_616,
      first_block_time: 1_632_255_656,
      last_block_time: 1_632_571_205,
      block_count: 9593,
      tx_count: 20_736,
      output: '10876219159738237',
      fees: '4426764732',
      active_stake: '1060378314781343'
    } as Responses['epoch_content'];

    const mockedNetworkResponse = {
      stake: {
        live: '15001884895856815',
        active: '1060378314781343'
      },
      supply: {
        max: '45000000000000000',
        total: '40267211394073980',
        circulating: '42064399450423723',
        locked: '6161981104458'
      }
    } as Responses['network'];

    BlockFrostAPI.prototype.epochsLatest = jest.fn().mockResolvedValue(mockedEpochsLatestResponse);
    BlockFrostAPI.prototype.network = jest.fn().mockResolvedValue(mockedNetworkResponse);

    const client = blockfrostProvider({ projectId: apiKey, isTestnet: true });
    const response = await client.networkInfo();

    expect(response).toMatchObject<NetworkInfo>({
      currentEpoch: {
        end: {
          date: new Date(1_632_687_616)
        },
        number: 158,
        start: {
          date: new Date(1_632_255_616)
        }
      },
      lovelaceSupply: {
        circulating: 42_064_399_450_423_723n,
        max: 45_000_000_000_000_000n,
        total: 40_267_211_394_073_980n
      },
      stake: {
        active: 1_060_378_314_781_343n,
        live: 15_001_884_895_856_815n
      }
    });
  });

  test('stakePoolStats', async () => {
    const mockedActivePoolsResponse = [
      'pool1adur9jcn0dkjpm3v8ayf94yn3fe5xfk2rqfz7rfpuh6cw6evd7w',
      'pool18kd2k7kqt9gje9y0azahww4dqak9azeeg8ayl0xl7dzewg70vlf',
      'pool13dgxp4ph2ut5datuh5na4wy7hrnqgkj4fyvac3e8fzfqcc7qh0h',
      'pool1wnf793xkgrw3s800tfdkkg3s3ddgxkucenahzs7490g4q0cpe0v',
      'pool156gxlrk0e3phxadasa33yzk9e94wg7tv3au02jge8eanv9zc4ym',
      'pool1znzwjv7cr7zjdnsncrg6jrtxwd3myys9p63sj3jajpnn22mwcy2',
      'pool1qa22ym0t8w9fg0ejlp0duhzcy6a24uyfjsyx5jugrjw6wsfetyd'
    ] as Responses['pool_list'];

    const mockedRetiredPoolsResponse = [
      'pool1adur9jcn0dkjpm3v8ayf94yn3fe5xfk2rqfz7rfpuh6cw6evd7w',
      'pool18kd2k7kqt9gje9y0azahww4dqak9azeeg8ayl0xl7dzewg70vlf',
      'pool1qa22ym0t8w9fg0ejlp0duhzcy6a24uyfjsyx5jugrjw6wsfetyd'
    ] as Responses['pool_list'];

    const mockedRetiringPoolsResponse = [
      'pool1adur9jcn0dkjpm3v8ayf94yn3fe5xfk2rqfz7rfpuh6cw6evd7w',
      'pool13dgxp4ph2ut5datuh5na4wy7hrnqgkj4fyvac3e8fzfqcc7qh0h'
    ] as Responses['pool_list'];

    BlockFrostAPI.prototype.pools = jest.fn().mockResolvedValue(mockedActivePoolsResponse);
    BlockFrostAPI.prototype.poolsRetired = jest.fn().mockResolvedValue(mockedRetiredPoolsResponse);
    BlockFrostAPI.prototype.poolsRetiring = jest.fn().mockResolvedValue(mockedRetiringPoolsResponse);

    const client = blockfrostProvider({ projectId: apiKey, isTestnet: true });
    const response = await client.stakePoolStats();

    expect(response).toMatchObject<StakePoolStats>({
      qty: {
        active: 7,
        retired: 3,
        retiring: 2
      }
    });
  });

  test('utxoDelegationAndRewards', async () => {
    const addressesUtxosAllMockResponse = [
      {
        tx_hash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
        tx_index: 0,
        output_index: 0,
        amount: [
          {
            unit: 'lovelace',
            quantity: '50928877'
          },
          {
            unit: 'b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237',
            quantity: '1'
          }
        ],
        block: 'b1b23210b9de8f3edef233f21f7d6e1fb93fe124ba126ba924edec3043e75b46'
      },
      {
        tx_hash: '6f04f2cd96b609b8d5675f89fe53159bab859fb1d62bb56c6001ccf58d9ac128',
        tx_index: 0,
        output_index: 0,
        amount: [
          {
            unit: 'lovelace',
            quantity: '1097647'
          }
        ],
        block: '500de01367988d4698266ca02148bf2308eab96c0876c9df00ee843772ccb326'
      }
    ];
    BlockFrostAPI.prototype.addressesUtxosAll = jest.fn().mockResolvedValue(addressesUtxosAllMockResponse);

    const accountsMockResponse = {
      stake_address: 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27',
      active: true,
      active_epoch: 81,
      controlled_amount: '95565690389731',
      rewards_sum: '615803862289',
      withdrawals_sum: '0',
      reserves_sum: '0',
      treasury_sum: '0',
      withdrawable_amount: '615803862289',
      pool_id: 'pool1y6chk7x7fup4ms9leesdr57r4qy9cwxuee0msan72x976a6u0nc'
    };
    BlockFrostAPI.prototype.accounts = jest.fn().mockResolvedValue(accountsMockResponse);

    const client = blockfrostProvider({ projectId: apiKey, isTestnet: true });
    const response = await client.utxoDelegationAndRewards(
      ['addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'],
      'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27'
    );

    expect(response.utxo).toBeTruthy();
    expect(response.utxo[0]).toHaveLength(2);
    expect(response.utxo[0][0]).toMatchObject<Cardano.TxIn>({
      txId: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
      index: 0
    });
    expect(response.utxo[0][1]).toMatchObject<Cardano.TxOut>({
      address:
        'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
      value: {
        coins: 50_928_877,
        assets: {
          b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237: BigInt(1)
        }
      }
    });

    expect(response.utxo[1]).toHaveLength(2);
    expect(response.utxo[1][0]).toMatchObject<Cardano.TxIn>({
      txId: '6f04f2cd96b609b8d5675f89fe53159bab859fb1d62bb56c6001ccf58d9ac128',
      index: 0
    });
    expect(response.utxo[1][1]).toMatchObject<Cardano.TxOut>({
      address:
        'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
      value: {
        coins: 1_097_647,
        assets: {}
      }
    });

    expect(response.delegationAndRewards.delegate).toEqual(accountsMockResponse.pool_id);
    expect(response.delegationAndRewards.rewards).toEqual(Number(accountsMockResponse.withdrawable_amount));
  });

  test('queryTransactionsByAddresses', async () => {
    const addressesTransactionsAllMockedResponse = [
      {
        tx_hash: '4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6',
        tx_index: 1,
        block_height: 2_540_728
      }
    ];
    BlockFrostAPI.prototype.addressesTransactionsAll = jest
      .fn()
      .mockResolvedValue(addressesTransactionsAllMockedResponse);

    const txsUtxosMockedResponse = {
      hash: '4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6',
      inputs: [
        {
          address:
            'addr_test1qr05llxkwg5t6c4j3ck5mqfax9wmz35rpcgw3qthrn9z7xcxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknstdz3k2',
          amount: [
            {
              unit: 'lovelace',
              quantity: '9732978705764'
            }
          ],
          tx_hash: '6d50c330a6fba79de6949a8dcd5e4b7ffa3f9442f0c5bed7a78fa6d786c6c863',
          output_index: 1
        }
      ],
      outputs: [
        {
          address:
            'addr_test1qzx9hu8j4ah3auytk0mwcupd69hpc52t0cw39a65ndrah86djs784u92a3m5w475w3w35tyd6v3qumkze80j8a6h5tuqq5xe8y',
          amount: [
            {
              unit: 'lovelace',
              quantity: '1000000000'
            },
            {
              unit: '06f8c5655b4e2b5911fee8ef2fc66b4ce64c8835642695c730a3d108617364',
              quantity: '63'
            },
            {
              unit: '06f8c5655b4e2b5911fee8ef2fc66b4ce64c8835642695c730a3d108646464',
              quantity: '22'
            }
          ]
        },
        {
          address:
            'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x',
          amount: [
            {
              unit: 'lovelace',
              quantity: '9731978536963'
            }
          ]
        }
      ]
    };
    BlockFrostAPI.prototype.txsUtxos = jest.fn().mockResolvedValue(txsUtxosMockedResponse);

    const client = blockfrostProvider({ projectId: apiKey, isTestnet: true });

    const response = await client.queryTransactionsByAddresses([
      'addr_test1qz7xvvc30qghk00sfpzcfhsw3s2nyn7my0r8hq8c2jj47zsxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6sjg2v'
    ]);

    expect(response).toHaveLength(1);
    expect(response[0]).toMatchObject<Transaction.WithHash>({
      hash: '4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6',
      inputs: [
        {
          txId: '6d50c330a6fba79de6949a8dcd5e4b7ffa3f9442f0c5bed7a78fa6d786c6c863',
          index: 1
        }
      ],
      outputs: [
        {
          address:
            'addr_test1qzx9hu8j4ah3auytk0mwcupd69hpc52t0cw39a65ndrah86djs784u92a3m5w475w3w35tyd6v3qumkze80j8a6h5tuqq5xe8y',
          value: {
            coins: 1_000_000_000,
            assets: {
              '06f8c5655b4e2b5911fee8ef2fc66b4ce64c8835642695c730a3d108617364': BigInt(63),
              '06f8c5655b4e2b5911fee8ef2fc66b4ce64c8835642695c730a3d108646464': BigInt(22)
            }
          }
        },
        {
          address:
            'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x',
          value: {
            coins: 9_731_978_536_963,
            assets: {}
          }
        }
      ]
    });
  });

  test('queryTransactionsByHashes', async () => {
    const mockedResponse = {
      hash: '4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6',
      inputs: [
        {
          address:
            'addr_test1qr05llxkwg5t6c4j3ck5mqfax9wmz35rpcgw3qthrn9z7xcxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknstdz3k2',
          amount: [
            {
              unit: 'lovelace',
              quantity: '9732978705764'
            }
          ],
          tx_hash: '6d50c330a6fba79de6949a8dcd5e4b7ffa3f9442f0c5bed7a78fa6d786c6c863',
          output_index: 1
        }
      ],
      outputs: [
        {
          address:
            'addr_test1qzx9hu8j4ah3auytk0mwcupd69hpc52t0cw39a65ndrah86djs784u92a3m5w475w3w35tyd6v3qumkze80j8a6h5tuqq5xe8y',
          amount: [
            {
              unit: 'lovelace',
              quantity: '1000000000'
            },
            {
              unit: '06f8c5655b4e2b5911fee8ef2fc66b4ce64c8835642695c730a3d108617364',
              quantity: '63'
            },
            {
              unit: '06f8c5655b4e2b5911fee8ef2fc66b4ce64c8835642695c730a3d108646464',
              quantity: '22'
            }
          ]
        },
        {
          address:
            'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x',
          amount: [
            {
              unit: 'lovelace',
              quantity: '9731978536963'
            }
          ]
        }
      ]
    };
    BlockFrostAPI.prototype.txsUtxos = jest.fn().mockResolvedValue(mockedResponse);

    const client = blockfrostProvider({ projectId: apiKey, isTestnet: true });
    const response = await client.queryTransactionsByHashes([
      '4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6'
    ]);

    expect(response).toHaveLength(1);
    expect(response[0]).toMatchObject<Transaction.WithHash>({
      hash: '4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6',
      inputs: [
        {
          txId: '6d50c330a6fba79de6949a8dcd5e4b7ffa3f9442f0c5bed7a78fa6d786c6c863',
          index: 1
        }
      ],
      outputs: [
        {
          address:
            'addr_test1qzx9hu8j4ah3auytk0mwcupd69hpc52t0cw39a65ndrah86djs784u92a3m5w475w3w35tyd6v3qumkze80j8a6h5tuqq5xe8y',
          value: {
            coins: 1_000_000_000,
            assets: {
              '06f8c5655b4e2b5911fee8ef2fc66b4ce64c8835642695c730a3d108617364': BigInt(63),
              '06f8c5655b4e2b5911fee8ef2fc66b4ce64c8835642695c730a3d108646464': BigInt(22)
            }
          }
        },
        {
          address:
            'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x',
          value: {
            coins: 9_731_978_536_963,
            assets: {}
          }
        }
      ]
    });
  });

  test('currentWalletProtocolParameters', async () => {
    const mockedResponse = {
      data: {
        min_fee_a: 44,
        min_fee_b: 155_381,
        key_deposit: '2000000',
        pool_deposit: '500000000',
        protocol_major_ver: 5,
        protocol_minor_ver: 0,
        min_pool_cost: '340000000',
        max_tx_size: '16384',
        max_val_size: '1000',
        max_collateral_inputs: 1,
        coins_per_utxo_word: '0'
      }
    };
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    BlockFrostAPI.prototype.axiosInstance = jest.fn().mockResolvedValue(mockedResponse) as any;

    const client = blockfrostProvider({ projectId: apiKey, isTestnet: true });
    const response = await client.currentWalletProtocolParameters();

    expect(response).toMatchObject({
      minFeeCoefficient: 44,
      minFeeConstant: 155_381,
      stakeKeyDeposit: 2_000_000,
      poolDeposit: 500_000_000,
      protocolVersion: { major: 5, minor: 0 },
      minPoolCost: 340_000_000,
      maxTxSize: 16_384,
      maxValueSize: 1000,
      maxCollateralInputs: 1,
      coinsPerUtxoWord: 0
    });
  });

  test('ledgerTip', async () => {
    const mockedResponse = {
      time: 1_632_136_410,
      height: 2_927_618,
      hash: '86e837d8a6cdfddaf364525ce9857eb93430b7e59a5fd776f0a9e11df476a7e5',
      slot: 37_767_194,
      epoch: 157,
      epoch_slot: 312_794,
      slot_leader: 'pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh',
      size: 1050,
      tx_count: 3,
      output: '9249073880',
      fees: '513839',
      block_vrf: 'vrf_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4s99zvg8',
      previous_block: 'da56fa53483a3a087c893b41aa0d73a303148c2887b3f7535e0b505ea5dc10aa',
      next_block: null,
      confirmations: 0
    } as Responses['block_content'];

    BlockFrostAPI.prototype.blocksLatest = jest.fn().mockResolvedValue(mockedResponse);

    const client = blockfrostProvider({ projectId: apiKey, isTestnet: true });
    const response = await client.ledgerTip();

    expect(response).toMatchObject({
      blockNo: 2_927_618,
      hash: '86e837d8a6cdfddaf364525ce9857eb93430b7e59a5fd776f0a9e11df476a7e5',
      slot: 37_767_194
    });
  });
});
