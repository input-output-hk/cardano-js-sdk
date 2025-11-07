import { BlockfrostChainHistoryProvider, BlockfrostClient } from '../../src';
import { Cardano, NetworkInfoProvider } from '@cardano-sdk/core';
import { Responses } from '@blockfrost/blockfrost-js';
import { cip19TestVectors } from '@cardano-sdk/util-dev';
import { dummyLogger as logger } from 'ts-log';
import { mockResponses } from '../util';
import type { Cache } from '@cardano-sdk/util';

jest.mock('@blockfrost/blockfrost-js');

// Test constants
const MOCK_EPOCH_PARAMS = { key_deposit: '0', pool_deposit: '0' };
const CBOR_NULL_ERROR = new Error('CBOR is null');
const ADDR_VKH_PREFIX = 'addresses/addr_vkh';
const TRANSACTIONS_PATH = '/transactions';
const UTXOS_PATH = '/utxos';
const EPOCHS_PATH = 'epochs/';
const CBOR_PATH = '/cbor';
const ACCOUNTS_PATH = 'accounts/';

// Mock endpoints that return empty arrays
const EMPTY_ENDPOINTS = [
  '/metadata',
  '/mirs',
  '/pool_updates',
  '/pool_retires',
  '/stakes',
  '/delegations',
  '/withdrawals',
  '/redeemers'
];

/** Helper to create handlers for credential-based queries. */
const createCredentialHandler = (credentialTxs: unknown[]) => (url: string) => {
  if (url.includes(ADDR_VKH_PREFIX) && url.includes(TRANSACTIONS_PATH)) return Promise.resolve(credentialTxs);
  return null;
};

/** Helper to create handlers for account-based queries. */
const createAccountHandler = (accountTxs: unknown[]) => (url: string) => {
  if (url.includes(ACCOUNTS_PATH) && url.includes(TRANSACTIONS_PATH)) return Promise.resolve(accountTxs);
  return null;
};

/** Helper to create a common mock request handler for transaction detail tests. */
const createMockRequestHandler =
  (
    txResponses: Record<string, unknown>,
    utxosResponse: unknown,
    additionalHandlers?: (url: string) => Promise<unknown> | null
  ) =>
  (url: string): Promise<unknown> => {
    // Handle transaction detail endpoints
    for (const txId of Object.keys(txResponses)) {
      if (url === `txs/${txId}`) return Promise.resolve(txResponses[txId]);
    }

    // Handle empty endpoints
    for (const endpoint of EMPTY_ENDPOINTS) {
      if (url.includes(endpoint)) return Promise.resolve([]);
    }

    // Handle standard endpoints
    if (url.includes(UTXOS_PATH)) return Promise.resolve(utxosResponse);
    if (url.includes(EPOCHS_PATH)) return Promise.resolve(MOCK_EPOCH_PARAMS);
    if (url.includes(CBOR_PATH)) throw CBOR_NULL_ERROR;

    // Handle additional custom handlers
    if (additionalHandlers) {
      const result = additionalHandlers(url);
      if (result !== null) return result;
    }

    // Default: return empty for transaction queries
    if (url.includes(TRANSACTIONS_PATH)) return Promise.resolve([]);

    return Promise.resolve([]);
  };

