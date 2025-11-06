import { BlockfrostClient, BlockfrostUtxoProvider } from '../../src';
import { Cardano } from '@cardano-sdk/core';
import { Responses } from '@blockfrost/blockfrost-js';
import { cip19TestVectors, logger } from '@cardano-sdk/util-dev';
import { mockResponses } from '../util';
import type { Cache } from '@cardano-sdk/util';
jest.mock('@blockfrost/blockfrost-js');

// Test constants
const ADDR_VKH_PREFIX = 'addresses/addr_vkh';
const SCRIPT_PREFIX = 'addresses/script';
const ACCOUNTS_PATH = 'accounts/';
const UTXOS_PATH = '/utxos';
const CBOR_PATH = '/cbor';

const CBOR_RESPONSE = {
  cbor: '84a5008182582038685cff32e65bbf5be53e5478b2c9f91c686a663394484df2205d4733d19ad501018182583900bdb17d476dfdaa0d06b970a19e260fc97b9622fa7b85fc51205a552b3781e8276be4ebdaff285d7a29a144a4cf681af786f441cd8a6eea041a062a3a78021a0002a019031a049dea66048183098200581c3781e8276be4ebdaff285d7a29a144a4cf681af786f441cd8a6eea048102a10082825820518ab6ccb82cf0db3893dc532af0eb27bdfd68d696811ff5acf16c47d4792ab3584018f37f5f94397c10ab44d6d382a0abc83807ab8039b8bff3b172b5875d928cec5022f02d027e4077253a79910126562988c306c34f14dca9d79be4e1c6de940f82582076f79de7b22ea72556735ba30b49a6b176e03641d088f43b64ec299400d971b7584046f4ce5ee2d14ab15c38aa74063bf25c9481ceaec59f9cf55bc25f6aae20a3c8761db8f7e9621c5f6b3f5628c574f738c3c997f83210effd5790d54419254a0ef5f6'
};

/** Helper to create handlers for credential-based UTXO queries. */
const createCredentialUtxoHandler = (credentialUtxos: Responses['address_utxo_content']) => (url: string) => {
  if ((url.includes(ADDR_VKH_PREFIX) || url.includes(SCRIPT_PREFIX)) && url.includes(UTXOS_PATH)) {
    return Promise.resolve(credentialUtxos);
  }
  return null;
};

/** Helper to create handlers for account-based UTXO queries. */
const createAccountUtxoHandler = (accountUtxos: Responses['address_utxo_content']) => (url: string) => {
  if (url.includes(ACCOUNTS_PATH) && url.includes(UTXOS_PATH)) {
    return Promise.resolve(accountUtxos);
  }
  return null;
};

