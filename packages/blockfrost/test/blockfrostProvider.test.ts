/* eslint-disable max-len */

import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { blockfrostProvider } from '../src';
import { Schema as Cardano } from '@cardano-ogmios/client';
import { Tx } from '@cardano-sdk/core';
jest.mock('@blockfrost/blockfrost-js');

describe('blockfrostProvider', () => {
  const apiKey = 'someapikey';

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
    expect(response[0]).toMatchObject<Tx>({
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
    expect(response[0]).toMatchObject<Tx>({
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
});