describe('blockfrostChainHistoryProvider', () => {
  describe('with default behavior (queryTxsByCredentials: false)', () => {
    let request: jest.Mock;
    let provider: BlockfrostChainHistoryProvider;
    let networkInfoProvider: NetworkInfoProvider;

    const txId1 = Cardano.TransactionId('1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477');
    const txId2 = Cardano.TransactionId('2e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477');
    const address1 = Cardano.PaymentAddress('2cWKMJemoBai9J7kVvRTukMmdfxtjL9z7c396rTfrrzfAZ6EeQoKLC2y1k34hswwm4SVr');
    const address2 = Cardano.PaymentAddress(
      'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
    );
    const txsUtxosResponse = {
      hash: txId1,
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
    const mockedTx1Response = {
      asset_mint_or_burn_count: 5,
      block: '356b7d7dbb696ccd12775c016941057a9dc70898d87a63fc752271bb46856940',
      block_height: 123_456,
      delegation_count: 0,
      fees: '182485',
      hash: txId1,
      index: 1,
      invalid_before: null,
      invalid_hereafter: '13885913',
      mir_cert_count: 1,
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
      pool_retire_count: 1,
      pool_update_count: 1,
      redeemer_count: 1,
      size: 433,
      slot: 42_000_000,
      stake_cert_count: 1,
      utxo_count: 5,
      valid_contract: true,
      withdrawal_count: 1
    };
    const mockedTx2Response = {
      ...mockedTx1Response,
      hash: txId2
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
    const mockedMirResponse = [
      {
        address: 'stake1u9r76ypf5fskppa0cmttas05cgcswrttn6jrq4yd7jpdnvc7gt0yc',
        amount: '431833601',
        cert_index: 0,
        pot: 'reserve'
      }
    ];
    const mockedPoolUpdateResponse = [
      {
        active_epoch: 210,
        cert_index: 0,
        fixed_cost: '340000000',
        margin_cost: 0.05,
        metadata: {
          description: 'The best pool ever',
          hash: '47c0c68cb57f4a5b4a87bad896fc274678e7aea98e200fa14a1cb40c0cab1d8c',
          homepage: 'https://stakentus.com/',
          name: 'Stake Nuts',
          ticker: 'NUTS',
          url: 'https://stakenuts.com/mainnet.json'
        },
        owners: ['stake1u98nnlkvkk23vtvf9273uq7cph5ww6u2yq2389psuqet90sv4xv9v'],
        pledge: '5000000000',
        pool_id: 'pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy',
        relays: [
          {
            dns: 'relay1.stakenuts.com',
            dns_srv: '_relays._tcp.relays.stakenuts.com',
            ipv4: '4.4.4.4',
            ipv6: 'https://stakenuts.com/mainnet.json',
            port: 3001
          }
        ],
        reward_account: 'stake1uxkptsa4lkr55jleztw43t37vgdn88l6ghclfwuxld2eykgpgvg3f',
        vrf_key: '0b5245f9934ec2151116fb8ec00f35fd00e0aa3b075c4ed12cce440f999d8233'
      }
    ];
    const mockedPoolRetireResponse = [
      {
        cert_index: 0,
        pool_id: 'pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy',
        retiring_epoch: 216
      }
    ];
    const mockedStakeResponse = [
      {
        address: 'stake1u9t3a0tcwune5xrnfjg4q7cpvjlgx9lcv0cuqf5mhfjwrvcwrulda',
        cert_index: 0,
        registration: true
      }
    ];
    const mockedDelegationResponse = [
      {
        active_epoch: 210,
        address: 'stake1u9r76ypf5fskppa0cmttas05cgcswrttn6jrq4yd7jpdnvc7gt0yc',
        cert_index: 0,
        pool_id: 'pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy'
      }
    ];
    const mockedWithdrawalResponse = [
      {
        address: 'stake1u9r76ypf5fskppa0cmttas05cgcswrttn6jrq4yd7jpdnvc7gt0yc',
        amount: '431833601'
      }
    ];
    const mockedReedemerResponse = [
      {
        fee: '172033',
        purpose: 'spend',
        redeemer_data_hash: '923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec',
        script_hash: 'ec26b89af41bef0f7585353831cb5da42b5b37185e0c8a526143b824',
        tx_index: 0,
        unit_mem: '1700',
        unit_steps: '476468'
      }
    ];

    const mockedAddressTransactionResponse: Responses['address_transactions_content'] = [
      {
        block_height: 123,
        block_time: 131_322,
        tx_hash: txId1,
        tx_index: 0
      }
    ];
    const mockedAddress2TransactionResponse: Responses['address_transactions_content'] = [
      {
        block_height: 124,
        block_time: 131_322,
        tx_hash: txId2,
        tx_index: 0
      }
    ];
    const mockedAddressTransactionDescResponse: Responses['address_transactions_content'] = [];
    const mockedEpochParametersResponse = { key_deposit: '0', pool_deposit: '0' };
    const expectedHydratedTx = {
      auxiliaryData: {
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
      },
      blockHeader: {
        blockNo: Cardano.BlockNo(123_456),
        hash: Cardano.BlockId('356b7d7dbb696ccd12775c016941057a9dc70898d87a63fc752271bb46856940'),
        slot: Cardano.Slot(42_000_000)
      },
      body: {
        certificates: [
          {
            __typename: Cardano.CertificateType.PoolRetirement,
            epoch: 216,
            poolId: 'pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy'
          } as unknown as Cardano.HydratedCertificate,
          {
            __typename: 'PoolRegistrationCertificate',
            deposit: 0n,
            poolId: 'pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy',
            poolParameters: {
              cost: 340_000_000n,
              id: 'pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy',
              margin: {
                denominator: 20,
                numerator: 1
              },
              owners: [],
              pledge: 5_000_000_000n,
              relays: [],
              rewardAccount: 'stake1uxkptsa4lkr55jleztw43t37vgdn88l6ghclfwuxld2eykgpgvg3f',
              vrf: '0b5245f9934ec2151116fb8ec00f35fd00e0aa3b075c4ed12cce440f999d8233'
            }
          },
          {
            __typename: 'MirCertificate',
            kind: 'ToStakeCreds',
            pot: 'reserve',
            quantity: 431_833_601n,
            rewardAccount: 'stake1u9r76ypf5fskppa0cmttas05cgcswrttn6jrq4yd7jpdnvc7gt0yc'
          },
          {
            __typename: 'RegistrationCertificate',
            deposit: 0n,
            stakeCredential: {
              hash: '571ebd7877279a18734c91507b0164be8317f863f1c0269bba64e1b3',
              type: 0
            }
          }
        ],
        collateralReturn: undefined,
        collaterals: new Array<Cardano.HydratedTxIn>(),
        fee: 182_485n,
        inputs: [
          {
            address: Cardano.PaymentAddress(
              'addr_test1qr05llxkwg5t6c4j3ck5mqfax9wmz35rpcgw3qthrn9z7xcxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknstdz3k2'
            ),
            index: 1,
            txId: Cardano.TransactionId('6d50c330a6fba79de6949a8dcd5e4b7ffa3f9442f0c5bed7a78fa6d786c6c863')
          }
        ],
        mint: new Map([
          [Cardano.AssetId('06f8c5655b4e2b5911fee8ef2fc66b4ce64c8835642695c730a3d108617364'), 63n],
          [Cardano.AssetId('06f8c5655b4e2b5911fee8ef2fc66b4ce64c8835642695c730a3d108646464'), 22n]
        ]),
        outputs: [
          {
            address: Cardano.PaymentAddress(
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
            address: Cardano.PaymentAddress(
              'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
            ),
            value: {
              coins: 9_731_978_536_963n
            }
          }
        ],
        proposalProcedures: undefined,
        validityInterval: {
          invalidBefore: undefined,
          invalidHereafter: Cardano.Slot(13_885_913)
        },
        votingProcedures: undefined,
        withdrawals: [
          {
            quantity: 431_833_601n,
            stakeAddress: 'stake1u9r76ypf5fskppa0cmttas05cgcswrttn6jrq4yd7jpdnvc7gt0yc'
          }
        ]
      },
      id: Cardano.TransactionId('1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477'),
      index: 1,
      inputSource: Cardano.InputSource.inputs,
      txSize: 433,
      witness: {
        redeemers: [
          {
            data: Buffer.from(
              new Uint8Array([110, 111, 116, 32, 105, 109, 112, 108, 101, 109, 101, 110, 116, 101, 100])
            ),
            executionUnits: {
              memory: 1700,
              steps: 476_468
            },
            index: 0,
            purpose: 'spend'
          } as Cardano.Redeemer
        ],
        signatures: new Map() // not available in blockfrost
      }
    } as Cardano.HydratedTx;

    beforeEach(() => {
      request = jest.fn();
      const client = { request } as unknown as BlockfrostClient;
      networkInfoProvider = {
        eraSummaries: jest.fn().mockResolvedValue([
          {
            end: { slot: 100, time: new Date(1_506_203_092_000) },
            parameters: { epochLength: 100, safeZone: 0, slotLength: 1 },
            start: { slot: 0, time: new Date(1_506_203_091_000) }
          }
        ])
      } as unknown as NetworkInfoProvider;
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

      provider = new BlockfrostChainHistoryProvider({
        cache,
        client,
        logger,
        networkInfoProvider
      });
      mockResponses(request, [
        [`txs/${txId1}/utxos`, txsUtxosResponse],
        [`txs/${txId1}`, mockedTx1Response],
        [`txs/${txId1}/metadata`, mockedMetadataResponse],
        [`txs/${txId1}/mirs`, mockedMirResponse],
        [`txs/${txId1}/pool_updates`, mockedPoolUpdateResponse],
        [`txs/${txId1}/pool_retires`, mockedPoolRetireResponse],
        [`txs/${txId1}/stakes`, mockedStakeResponse],
        [`txs/${txId1}/delegations`, mockedDelegationResponse],
        [`txs/${txId1}/withdrawals`, mockedWithdrawalResponse],
        [`txs/${txId1}/redeemers`, mockedReedemerResponse],
        [`txs/${txId2}/utxos`, txsUtxosResponse],
        [`txs/${txId2}`, mockedTx2Response],
        [`txs/${txId2}/metadata`, mockedMetadataResponse],
        [`txs/${txId2}/mirs`, mockedMirResponse],
        [`txs/${txId2}/pool_updates`, mockedPoolUpdateResponse],
        [`txs/${txId2}/pool_retires`, mockedPoolRetireResponse],
        [`txs/${txId2}/stakes`, mockedStakeResponse],
        [`txs/${txId2}/delegations`, mockedDelegationResponse],
        [`txs/${txId2}/withdrawals`, mockedWithdrawalResponse],
        [`txs/${txId2}/redeemers`, mockedReedemerResponse],
        [`addresses/${address1}/transactions?page=1&count=20`, mockedAddressTransactionResponse],
        [`addresses/${address1}/transactions?page=1&count=1`, mockedAddressTransactionResponse],
        [`addresses/${address2}/transactions?page=1&count=1`, mockedAddress2TransactionResponse],
        [
          `addresses/${Cardano.PaymentAddress(
            'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
          )}/transactions?page=1&count=20`,
          mockedAddressTransactionResponse
        ],
        [
          'addresses/2cWKMJemoBai9J7kVvRTukMmdfxtjL9z7c396rTfrrzfAZ6EeQoKLC2y1k34hswwm4SVr/transactions?page=1&count=20&order=desc',
          mockedAddressTransactionDescResponse
        ],
        ['epochs/420000/parameters', mockedEpochParametersResponse],
        [`txs/${txId1}/cbor`, new Error('CBOR is null')]
      ]);
    });

    describe('transactionsBy*', () => {
      describe('transactionsByAddresses', () => {
        test('converts responses correctly', async () => {
          const response = await provider.transactionsByAddresses({
            addresses: [
              Cardano.PaymentAddress('2cWKMJemoBai9J7kVvRTukMmdfxtjL9z7c396rTfrrzfAZ6EeQoKLC2y1k34hswwm4SVr')
            ],
            pagination: { limit: 20, startAt: 0 }
          });

          expect(response.totalResultCount).toBe(mockedAddressTransactionResponse.length);
          expect(response.pageResults[0]).toEqual(expectedHydratedTx);
        });
        test('supports desc order', async () => {
          const response = await provider.transactionsByAddresses({
            addresses: [
              Cardano.PaymentAddress('2cWKMJemoBai9J7kVvRTukMmdfxtjL9z7c396rTfrrzfAZ6EeQoKLC2y1k34hswwm4SVr')
            ],
            pagination: { limit: 20, order: 'desc', startAt: 0 }
          });

          expect(response.totalResultCount).toBe(0);
        });
        test('deduplicates transactions', async () => {
          const response = await provider.transactionsByAddresses({
            addresses: [
              Cardano.PaymentAddress('2cWKMJemoBai9J7kVvRTukMmdfxtjL9z7c396rTfrrzfAZ6EeQoKLC2y1k34hswwm4SVr'),
              Cardano.PaymentAddress(
                'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
              )
            ],
            pagination: { limit: 20, startAt: 0 }
          });
          expect(response.pageResults).toHaveLength(mockedAddressTransactionResponse.length);
          expect(response.totalResultCount).toBe(mockedAddressTransactionResponse.length);
        });
        test('returns up to the {limit*addresses.length} number of transactions', async () => {
          const response = await provider.transactionsByAddresses({
            addresses: [address1, address2],
            pagination: { limit: 1, startAt: 0 }
          });

          const totalResultCount = mockedAddressTransactionResponse.length + mockedAddress2TransactionResponse.length;
          expect(response.totalResultCount).toBe(totalResultCount);
          expect(response.pageResults.length).toBe(totalResultCount);
        });
      });

      describe('transactionsByHashes', () => {
        test('converts responses correctly', async () => {
          const response = await provider.transactionsByHashes({
            ids: ['1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477'].map(Cardano.TransactionId)
          });

          expect(response).toHaveLength(1);
          expect(response[0]).toEqual(expectedHydratedTx);
        });
      });
    });
    describe('transactionsBy* with CBOR', () => {
      const mockedCborResponse = {
        cbor: '84a90082825820262e95982cfe9fbc565a0e9a5343d323be8e08e51de23a5262b75ce6984179a900825820262e95982cfe9fbc565a0e9a5343d323be8e08e51de23a5262b75ce6984179a9010d81825820262e95982cfe9fbc565a0e9a5343d323be8e08e51de23a5262b75ce6984179a90112818258205de304d9c8884dd62ad8535d529e3d8fd5f212cc3c0c39410e4f3bccfca6e46b010182a300581d7039a4c3afe97b4c2d3385fefd5206d1865c74786b7ce955ebb6532e7a01821a001b9f18a1581cdab1406f1c769fbdb00514c494eed47a54c7ffc5d7aafc524cca069aa14d446a65644f7261636c654e465401028201d81858a6d8799f58404fe28ad1e94e742a6c79eb8f7cc44128965579792e4b5be940bfa61c3797914970fe2055016c2b7c3bbd9de43194e82b22a4ccdbee80b4099f73a304d9550707d8799fd8799f1a000f42401a00053dc9ffd8799fd8799fd87a9f1b00000192515efa80ffd87a80ffd8799fd87a9f1b00000192516cb620ffd87a80ffff43555344ff581cdab1406f1c769fbdb00514c494eed47a54c7ffc5d7aafc524cca069aff82583900f0a26fc170ad82b64a3d43dede08e78ea6e2028b5101058d0263a80a4c0ec23eba3aa27a4b8d61107f59f3e0d24b7bb6d7ae1a4bbd689c8d1abe8373ea021a0003ff5f031a044e9894081a044e95100e81581cf0a26fc170ad82b64a3d43dede08e78ea6e2028b5101058d0263a80a0b58205b3d8c3bc5032e4d2dbe3c07d23d7fb5133f4ec7466e73744317cebe2ed12610a200818258205401b7f67442e6cc870fbcffe921d24ab03e97e03bb655a24b4f424fd832c61558405bddd2f0d88e254ef1f0a84276aaadea4df3b05f8c441d9774b6a8d1c2556437a79e5131ea4475169d45e6e02bb3b31cd93216c5499e2c316aa68e485d6800000581840000d87980821a0006a7f41a0ab2d5a5f5f6'
      };
      const expectedHydratedTxCBOR = {
        auxiliaryData: undefined,
        blockHeader: {
          blockNo: Cardano.BlockNo(123_456),
          hash: Cardano.BlockId('356b7d7dbb696ccd12775c016941057a9dc70898d87a63fc752271bb46856940'),
          slot: Cardano.Slot(42_000_000)
        },
        body: {
          certificates: undefined,
          collateralReturn: undefined,
          collaterals: new Array<Cardano.HydratedTxIn>(),
          fee: 261_983n,
          inputs: [
            {
              address: Cardano.PaymentAddress(
                'addr_test1qr05llxkwg5t6c4j3ck5mqfax9wmz35rpcgw3qthrn9z7xcxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknstdz3k2'
              ),
              index: 1,
              txId: Cardano.TransactionId('6d50c330a6fba79de6949a8dcd5e4b7ffa3f9442f0c5bed7a78fa6d786c6c863')
            }
          ],
          mint: undefined,
          outputs: [
            {
              address: Cardano.PaymentAddress(
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
              address: Cardano.PaymentAddress(
                'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
              ),
              value: {
                coins: 9_731_978_536_963n
              }
            }
          ],
          proposalProcedures: undefined,
          validityInterval: {
            invalidBefore: Cardano.Slot(72_258_832),
            invalidHereafter: Cardano.Slot(72_259_732)
          },
          votingProcedures: undefined,
          withdrawals: undefined
        },
        id: Cardano.TransactionId('1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477'),
        index: 1,
        inputSource: Cardano.InputSource.inputs,
        txSize: 433,
        witness: {
          redeemers: [
            {
              data: Buffer.from(
                new Uint8Array([110, 111, 116, 32, 105, 109, 112, 108, 101, 109, 101, 110, 116, 101, 100])
              ),
              executionUnits: {
                memory: 436_212,
                steps: 179_492_261
              },
              index: 0,
              purpose: 'spend'
            }
          ],
          signatures: new Map()
        }
      } as Cardano.HydratedTx;

      beforeEach(() => {
        const txId = Cardano.TransactionId('1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477');
        const id = txId.toString();
        mockResponses(request, [
          [`txs/${id}/utxos`, txsUtxosResponse],
          [`txs/${id}`, mockedTx1Response],
          [`txs/${id}/metadata`, mockedMetadataResponse],
          [`txs/${id}/mirs`, mockedMirResponse],
          [`txs/${id}/pool_updates`, mockedPoolUpdateResponse],
          [`txs/${id}/pool_retires`, mockedPoolRetireResponse],
          [`txs/${id}/stakes`, mockedStakeResponse],
          [`txs/${id}/delegations`, mockedDelegationResponse],
          [`txs/${id}/withdrawals`, mockedWithdrawalResponse],
          [`txs/${id}/redeemers`, mockedReedemerResponse],
          [
            `addresses/${Cardano.PaymentAddress(
              '2cWKMJemoBai9J7kVvRTukMmdfxtjL9z7c396rTfrrzfAZ6EeQoKLC2y1k34hswwm4SVr'
            ).toString()}/transactions?page=1&count=20`,
            mockedAddressTransactionResponse
          ],
          ['epochs/420000/parameters', mockedEpochParametersResponse],
          [`txs/${id}/cbor`, mockedCborResponse]
        ]);
      });

      describe('transactionsByAddresses (CBOR)', () => {
        test('converts responses correctly (CBOR)', async () => {
          const response = await provider.transactionsByAddresses({
            addresses: [
              Cardano.PaymentAddress('2cWKMJemoBai9J7kVvRTukMmdfxtjL9z7c396rTfrrzfAZ6EeQoKLC2y1k34hswwm4SVr')
            ],
            pagination: { limit: 20, startAt: 0 }
          });

          expect(response.totalResultCount).toBe(mockedAddressTransactionResponse.length);
          expect(response.pageResults[0]).toEqual(expectedHydratedTxCBOR);
        });
      });

      describe('transactionsByHashes (CBOR)', () => {
        test('converts responses correctly (CBOR)', async () => {
          const response = await provider.transactionsByHashes({
            ids: ['1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477'].map(Cardano.TransactionId)
          });

          expect(response).toHaveLength(1);
          expect(response[0]).toEqual(expectedHydratedTxCBOR);
        });
      });

      test('caches transactions and returns them from the cache on subsequent calls', async () => {
        const firstResponse = await provider.transactionsByHashes({
          ids: ['1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477' as Cardano.TransactionId]
        });

        expect(firstResponse).toHaveLength(1);
        expect(firstResponse[0]).toEqual(expectedHydratedTxCBOR);
        expect(request).toHaveBeenCalled();

        request.mockClear();

        const secondResponse = await provider.transactionsByHashes({
          ids: ['1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477' as Cardano.TransactionId]
        });

        expect(secondResponse).toHaveLength(1);
        expect(secondResponse[0]).toEqual(expectedHydratedTxCBOR);
        expect(request).not.toHaveBeenCalled();
      });
    });
  });

  describe('constructor overloads', () => {
    let client: BlockfrostClient;
    let cache: Cache<Cardano.HydratedTx>;
    let networkInfoProvider: NetworkInfoProvider;

    beforeEach(() => {
      const request = jest.fn();
      client = { request } as unknown as BlockfrostClient;
      networkInfoProvider = {
        eraSummaries: jest.fn().mockResolvedValue([
          {
            end: { slot: 100, time: new Date(1_506_203_092_000) },
            parameters: { epochLength: 100, safeZone: 0, slotLength: 1 },
            start: { slot: 0, time: new Date(1_506_203_091_000) }
          }
        ])
      } as unknown as NetworkInfoProvider;
      const cacheStorage = new Map();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      cache = {
        async get(key) {
          return cacheStorage.get(key);
        },
        async set(key, value) {
          cacheStorage.set(key, value);
        }
      };
    });

    test('old constructor signature works (backward compatibility)', () => {
      const provider = new BlockfrostChainHistoryProvider({
        cache,
        client,
        logger,
        networkInfoProvider
      });

      expect(provider).toBeInstanceOf(BlockfrostChainHistoryProvider);
      // @ts-expect-error accessing protected property for testing
      expect(provider.queryTxsByCredentials).toBe(false);
    });

    test('new constructor signature with queryTxsByCredentials: false', () => {
      const provider = new BlockfrostChainHistoryProvider(
        { queryTxsByCredentials: false },
        {
          cache,
          client,
          logger,
          networkInfoProvider
        }
      );

      expect(provider).toBeInstanceOf(BlockfrostChainHistoryProvider);
      // @ts-expect-error accessing protected property for testing
      expect(provider.queryTxsByCredentials).toBe(false);
    });

    test('new constructor signature with queryTxsByCredentials: true', () => {
      const provider = new BlockfrostChainHistoryProvider(
        { queryTxsByCredentials: true },
        {
          cache,
          client,
          logger,
          networkInfoProvider
        }
      );

      expect(provider).toBeInstanceOf(BlockfrostChainHistoryProvider);
      // @ts-expect-error accessing protected property for testing
      expect(provider.queryTxsByCredentials).toBe(true);
    });

    test('new constructor signature defaults to false when not specified', () => {
      const provider = new BlockfrostChainHistoryProvider(
        {},
        {
          cache,
          client,
          logger,
          networkInfoProvider
        }
      );

      expect(provider).toBeInstanceOf(BlockfrostChainHistoryProvider);
      // @ts-expect-error accessing protected property for testing
      expect(provider.queryTxsByCredentials).toBe(false);
    });
  });

  describe('with feature flag ON (queryTxsByCredentials: true)', () => {
    let request: jest.Mock;
    let provider: BlockfrostChainHistoryProvider;
    let networkInfoProvider: NetworkInfoProvider;
    let cache: Cache<Cardano.HydratedTx>;

    const txId1 = Cardano.TransactionId('1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477');
    const txId2 = Cardano.TransactionId('2e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477');
    const txId3 = Cardano.TransactionId('3e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477');

    // Use real test addresses from CIP-19 test vectors
    const baseAddress1 = cip19TestVectors.basePaymentKeyStakeKey; // Base address with payment key + stake key
    const baseAddress2 = cip19TestVectors.basePaymentScriptStakeKey; // Base address with script + stake key
    const enterpriseAddress = cip19TestVectors.enterpriseKey; // Enterprise address (no stake)

    const mockedTx1Response = {
      asset_mint_or_burn_count: 0,
      block: '356b7d7dbb696ccd12775c016941057a9dc70898d87a63fc752271bb46856940',
      block_height: 100,
      delegation_count: 0,
      fees: '182485',
      hash: txId1,
      index: 1,
      invalid_before: null,
      invalid_hereafter: '13885913',
      mir_cert_count: 0,
      output_amount: [{ quantity: '42000000', unit: 'lovelace' }],
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

    const mockedTx2Response = { ...mockedTx1Response, block_height: 101, hash: txId2 };
    const mockedTx3Response = { ...mockedTx1Response, block_height: 102, hash: txId3 };

    const txsUtxosResponse = {
      hash: txId1,
      inputs: [
        {
          address: baseAddress1,
          amount: [{ quantity: '50000000', unit: 'lovelace' }],
          output_index: 0,
          tx_hash: '0000000000000000000000000000000000000000000000000000000000000000'
        }
      ],
      outputs: [
        {
          address: baseAddress1,
          amount: [{ quantity: '42000000', unit: 'lovelace' }]
        }
      ]
    };

    beforeEach(() => {
      request = jest.fn();
      const client = { request } as unknown as BlockfrostClient;
      networkInfoProvider = {
        eraSummaries: jest.fn().mockResolvedValue([
          {
            end: { slot: 100, time: new Date(1_506_203_092_000) },
            parameters: { epochLength: 100, safeZone: 0, slotLength: 1 },
            start: { slot: 0, time: new Date(1_506_203_091_000) }
          }
        ])
      } as unknown as NetworkInfoProvider;
      const cacheStorage = new Map();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      cache = {
        async get(key) {
          return cacheStorage.get(key);
        },
        async set(key, value) {
          cacheStorage.set(key, value);
        }
      };

      provider = new BlockfrostChainHistoryProvider(
        { queryTxsByCredentials: true },
        {
          cache,
          client,
          logger,
          networkInfoProvider
        }
      );
    });

    describe('transactionsByAddresses with credential-based queries', () => {
      test('single address is minimized to payment credential (1 API call)', async () => {
        const credentialTxs = [{ block_height: 100, block_time: 1_000_000, tx_hash: txId1, tx_index: 0 }];

        request.mockImplementation(
          createMockRequestHandler(
            { [txId1]: mockedTx1Response },
            txsUtxosResponse,
            createCredentialHandler(credentialTxs)
          )
        );

        await provider.transactionsByAddresses({
          addresses: [baseAddress1],
          pagination: { limit: 20, startAt: 0 }
        });

        // Verify we queried by payment credential, not by address
        const credentialCalls = request.mock.calls.filter((call: string[]) => call[0].includes(ADDR_VKH_PREFIX));
        expect(credentialCalls.length).toBeGreaterThan(0);

        // Should not query by address directly
        const addressCalls = request.mock.calls.filter((call: string[]) =>
          call[0].includes(`addresses/${baseAddress1}${TRANSACTIONS_PATH}`)
        );
        expect(addressCalls.length).toBe(0);
      });

      test('multiple addresses with shared stake key use reward account query', async () => {
        const rewardAccountTxs = [
          { block_height: 100, block_time: 1_000_000, tx_hash: txId1, tx_index: 0 },
          { block_height: 101, block_time: 1_000_020, tx_hash: txId2, tx_index: 0 }
        ];

        request.mockImplementation(
          createMockRequestHandler(
            { [txId1]: mockedTx1Response, [txId2]: mockedTx2Response },
            txsUtxosResponse,
            createAccountHandler(rewardAccountTxs)
          )
        );

        await provider.transactionsByAddresses({
          addresses: [baseAddress1, baseAddress2],
          pagination: { limit: 20, startAt: 0 }
        });

        // Should query by reward account (stake address)
        const rewardAccountCalls = request.mock.calls.filter(
          (call: string[]) => call[0].includes(ACCOUNTS_PATH) && call[0].includes(TRANSACTIONS_PATH)
        );
        expect(rewardAccountCalls.length).toBeGreaterThan(0);

        // Should not query by payment credentials
        const credentialCalls = request.mock.calls.filter((call: string[]) => call[0].includes(ADDR_VKH_PREFIX));
        expect(credentialCalls.length).toBe(0);
      });

      test('deduplicates transactions correctly', async () => {
        const credentialTxs = [
          { block_height: 100, block_time: 1_000_000, tx_hash: txId1, tx_index: 0 },
          { block_height: 101, block_time: 1_000_020, tx_hash: txId2, tx_index: 0 },
          { block_height: 102, block_time: 1_000_040, tx_hash: txId2, tx_index: 1 } // Duplicate txId2
        ];

        request.mockImplementation(
          createMockRequestHandler(
            { [txId1]: mockedTx1Response, [txId2]: mockedTx2Response },
            txsUtxosResponse,
            createCredentialHandler(credentialTxs)
          )
        );

        const result = await provider.transactionsByAddresses({
          addresses: [baseAddress1],
          pagination: { limit: 20, startAt: 0 }
        });

        // Should deduplicate to 2 unique transactions (txId1, txId2)
        expect(result.pageResults.length).toBe(2);
        expect(result.totalResultCount).toBe(2);
      });

      test('sorts transactions in descending order', async () => {
        const credentialTxs = [
          { block_height: 100, block_time: 1_000_000, tx_hash: txId1, tx_index: 0 },
          { block_height: 101, block_time: 1_000_020, tx_hash: txId2, tx_index: 0 },
          { block_height: 102, block_time: 1_000_040, tx_hash: txId3, tx_index: 0 }
        ];

        request.mockImplementation(
          createMockRequestHandler(
            { [txId1]: mockedTx1Response, [txId2]: mockedTx2Response, [txId3]: mockedTx3Response },
            txsUtxosResponse,
            createCredentialHandler(credentialTxs)
          )
        );

        const result = await provider.transactionsByAddresses({
          addresses: [baseAddress1],
          pagination: { limit: 20, order: 'desc', startAt: 0 }
        });

        // Should be sorted descending (newest first)
        expect(result.pageResults.length).toBe(3);
        expect(result.pageResults[0].id).toBe(txId3);
        expect(result.pageResults[1].id).toBe(txId2);
        expect(result.pageResults[2].id).toBe(txId1);

        // Verify block heights are actually in descending order
        expect(result.pageResults[0].blockHeader.blockNo).toBeGreaterThan(result.pageResults[1].blockHeader.blockNo);
        expect(result.pageResults[1].blockHeader.blockNo).toBeGreaterThan(result.pageResults[2].blockHeader.blockNo);
      });

      test('applies blockRange filters', async () => {
        const credentialTxs = [
          { block_height: 50, block_time: 500_000, tx_hash: txId1, tx_index: 0 },
          { block_height: 101, block_time: 1_000_000, tx_hash: txId2, tx_index: 0 },
          { block_height: 150, block_time: 1_500_000, tx_hash: txId3, tx_index: 0 }
        ];

        request.mockImplementation(
          createMockRequestHandler(
            { [txId1]: mockedTx1Response, [txId2]: mockedTx2Response, [txId3]: mockedTx3Response },
            txsUtxosResponse,
            createCredentialHandler(credentialTxs)
          )
        );

        const result = await provider.transactionsByAddresses({
          addresses: [baseAddress1],
          blockRange: { lowerBound: Cardano.BlockNo(75), upperBound: Cardano.BlockNo(125) },
          pagination: { limit: 20, startAt: 0 }
        });

        // Should only include txId2 (block_height: 101, within range 75-125)
        // txId1 (block_height: 50) and txId3 (block_height: 150) should be filtered out
        expect(result.pageResults.length).toBe(1);
        expect(result.pageResults[0].id).toBe(txId2);
        expect(result.pageResults[0].blockHeader.blockNo).toBe(Cardano.BlockNo(101));
      });

      test('handles enterprise addresses (no stake credential)', async () => {
        const credentialTxs = [{ block_height: 100, block_time: 1_000_000, tx_hash: txId1, tx_index: 0 }];

        request.mockImplementation(
          createMockRequestHandler(
            { [txId1]: mockedTx1Response },
            txsUtxosResponse,
            createCredentialHandler(credentialTxs)
          )
        );

        await provider.transactionsByAddresses({
          addresses: [enterpriseAddress],
          pagination: { limit: 20, startAt: 0 }
        });

        // Should query by payment credential (no stake account query)
        const credentialCalls = request.mock.calls.filter((call: string[]) => call[0].includes(ADDR_VKH_PREFIX));
        expect(credentialCalls.length).toBeGreaterThan(0);

        // Should not query by stake account
        const stakeCalls = request.mock.calls.filter(
          (call: string[]) => call[0].includes(ACCOUNTS_PATH) && call[0].includes(TRANSACTIONS_PATH)
        );
        expect(stakeCalls.length).toBe(0);
      });

      test('handles empty result sets', async () => {
        request.mockImplementation(createMockRequestHandler({}, txsUtxosResponse));

        const result = await provider.transactionsByAddresses({
          addresses: [baseAddress1],
          pagination: { limit: 20, startAt: 0 }
        });

        expect(result.pageResults.length).toBe(0);
        expect(result.totalResultCount).toBe(0);
      });

      test('respects pagination limit and avoids fetching all pages', async () => {
        // Create 300 transactions (3 pages with default page size of 100)
        const allTransactions = Array.from({ length: 300 }, (_, i) => ({
          block_height: 100 + i,
          block_time: 1_000_000 + i * 1000,
          tx_hash: `${i.toString().padStart(4, '0')}3f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477`,
          tx_index: 0
        }));

        // Create mock responses for all 300 transactions (to handle the bug where it fetches all)
        const txResponses: Record<string, unknown> = {};
        for (const transaction of allTransactions) {
          txResponses[transaction.tx_hash] = {
            ...mockedTx1Response,
            block_height: transaction.block_height,
            hash: transaction.tx_hash
          };
        }

        // Track pagination requests
        const paginationRequests: string[] = [];

        const handleCredentialRequest = (url: string) => {
          paginationRequests.push(url);

          // Parse page number from query string (page size is always 100)
          const pageMatch = url.match(/[&?]page=(\d+)/);
          const page = pageMatch ? Number.parseInt(pageMatch[1], 10) : 1;
          const pageSize = 100;

          // Return transactions for this page
          const startIdx = (page - 1) * pageSize;
          const endIdx = Math.min(startIdx + pageSize, allTransactions.length);
          return Promise.resolve(allTransactions.slice(startIdx, endIdx));
        };

        request.mockImplementation(
          createMockRequestHandler(txResponses, txsUtxosResponse, (url) => {
            if (url.includes(ADDR_VKH_PREFIX) && url.includes(TRANSACTIONS_PATH)) {
              return handleCredentialRequest(url);
            }
            return null;
          })
        );

        // Request 200 transactions out of 300 total (exactly 2 pages)
        const result = await provider.transactionsByAddresses({
          addresses: [baseAddress1],
          pagination: { limit: 200, startAt: 0 }
        });

        // Should return exactly 200 transactions
        expect(result.pageResults.length).toBe(200);

        // Should fetch exactly 2 pages to get 200 transactions (not all 3 pages)
        expect(paginationRequests.length).toBe(2);

        // Verify the pagination requests
        expect(paginationRequests[0]).toContain('page=1');
        expect(paginationRequests[1]).toContain('page=2');
      });
    });
  });
});
