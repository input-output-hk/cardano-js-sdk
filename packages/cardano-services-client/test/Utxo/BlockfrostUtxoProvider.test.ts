import { BlockfrostClient, BlockfrostUtxoProvider } from '../../src';
import { Cardano } from '@cardano-sdk/core';
import { Responses } from '@blockfrost/blockfrost-js';
import { logger } from '@cardano-sdk/util-dev';
import { mockResponses } from '../util';
import type { Cache } from '@cardano-sdk/util';
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
    const cacheStorage = new Map();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const cache: Cache<any> = {
      async get(key) {
        return cacheStorage.get(key);
      },
      async set(key, value) {
        cacheStorage.set(key, value);
      }
    };

    provider = new BlockfrostUtxoProvider({
      cache,
      client,
      logger
    });
    address = Cardano.PaymentAddress(
      'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
    );
  });

  describe('with default behavior (queryUtxosByCredentials: false)', () => {
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

      test('does not call txs/${hash}/cbor when data is cached', async () => {
        const txHash = '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5';

        mockResponses(request, [
          [
            `txs/${txHash}/cbor`,
            {
              cbor: '84a5008182582038685cff32e65bbf5be53e5478b2c9f91c686a663394484df2205d4733d19ad501018182583900bdb17d476dfdaa0d06b970a19e260fc97b9622fa7b85fc51205a552b3781e8276be4ebdaff285d7a29a144a4cf681af786f441cd8a6eea041a062a3a78021a0002a019031a049dea66048183098200581c3781e8276be4ebdaff285d7a29a144a4cf681af786f441cd8a6eea048102a10082825820518ab6ccb82cf0db3893dc532af0eb27bdfd68d696811ff5acf16c47d4792ab3584018f37f5f94397c10ab44d6d382a0abc83807ab8039b8bff3b172b5875d928cec5022f02d027e4077253a79910126562988c306c34f14dca9d79be4e1c6de940f82582076f79de7b22ea72556735ba30b49a6b176e03641d088f43b64ec299400d971b7584046f4ce5ee2d14ab15c38aa74063bf25c9481ceaec59f9cf55bc25f6aae20a3c8761db8f7e9621c5f6b3f5628c574f738c3c997f83210effd5790d54419254a0ef5f6'
            }
          ],
          [`addresses/${address.toString()}/utxos?page=1&count=100`, generateUtxoResponseMock(1)],
          [`addresses/${address.toString()}/utxos?page=2&count=100`, generateUtxoResponseMock(0)]
        ]);

        const firstResponse = await provider.utxoByAddresses({ addresses: [address] });

        expect(firstResponse).toBeTruthy();
        expect(firstResponse.length).toBe(1);

        expect(request).toHaveBeenCalled();
        request.mockClear();

        const secondResponse = await provider.utxoByAddresses({ addresses: [address] });

        expect(secondResponse).toEqual(firstResponse);

        expect(request).not.toHaveBeenCalledWith(`txs/${txHash}/cbor`, undefined);
      });
    });
  });

  describe('constructor', () => {
    it('accepts old signature (backward compatibility)', () => {
      const client = { request: jest.fn() } as unknown as BlockfrostClient;
      const cacheStorage = new Map();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const cache: Cache<any> = {
        async get(key) {
          return cacheStorage.get(key);
        },
        async set(key, value) {
          cacheStorage.set(key, value);
        }
      };

      const testProvider = new BlockfrostUtxoProvider({ cache, client, logger });

      expect(testProvider).toBeInstanceOf(BlockfrostUtxoProvider);
      // @ts-expect-error - accessing private field for testing
      expect(testProvider.queryUtxosByCredentials).toBe(false);
    });

    it('accepts new signature with options (queryUtxosByCredentials: false)', () => {
      const client = { request: jest.fn() } as unknown as BlockfrostClient;
      const cacheStorage = new Map();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const cache: Cache<any> = {
        async get(key) {
          return cacheStorage.get(key);
        },
        async set(key, value) {
          cacheStorage.set(key, value);
        }
      };

      const testProvider = new BlockfrostUtxoProvider({ queryUtxosByCredentials: false }, { cache, client, logger });

      expect(testProvider).toBeInstanceOf(BlockfrostUtxoProvider);
      // @ts-expect-error - accessing private field for testing
      expect(testProvider.queryUtxosByCredentials).toBe(false);
    });

    it('accepts new signature with options (queryUtxosByCredentials: true)', () => {
      const client = { request: jest.fn() } as unknown as BlockfrostClient;
      const cacheStorage = new Map();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const cache: Cache<any> = {
        async get(key) {
          return cacheStorage.get(key);
        },
        async set(key, value) {
          cacheStorage.set(key, value);
        }
      };

      const testProvider = new BlockfrostUtxoProvider({ queryUtxosByCredentials: true }, { cache, client, logger });

      expect(testProvider).toBeInstanceOf(BlockfrostUtxoProvider);
      // @ts-expect-error - accessing private field for testing
      expect(testProvider.queryUtxosByCredentials).toBe(true);
    });
  });
});
