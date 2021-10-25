/* eslint-disable max-len */

import { GraphQLClient } from 'graphql-request';
import { NetworkInfo, ProtocolParametersRequiredByWallet, Transaction } from '@cardano-sdk/core';
import { cardanoGraphqlDbSyncProvider } from '../src';
import { Schema as Cardano } from '@cardano-ogmios/client';
jest.mock('graphql-request');

describe('cardanoGraphqlDbSyncProvider', () => {
  const uri = 'http://someurl.com';

  test('queryTransactionsByAddresses', async () => {
    const mockedResponse = {
      transactions: [
        {
          hash: '886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8',
          inputs: [
            {
              address:
                'addr_test1qr05llxkwg5t6c4j3ck5mqfax9wmz35rpcgw3qthrn9z7xcxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknstdz3k2',
              txHash: '886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8',
              sourceTxIndex: 1
            }
          ],
          outputs: [
            {
              address:
                'addr_test1qzhj44x8qdyj8uzzk98h85wmwjaxwfelnsce78y2823n67klx3h666clw83vu7askvacnvtlh0megn8ue60afer83hfseeq9q7',
              value: '1000000000',
              tokens: [
                {
                  asset: {
                    assetId: 'b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'
                  },
                  quantity: '1'
                }
              ]
            },
            {
              address:
                'addr_test1qz7xvvc30qghk00sfpzcfhsw3s2nyn7my0r8hq8c2jj47zsxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6sjg2v',
              value: '9515281005985',
              tokens: []
            }
          ]
        },
        {
          hash: '390ec1131b8cc95125f1dc2d2c02d54c79939f04f3f5723e47606279ddc822b3',
          inputs: [
            {
              address:
                'addr_test1qr05llxkwg5t6c4j3ck5mqfax9wmz35rpcgw3qthrn9z7xcxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknstdz3k2',
              txHash: '390ec1131b8cc95125f1dc2d2c02d54c79939f04f3f5723e47606279ddc822b3',
              sourceTxIndex: 1
            }
          ],
          outputs: [
            {
              address:
                'addr_test1qp5ckv784ddzn2tstt4y5c9kex3wnuza6kuz0jc66q8ezcsxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknsyqaf7l',
              value: '9514280838416',
              tokens: []
            },
            {
              address: 'addr_test1vrdkagyspkmt96k6z87rnt9dzzy8mlcex7awjymm8wx434q837u24',
              value: '1000000000',
              tokens: []
            }
          ]
        }
      ]
    };
    GraphQLClient.prototype.request = jest.fn().mockResolvedValue(mockedResponse);
    const client = cardanoGraphqlDbSyncProvider(uri);

    const response = await client.queryTransactionsByAddresses([
      'addr_test1qz7xvvc30qghk00sfpzcfhsw3s2nyn7my0r8hq8c2jj47zsxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6sjg2v'
    ]);

    expect(response).toHaveLength(2);

    expect(response[0]).toMatchObject<Transaction.Tx>({
      hash: '886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8',
      inputs: [
        {
          address:
            'addr_test1qr05llxkwg5t6c4j3ck5mqfax9wmz35rpcgw3qthrn9z7xcxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknstdz3k2',
          txId: '886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8',
          index: 1
        }
      ],
      outputs: [
        {
          address:
            'addr_test1qzhj44x8qdyj8uzzk98h85wmwjaxwfelnsce78y2823n67klx3h666clw83vu7askvacnvtlh0megn8ue60afer83hfseeq9q7',
          value: {
            coins: 1_000_000_000,
            assets: {
              b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237: BigInt('1')
            }
          }
        },
        {
          address:
            'addr_test1qz7xvvc30qghk00sfpzcfhsw3s2nyn7my0r8hq8c2jj47zsxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6sjg2v',
          value: { coins: 9_515_281_005_985, assets: {} }
        }
      ]
    });
  });

  test('queryTransactionsByHashes', async () => {
    const mockedResponse = {
      transactions: [
        {
          hash: '886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8',
          inputs: [
            {
              address:
                'addr_test1qr05llxkwg5t6c4j3ck5mqfax9wmz35rpcgw3qthrn9z7xcxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknstdz3k2',
              txHash: '886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8',
              sourceTxIndex: 1
            }
          ],
          outputs: [
            {
              address:
                'addr_test1qzhj44x8qdyj8uzzk98h85wmwjaxwfelnsce78y2823n67klx3h666clw83vu7askvacnvtlh0megn8ue60afer83hfseeq9q7',
              value: '1000000000',
              tokens: [
                {
                  asset: {
                    assetId: 'b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'
                  },
                  quantity: '1'
                }
              ]
            },
            {
              address:
                'addr_test1qz7xvvc30qghk00sfpzcfhsw3s2nyn7my0r8hq8c2jj47zsxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6sjg2v',
              value: '9515281005985',
              tokens: []
            }
          ]
        }
      ]
    };

    GraphQLClient.prototype.request = jest.fn().mockResolvedValue(mockedResponse);
    const client = cardanoGraphqlDbSyncProvider(uri);

    const response = await client.queryTransactionsByHashes([
      '886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8'
    ]);

    expect(response).toHaveLength(1);
    expect(response[0]).toMatchObject<Transaction.Tx>({
      hash: '886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8',
      inputs: [
        {
          address:
            'addr_test1qr05llxkwg5t6c4j3ck5mqfax9wmz35rpcgw3qthrn9z7xcxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknstdz3k2',
          txId: '886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8',
          index: 1
        }
      ],
      outputs: [
        {
          address:
            'addr_test1qzhj44x8qdyj8uzzk98h85wmwjaxwfelnsce78y2823n67klx3h666clw83vu7askvacnvtlh0megn8ue60afer83hfseeq9q7',
          value: {
            coins: 1_000_000_000,
            assets: {
              b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237: BigInt('1')
            }
          }
        },
        {
          address:
            'addr_test1qz7xvvc30qghk00sfpzcfhsw3s2nyn7my0r8hq8c2jj47zsxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6sjg2v',
          value: { coins: 9_515_281_005_985, assets: {} }
        }
      ]
    });
  });

  test('currentWalletProtocolParameters', async () => {
    const mockedResponse = {
      cardano: {
        currentEpoch: {
          protocolParams: {
            coinsPerUtxoWord: 34_482,
            maxTxSize: 16_384,
            maxValSize: '5000',
            keyDeposit: 2_000_000,
            maxCollateralInputs: 3,
            minFeeA: 44,
            minFeeB: 155_381,
            minPoolCost: 340_000_000,
            poolDeposit: 500_000_000,
            protocolVersion: {
              major: 5,
              minor: 5
            }
          }
        }
      }
    };

    GraphQLClient.prototype.request = jest.fn().mockResolvedValue(mockedResponse);
    const client = cardanoGraphqlDbSyncProvider(uri);

    const response = await client.currentWalletProtocolParameters();

    expect(response).toMatchObject<ProtocolParametersRequiredByWallet>({
      coinsPerUtxoWord: 34_482,
      maxTxSize: 16_384,
      maxValueSize: 5000,
      stakeKeyDeposit: 2_000_000,
      maxCollateralInputs: 3,
      minFeeCoefficient: 44,
      minFeeConstant: 155_381,
      minPoolCost: 340_000_000,
      poolDeposit: 500_000_000,
      protocolVersion: {
        major: 5,
        minor: 5
      }
    });
  });

  test('ledgerTip', async () => {
    const mockedResponse = {
      cardano: {
        tip: {
          hash: 'af310732fdd99892fa78584aca1d2be147e6001030ae51b054e38feeb4fd762d',
          number: 2_884_196,
          slotNo: 36_370_316
        }
      }
    };

    GraphQLClient.prototype.request = jest.fn().mockResolvedValue(mockedResponse);
    const client = cardanoGraphqlDbSyncProvider(uri);

    const response = await client.ledgerTip();

    expect(response).toMatchObject<Cardano.Tip>({
      hash: 'af310732fdd99892fa78584aca1d2be147e6001030ae51b054e38feeb4fd762d',
      blockNo: 2_884_196,
      slot: 36_370_316
    });
  });

  test('networkInfo', async () => {
    const mockedResponse = {
      activeStake_aggregate: {
        aggregate: {
          sum: {
            amount: '1663852188977832700'
          }
        }
      },
      ada: {
        supply: {
          circulating: '32825132667938671',
          max: '45000000000000000',
          total: '33139680532518730'
        }
      },
      cardano: {
        currentEpoch: {
          lastBlockTime: '2021-09-28T04:59:09Z',
          number: 290,
          startedAt: '2021-09-27T21:46:53Z'
        }
      }
    };

    GraphQLClient.prototype.request = jest.fn().mockResolvedValue(mockedResponse);
    const client = cardanoGraphqlDbSyncProvider(uri);

    const response = await client.networkInfo();

    expect(response).toMatchObject<NetworkInfo>({
      currentEpoch: {
        end: {
          date: new Date('2021-09-28T04:59:09Z')
        },
        number: 290,
        start: {
          date: new Date('2021-09-27T21:46:53Z')
        }
      },
      lovelaceSupply: {
        circulating: 32_825_132_667_938_671n,
        max: 45_000_000_000_000_000n,
        total: 33_139_680_532_518_730n
      },
      stake: {
        active: 1_663_852_188_977_832_700n,
        live: 0n
      }
    });
  });

  // The mocking strategy for this provider cannot handle multiple requests
  // test('stakePoolStats', async () => {
  //   GraphQLClient.prototype.request = jest.fn().mockResolvedValue({
  //     stakePool_aggregate: {
  //       aggregate: {
  //         count: '3021'
  //       }
  //     }
  //   });
  //   const client = cardanoGraphqlDbSyncProvider(uri);
  //
  //   const response = await client.stakePoolStats();
  //
  //   expect(response).toMatchObject<StakePoolStats>({
  //     qty: {
  //       active: 3021,
  //       retired: 1317,
  //       retiring: 4
  //     }
  //   });
  // });
});
