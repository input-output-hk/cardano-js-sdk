import { BlockfrostClient, BlockfrostUtxoProvider } from '../../src';
import { Cardano } from '@cardano-sdk/core';
import { Responses } from '@blockfrost/blockfrost-js';
import { logger } from '@cardano-sdk/util-dev';
import { mockResponses } from '../util';
jest.mock('@blockfrost/blockfrost-js');

const generateUtxoResponseMock = (qty: number) =>
  [...Array.from({ length: qty }).keys()].map((num) => ({
    amount: [
      {
        quantity: String(50_928_877 + num),
        unit: 'lovelace'
      },
      {
        quantity: num + 1,
        unit: 'b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'
      }
    ],
    block: 'b1b23210b9de8f3edef233f21f7d6e1fb93efe124ba126ba924edec3043e75b46',
    output_index: num,
    tx_hash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
    tx_index: num
  })) as Responses['address_utxo_content'];

describe('blockfrostUtxoProvider', () => {
  let request: jest.Mock;
  let provider: BlockfrostUtxoProvider;
  let address: Cardano.PaymentAddress;

  beforeEach(async () => {
    request = jest.fn();
    const client = { request } as unknown as BlockfrostClient;
    provider = new BlockfrostUtxoProvider(client, logger);
    address = Cardano.PaymentAddress(
      'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
    );
  });

  describe('utxoByAddresses', () => {
    test('used addresses', async () => {
      mockResponses(request, [
        [`addresses/${address.toString()}/utxos?page=1&count=100`, generateUtxoResponseMock(100)],
        [`addresses/${address.toString()}/utxos?page=2&count=100`, generateUtxoResponseMock(100)],
        [`addresses/${address.toString()}/utxos?page=3&count=100`, generateUtxoResponseMock(0)]
      ]);
      const response = await provider.utxoByAddresses({
        addresses: [address]
      });

      expect(response).toBeTruthy();
      expect(response[0]).toHaveLength(2);
      expect(response[0][0]).toMatchObject<Cardano.TxIn>({
        index: 0,
        txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
      });
      expect(response[0][1]).toMatchObject<Cardano.TxOut>({
        address,
        value: {
          assets: new Map([
            [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 1n]
          ]),
          coins: 50_928_877n
        }
      });

      expect(response[1]).toHaveLength(2);
      expect(response[1][0]).toMatchObject<Cardano.TxIn>({
        index: 1,
        txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
      });
      expect(response[1][1]).toMatchObject<Cardano.TxOut>({
        address,
        value: {
          assets: new Map([
            [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 2n]
          ]),
          coins: 50_928_878n
        }
      });
    });
  });
});
