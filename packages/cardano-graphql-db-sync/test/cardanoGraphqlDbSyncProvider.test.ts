/* eslint-disable max-len */

import { GraphQLClient } from 'graphql-request';
import { Tx } from '@cardano-sdk/core';
import { cardanoGraphqlDbSyncProvider } from '../src';
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

    expect(response[0]).toMatchObject<Tx>({
      hash: '886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8',
      inputs: [
        {
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
    expect(response[0]).toMatchObject<Tx>({
      hash: '886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8',
      inputs: [
        {
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
});