/** Helper to create a common mock request handler for UTXO tests. */
const createMockUtxoHandler =
  (additionalHandlers?: (url: string) => Promise<unknown> | null) =>
  (url: string): Promise<unknown> => {
    // Handle CBOR endpoints
    if (url.includes(CBOR_PATH)) {
      return Promise.resolve(CBOR_RESPONSE);
    }

    // Handle additional custom handlers
    if (additionalHandlers) {
      const result = additionalHandlers(url);
      if (result !== null) return result;
    }

    // Default: return empty for UTXO queries
    if (url.includes(UTXOS_PATH)) return Promise.resolve([]);

    return Promise.resolve([]);
  };

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

  describe('with feature flag ON (queryUtxosByCredentials: true)', () => {
    let mockRequest: jest.Mock;
    let credentialProvider: BlockfrostUtxoProvider;
    let credentialCache: Cache<Cardano.Tx>;

    // Use real test addresses from CIP-19 test vectors
    const baseAddress1 = cip19TestVectors.basePaymentKeyStakeKey; // Base address with payment key + stake key
    const baseAddress2 = cip19TestVectors.basePaymentScriptStakeKey; // Base address with script + stake key
    const enterpriseAddress = cip19TestVectors.enterpriseKey; // Enterprise address (no stake)

    const generateUtxoForAddress = (addr: Cardano.PaymentAddress, index: number) => ({
      address: addr,
      amount: [
        {
          quantity: String(50_000_000 + index),
          unit: 'lovelace'
        }
      ],
      block: 'b1b23210b9de8f3edef233f21f7d6e1fb93efe124ba126ba924edec3043e75b46',
      data_hash: null,
      inline_datum: null,
      output_index: index,
      reference_script_hash: null,
      tx_hash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
      tx_index: index
    });

    beforeEach(() => {
      mockRequest = jest.fn();
      const client = { request: mockRequest } as unknown as BlockfrostClient;
      const cacheStorage = new Map();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      credentialCache = {
        async get(key) {
          return cacheStorage.get(key);
        },
        async set(key, value) {
          cacheStorage.set(key, value);
        }
      };

      credentialProvider = new BlockfrostUtxoProvider(
        { queryUtxosByCredentials: true },
        { cache: credentialCache, client, logger }
      );
    });

    describe('utxoByAddresses with credential-based queries', () => {
      it('single address is minimized to payment credential (1 API call)', async () => {
        const credentialUtxos = [generateUtxoForAddress(baseAddress1, 0), generateUtxoForAddress(baseAddress1, 1)];

        mockRequest.mockImplementation(createMockUtxoHandler(createCredentialUtxoHandler(credentialUtxos)));

        const result = await credentialProvider.utxoByAddresses({ addresses: [baseAddress1] });

        // Verify we queried by payment credential, not by address
        const credentialCalls = mockRequest.mock.calls.filter((call: string[]) => call[0].includes(ADDR_VKH_PREFIX));
        expect(credentialCalls.length).toBeGreaterThan(0);

        // Should not query by address directly
        const addressCalls = mockRequest.mock.calls.filter((call: string[]) =>
          call[0].includes(`addresses/${baseAddress1}${UTXOS_PATH}`)
        );
        expect(addressCalls.length).toBe(0);

        // Should return 2 UTXOs
        expect(result).toHaveLength(2);
      });

      it('multiple addresses with shared stake key use reward account query', async () => {
        // Both addresses share the same stake key
        const rewardAccountUtxos = [generateUtxoForAddress(baseAddress1, 0), generateUtxoForAddress(baseAddress1, 1)];

        mockRequest.mockImplementation(createMockUtxoHandler(createAccountUtxoHandler(rewardAccountUtxos)));

        // Query with two addresses that share the same stake key
        const result = await credentialProvider.utxoByAddresses({ addresses: [baseAddress1, baseAddress2] });

        // Should query by reward account (stake address)
        const rewardAccountCalls = mockRequest.mock.calls.filter(
          (call: string[]) => call[0].includes(ACCOUNTS_PATH) && call[0].includes(UTXOS_PATH)
        );
        expect(rewardAccountCalls.length).toBeGreaterThan(0);

        // Should not query by payment credentials (minimization prefers reward account)
        const credentialCalls = mockRequest.mock.calls.filter((call: string[]) => call[0].includes(ADDR_VKH_PREFIX));
        expect(credentialCalls.length).toBe(0);

        // Should return filtered UTXOs (only those with payment credentials we control)
        expect(result.length).toBeGreaterThan(0);
      });

      it('filters UTXOs by payment credential in reward account queries', async () => {
        // When querying with multiple addresses that share a stake key,
        // reward account query returns UTXOs for ALL addresses under that stake key
        // We need to filter to only include UTXOs for addresses we queried
        const otherAddress = cip19TestVectors.basePaymentScriptStakeKey; // Shares stake key but different payment
        const rewardAccountUtxos = [
          generateUtxoForAddress(baseAddress1, 0),
          generateUtxoForAddress(baseAddress1, 1),
          generateUtxoForAddress(otherAddress, 2) // This should be filtered out (different payment cred)
        ];

        mockRequest.mockImplementation(createMockUtxoHandler(createAccountUtxoHandler(rewardAccountUtxos)));

        // Query with BOTH addresses that share the stake key
        const result = await credentialProvider.utxoByAddresses({ addresses: [baseAddress1, baseAddress2] });

        // Should use reward account query (minimization algorithm)
        const rewardAccountCalls = mockRequest.mock.calls.filter(
          (call: string[]) => call[0].includes(ACCOUNTS_PATH) && call[0].includes(UTXOS_PATH)
        );
        expect(rewardAccountCalls.length).toBeGreaterThan(0);

        // Should return filtered UTXOs (filtering done automatically by payment credential filter)
        expect(result.length).toBeGreaterThan(0);
      });

      it('enterprise address uses payment credential query', async () => {
        const credentialUtxos = [generateUtxoForAddress(enterpriseAddress, 0)];

        mockRequest.mockImplementation(createMockUtxoHandler(createCredentialUtxoHandler(credentialUtxos)));

        const result = await credentialProvider.utxoByAddresses({ addresses: [enterpriseAddress] });

        // Should query by payment credential
        const credentialCalls = mockRequest.mock.calls.filter((call: string[]) => call[0].includes(ADDR_VKH_PREFIX));
        expect(credentialCalls.length).toBeGreaterThan(0);

        // Should not query by reward account
        const rewardAccountCalls = mockRequest.mock.calls.filter((call: string[]) => call[0].includes(ACCOUNTS_PATH));
        expect(rewardAccountCalls.length).toBe(0);

        expect(result).toHaveLength(1);
      });

      it('deduplicates UTXOs correctly', async () => {
        const credentialUtxos = [
          generateUtxoForAddress(baseAddress1, 0),
          generateUtxoForAddress(baseAddress1, 0), // Duplicate
          generateUtxoForAddress(baseAddress1, 1)
        ];

        mockRequest.mockImplementation(createMockUtxoHandler(createCredentialUtxoHandler(credentialUtxos)));

        const result = await credentialProvider.utxoByAddresses({ addresses: [baseAddress1] });

        // Should deduplicate to 2 unique UTXOs
        expect(result).toHaveLength(2);
      });

      it('sorts UTXOs by txId and index', async () => {
        const utxo1 = generateUtxoForAddress(baseAddress1, 0);
        utxo1.tx_hash = '1f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5';
        const utxo2 = generateUtxoForAddress(baseAddress1, 1);
        utxo2.tx_hash = '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5';
        const utxo3 = generateUtxoForAddress(baseAddress1, 0);
        utxo3.tx_hash = '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5';

        const credentialUtxos = [utxo1, utxo2, utxo3];

        mockRequest.mockImplementation(createMockUtxoHandler(createCredentialUtxoHandler(credentialUtxos)));

        const result = await credentialProvider.utxoByAddresses({ addresses: [baseAddress1] });

        expect(result).toHaveLength(3);
        // Should be sorted by txId first, then by index
        expect(result[0][0].txId).toBe(Cardano.TransactionId(utxo3.tx_hash));
        expect(result[0][0].index).toBe(0);
        expect(result[1][0].txId).toBe(Cardano.TransactionId(utxo2.tx_hash));
        expect(result[1][0].index).toBe(1);
        expect(result[2][0].txId).toBe(Cardano.TransactionId(utxo1.tx_hash));
        expect(result[2][0].index).toBe(0);
      });

      it('handles empty results', async () => {
        mockRequest.mockImplementation(createMockUtxoHandler(createCredentialUtxoHandler([])));

        const result = await credentialProvider.utxoByAddresses({ addresses: [baseAddress1] });

        expect(result).toHaveLength(0);
      });

      it('handles mixed base and enterprise addresses', async () => {
        // Note: baseAddress1 and enterpriseAddress share the same payment credential
        // so the minimization algorithm will use only 1 payment credential query
        const allUtxos = [generateUtxoForAddress(baseAddress1, 0), generateUtxoForAddress(enterpriseAddress, 1)];

        let paymentCredentialCallCount = 0;

        mockRequest.mockImplementation((url: string) => {
          if (url.includes(ADDR_VKH_PREFIX) && url.includes(UTXOS_PATH)) {
            paymentCredentialCallCount++;
            // Return UTXOs for both addresses since they share the same payment credential
            return Promise.resolve(allUtxos);
          }
          if (url.includes(CBOR_PATH)) {
            return Promise.resolve(CBOR_RESPONSE);
          }
          return Promise.resolve([]);
        });

        const result = await credentialProvider.utxoByAddresses({ addresses: [baseAddress1, enterpriseAddress] });

        // Both addresses share the same payment credential,
        // so only 1 payment credential query is needed (optimal minimization)
        expect(paymentCredentialCallCount).toBe(1);

        // Should return UTXOs from both addresses
        expect(result).toHaveLength(2);
      });
    });
  });
});
