import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { BlockfrostChainHistoryProvider } from '../../../src';
import { Cardano } from '@cardano-sdk/core';
import { dummyLogger as logger } from 'ts-log';

jest.mock('@blockfrost/blockfrost-js');

describe('blockfrostChainHistoryProvider', () => {
  const apiKey = 'someapikey';

  describe('transactionsBy*', () => {
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
    const mockedTxResponse = {
      asset_mint_or_burn_count: 5,
      block: '356b7d7dbb696ccd12775c016941057a9dc70898d87a63fc752271bb46856940',
      block_height: 123_456,
      delegation_count: 0,
      fees: '182485',
      hash: '1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477',
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
    const mockedAddressTransactionResponse = [
      {
        block_height: 123,
        block_time: 131_322,
        tx_hash: '1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477',
        tx_index: 0
      }
    ];
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
            cert_index: 0,
            epoch: 216,
            poolId: 'pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy'
          } as unknown as Cardano.HydratedCertificate,
          {
            __typename: 'PoolRegistrationCertificate',
            cert_index: 0,
            poolId: 'pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy',
            poolParameters: null
          },
          {
            __typename: 'MirCertificate',
            cert_index: 0,
            kind: 'ToStakeCreds',
            pot: 'reserve',
            quantity: 431_833_601n,
            rewardAccount: 'stake1u9r76ypf5fskppa0cmttas05cgcswrttn6jrq4yd7jpdnvc7gt0yc'
          },
          {
            __typename: 'StakeRegistrationCertificate',
            cert_index: 0,
            stakeCredential: {
              hash: '571ebd7877279a18734c91507b0164be8317f863f1c0269bba64e1b3',
              type: 0
            }
          }
        ],
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
              assets: new Map(),
              coins: 9_731_978_536_963n
            }
          }
        ],
        validityInterval: {
          invalidBefore: undefined,
          invalidHereafter: Cardano.Slot(13_885_913)
        },
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
              new Uint8Array([
                101, 99, 50, 54, 98, 56, 57, 97, 102, 52, 49, 98, 101, 102, 48, 102, 55, 53, 56, 53, 51, 53, 51, 56, 51,
                49, 99, 98, 53, 100, 97, 52, 50, 98, 53, 98, 51, 55, 49, 56, 53, 101, 48, 99, 56, 97, 53, 50, 54, 49,
                52, 51, 98, 56, 50, 52
              ])
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
    let blockfrost: BlockFrostAPI;

    beforeEach(() => {
      BlockFrostAPI.prototype.txsUtxos = jest.fn().mockResolvedValue(txsUtxosResponse);
      BlockFrostAPI.prototype.txs = jest.fn().mockResolvedValue(mockedTxResponse);
      BlockFrostAPI.prototype.txsMetadata = jest.fn().mockResolvedValue(mockedMetadataResponse);
      BlockFrostAPI.prototype.txsMirs = jest.fn().mockResolvedValue(mockedMirResponse);
      BlockFrostAPI.prototype.txsPoolUpdates = jest.fn().mockResolvedValue(mockedPoolUpdateResponse);
      BlockFrostAPI.prototype.txsPoolRetires = jest.fn().mockResolvedValue(mockedPoolRetireResponse);
      BlockFrostAPI.prototype.txsStakes = jest.fn().mockResolvedValue(mockedStakeResponse);
      BlockFrostAPI.prototype.txsDelegations = jest.fn().mockResolvedValue(mockedDelegationResponse);
      BlockFrostAPI.prototype.txsWithdrawals = jest.fn().mockResolvedValue(mockedWithdrawalResponse);
      BlockFrostAPI.prototype.txsRedeemers = jest.fn().mockResolvedValue(mockedReedemerResponse);
      BlockFrostAPI.prototype.addressesTransactions = jest.fn().mockResolvedValue(mockedAddressTransactionResponse);

      blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
    });
    describe('transactionsByAddresses', () => {
      test('converts responses correctly', async () => {
        const provider = new BlockfrostChainHistoryProvider({ blockfrost, logger });
        const response = await provider.transactionsByAddresses({
          addresses: [Cardano.PaymentAddress('2cWKMJemoBai9J7kVvRTukMmdfxtjL9z7c396rTfrrzfAZ6EeQoKLC2y1k34hswwm4SVr')],
          pagination: { limit: 20, startAt: 0 }
        });

        expect(response.totalResultCount).toBe(1);
        expect(response.pageResults[0]).toEqual(expectedHydratedTx);
      });
    });

    describe('transactionsByHashes', () => {
      test('converts responses correctly', async () => {
        const provider = new BlockfrostChainHistoryProvider({ blockfrost, logger });
        const response = await provider.transactionsByHashes({
          ids: ['1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477'].map(Cardano.TransactionId)
        });

        expect(response).toHaveLength(1);
        expect(response[0]).toEqual(expectedHydratedTx);
      });
    });
  });

  describe('transactionsBy* throws', () => {
    let blockfrost: BlockFrostAPI;
    const mockedError = {
      error: 'Forbidden',
      message: 'Invalid project token.',
      status_code: 403,
      url: 'test'
    };

    const mockedErrorMethod = jest.fn().mockRejectedValue(mockedError);
    beforeAll(() => {
      BlockFrostAPI.prototype.txsUtxos = mockedErrorMethod;
      BlockFrostAPI.prototype.txs = mockedErrorMethod;
      BlockFrostAPI.prototype.txsMetadata = mockedErrorMethod;
      BlockFrostAPI.prototype.txsMirs = mockedErrorMethod;
      BlockFrostAPI.prototype.txsPoolUpdates = mockedErrorMethod;
      BlockFrostAPI.prototype.txsPoolRetires = mockedErrorMethod;
      BlockFrostAPI.prototype.txsStakes = mockedErrorMethod;
      BlockFrostAPI.prototype.txsDelegations = mockedErrorMethod;
      BlockFrostAPI.prototype.txsWithdrawals = mockedErrorMethod;
      BlockFrostAPI.prototype.txsRedeemers = mockedErrorMethod;
      BlockFrostAPI.prototype.addressesTransactions = mockedErrorMethod;

      blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
    });
    beforeEach(() => {
      mockedErrorMethod.mockClear();
    });
    describe('transactionsByAddresses', () => {
      test('throws', async () => {
        const provider = new BlockfrostChainHistoryProvider({ blockfrost, logger });

        await expect(() =>
          provider.transactionsByAddresses({
            addresses: [
              Cardano.PaymentAddress('2cWKMJemoBai9J7kVvRTukMmdfxtjL9z7c396rTfrrzfAZ6EeQoKLC2y1k34hswwm4SVr')
            ],
            pagination: { limit: 20, startAt: 0 }
          })
        ).rejects.toThrow();

        expect(mockedErrorMethod).toBeCalledTimes(1);
      });
    });

    describe('transactionsByHashes', () => {
      test('throws', async () => {
        const provider = new BlockfrostChainHistoryProvider({ blockfrost, logger });

        await expect(() =>
          provider.transactionsByHashes({
            ids: ['1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477'].map(Cardano.TransactionId)
          })
        ).rejects.toThrow();
        expect(mockedErrorMethod).toBeCalledTimes(1);
      });
    });
  });
  describe('blocksByHashes', () => {
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
    test('blocksByHashes', async () => {
      BlockFrostAPI.prototype.blocks = jest.fn().mockResolvedValue(blockResponse);

      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = new BlockfrostChainHistoryProvider({ blockfrost, logger });
      const response = await provider.blocksByHashes({
        ids: [Cardano.BlockId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed')]
      });

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
        } as Cardano.ExtendedBlockInfo
      ]);
    });

    test('blocksByHashes, genesis delegate slot leader', async () => {
      const slotLeader = 'ShelleyGenesis-eff1b5b26e65b791';
      BlockFrostAPI.prototype.blocks = jest.fn().mockResolvedValue({ ...blockResponse, slot_leader: slotLeader });

      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = new BlockfrostChainHistoryProvider({ blockfrost, logger });
      const response = await provider.blocksByHashes({
        ids: [Cardano.BlockId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed')]
      });

      expect(response[0].slotLeader).toBe(slotLeader);
    });
    test('throws', async () => {
      const mockedError = {
        error: 'Forbidden',
        message: 'Invalid project token.',
        status_code: 403,
        url: 'test'
      };
      const mockedErrorMethod = jest.fn().mockRejectedValue(mockedError);

      BlockFrostAPI.prototype.blocks = mockedErrorMethod;

      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = new BlockfrostChainHistoryProvider({ blockfrost, logger });

      await expect(() =>
        provider.blocksByHashes({
          ids: [Cardano.BlockId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed')]
        })
      ).rejects.toThrow();
      expect(mockedErrorMethod).toBeCalledTimes(1);
    });
  });
});
