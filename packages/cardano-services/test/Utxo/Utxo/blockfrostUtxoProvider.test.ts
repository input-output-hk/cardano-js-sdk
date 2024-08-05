/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */

import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { blockfrostUtxoProvider } from '../../../src';
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
    block: 'b1b23210b9de8f3edef233f21f7d6e1fb93fe124ba126ba924edec3043e75b46',
    output_index: num,
    tx_hash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
    tx_index: num
  })) as Responses['address_utxo_content'];

describe('blockfrostUtxoProvider', () => {
  const apiKey = 'someapikey';

  describe('healthCheck', () => {
    it('returns ok if the service reports a healthy state', async () => {
      BlockFrostAPI.prototype.health = jest.fn().mockResolvedValue({ is_healthy: true });
      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = blockfrostUtxoProvider(blockfrost);
      expect(await provider.healthCheck()).toEqual({ ok: true });
    });
    it('returns not ok if the service reports an unhealthy state', async () => {
      BlockFrostAPI.prototype.health = jest.fn().mockResolvedValue({ is_healthy: false });
      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = blockfrostUtxoProvider(blockfrost);
      expect(await provider.healthCheck()).toEqual({ ok: false });
    });
    it('throws a typed error if caught during the service interaction', async () => {
      BlockFrostAPI.prototype.health = jest
        .fn()
        .mockRejectedValue(new ProviderError(ProviderFailure.Unknown, new Error('Some error')));
      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = blockfrostUtxoProvider(blockfrost);
      await expect(provider.healthCheck()).rejects.toThrowError(ProviderError);
    });
  });

  describe('utxoByAddresses', () => {
    test('used addresses', async () => {
      BlockFrostAPI.prototype.addressesUtxos = jest
        .fn()
        .mockResolvedValueOnce(generateUtxoResponseMock(100))
        .mockResolvedValueOnce(generateUtxoResponseMock(100))
        .mockResolvedValueOnce(generateUtxoResponseMock(0));

      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const client = blockfrostUtxoProvider(blockfrost);
      const response = await client.utxoByAddresses({
        addresses: [
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
        ].map(Cardano.PaymentAddress)
      });

      expect(response).toBeTruthy();
      expect(response[0]).toHaveLength(2);
      expect(response[0][0]).toMatchObject<Cardano.TxIn>({
        index: 0,
        txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
      });
      expect(response[0][1]).toMatchObject<Cardano.TxOut>({
        address: Cardano.PaymentAddress(
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
        ),
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
        address: Cardano.PaymentAddress(
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
        ),
        value: {
          assets: new Map([
            [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 2n]
          ]),
          coins: 50_928_878n
        }
      });
    });

    test('unused addresses', async () => {
      const notFoundBody = {
        error: 'Not Found',
        message: 'The requested component has not been found.',
        status_code: 404
      };
      BlockFrostAPI.prototype.addressesUtxos = jest.fn().mockRejectedValue(notFoundBody);

      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const client = blockfrostUtxoProvider(blockfrost);
      const response = await client.utxoByAddresses({
        addresses: [
          'addr_test1qz44wna7xvs8n2ukxw0qat3vktymndgk8nerey6mlxr97s47n48hk78hcuyku03lj7qplmfqscm87j9wv3amxqaur2hs055pjt'
        ].map(Cardano.PaymentAddress)
      });
      expect(response).toBeTruthy();
      expect(response.length).toBe(0);
    });
  });
});
