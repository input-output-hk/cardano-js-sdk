import * as AssetId from '../../../util-dev/src/assetId';
import * as AssetIds from '../AssetId';
import * as Cardano from '../../src/Cardano';
import {
  Asset,
  AssetInfoWithAmount,
  Milliseconds,
  TokenTransferValue,
  createTxInspector,
  tokenTransferInspector
} from '../../src';
import { Ed25519KeyHashHex, Ed25519PublicKeyHex, Ed25519SignatureHex } from '@cardano-sdk/crypto';
import { createMockAssetProvider, createMockInputResolver } from './mocks';
import { jsonToMetadatum } from '../../src/util/metadatum';
import { logger } from '@cardano-sdk/util-dev';

const buildTokenTransferValue = (coins: bigint, assets: Array<[Asset.AssetInfo, bigint]>): TokenTransferValue => ({
  assets: new Map<Cardano.AssetId, AssetInfoWithAmount>(
    assets.map(([assetInfo, amount]) => [assetInfo.assetId, { amount, assetInfo }])
  ),
  coins
});

// eslint-disable-next-line max-statements
describe('txInspector', () => {
  const sendingAddress = Cardano.PaymentAddress(
    'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
  );
  const receivingAddress = Cardano.PaymentAddress(
    'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
  );
  const addresses = [
    Cardano.PaymentAddress(
      'addr1qx2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3n0d3vllmyqwsx5wktcd8cc3sq835lu7drv2xwl2wywfgse35a3x'
    ),
    Cardano.PaymentAddress(
      'addr1z8phkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gten0d3vllmyqwsx5wktcd8cc3sq835lu7drv2xwl2wywfgs9yc0hh'
    ),
    Cardano.PaymentAddress(
      'addr1yx2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzerkr0vd4msrxnuwnccdxlhdjar77j6lg0wypcc9uar5d2shs2z78ve'
    ),
    Cardano.PaymentAddress(
      'addr1x8phkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gt7r0vd4msrxnuwnccdxlhdjar77j6lg0wypcc9uar5d2shskhj42g'
    )
  ];

  const txMetadatum = new Map([
    [
      721n,
      jsonToMetadatum({
        b8fdbcbe003cef7e47eb5307d328e10191952bd02901a850699e7e35: {
          'NFT-001': {
            image: ['ipfs://some_hash1'],
            name: 'One',
            version: '1.0'
          }
        }
      })
    ]
  ]);

  const mockScript1 = {
    __type: Cardano.ScriptType.Native,
    kind: Cardano.NativeScriptKind.RequireAllOf,
    scripts: [
      {
        __type: Cardano.ScriptType.Native,
        keyHash: Ed25519KeyHashHex('24accb6ca2690388f067175d773871f5640de57bf11aec0be258d6c7'),
        kind: Cardano.NativeScriptKind.RequireSignature
      }
    ]
  };

  const mockScript2 = {
    __type: Cardano.ScriptType.Native,
    kind: Cardano.NativeScriptKind.RequireAllOf,
    scripts: [
      {
        __type: Cardano.ScriptType.Native,
        keyHash: Ed25519KeyHashHex('00accb6ca2690388f067175d773871f5640de57bf11aec0be258d6c7'),
        kind: Cardano.NativeScriptKind.RequireSignature
      }
    ]
  };

  const auxiliaryData = {
    blob: txMetadatum,
    scripts: [mockScript2]
  };

  const buildMockTx = (
    args: {
      inputs?: Cardano.HydratedTxIn[];
      outputs?: Cardano.TxOut[];
      certificates?: Cardano.Certificate[];
      withdrawals?: Cardano.Withdrawal[];
      mint?: Cardano.TokenMap;
      witness?: Cardano.Witness;
      includeAuxData?: boolean;
    } = {}
  ): Cardano.HydratedTx =>
    ({
      auxiliaryData: args.includeAuxData ? auxiliaryData : undefined,
      blockHeader: {
        blockNo: Cardano.BlockNo(200),
        hash: Cardano.BlockId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed'),
        slot: Cardano.Slot(1000)
      },
      body: {
        certificates: args.certificates,
        fee: 170_000n,
        inputs: args.inputs ?? [
          {
            address: sendingAddress,
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],
        mint:
          args.mint ??
          new Map([
            [Cardano.AssetId('b8fdbcbe003cef7e47eb5307d328e10191952bd02901a850699e7e3500000000000000'), 1n],
            [Cardano.AssetId('5ba141e401cfebf1929d539e48d14f4b20679c5409526814e0f17121ffffffffffffff'), 100_000n],
            [Cardano.AssetId('00000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaa'), -1n]
          ]),

        outputs: args.outputs ?? [
          {
            address: receivingAddress,
            value: { coins: 5_000_000n }
          },
          {
            address: receivingAddress,
            value: {
              assets: new Map([
                [AssetIds.PXL, 3n],
                [AssetIds.TSLA, 4n]
              ]),
              coins: 2_000_000n
            }
          },
          {
            address: receivingAddress,
            value: {
              assets: new Map([[AssetIds.PXL, 6n]]),
              coins: 2_000_000n
            }
          },
          {
            address: sendingAddress,
            value: {
              assets: new Map([[AssetIds.PXL, 1n]]),
              coins: 2_000_000n
            }
          }
        ],
        validityInterval: {},
        withdrawals: args.withdrawals
      },
      id: Cardano.TransactionId('e3a443363eb6ee3d67c5e75ec10b931603787581a948d68fa3b2cd3ff2e0d2ad'),
      index: 0,
      witness: args.witness ?? {
        scripts: [mockScript1],
        signatures: new Map<Ed25519PublicKeyHex, Ed25519SignatureHex>()
      }
    } as Cardano.HydratedTx);

  const assetInfos = [
    {
      assetId: AssetId.PXL,
      nftMetadata: { name: 'PXL' },
      supply: 11_242_452_000n,
      tokenMetadata: null
    } as Asset.AssetInfo,
    {
      assetId: AssetId.TSLA,
      nftMetadata: { name: 'TSLA' },
      supply: 1_000_000n,
      tokenMetadata: null
    } as Asset.AssetInfo,
    { assetId: AssetId.Unit, nftMetadata: { name: 'Unit' }, supply: 1n, tokenMetadata: null } as Asset.AssetInfo
  ];

  const oldAssetInfos = [
    {
      assetId: AssetId.PXL,
      nftMetadata: { name: 'PXL_old' },
      supply: 11_242_452_000n,
      tokenMetadata: null
    } as Asset.AssetInfo,
    {
      assetId: AssetId.TSLA,
      nftMetadata: { name: 'TSLA_old' },
      supply: 1_000_000n,
      tokenMetadata: null
    } as Asset.AssetInfo,
    { assetId: AssetId.Unit, nftMetadata: { name: 'Unit_old' }, supply: 1n, tokenMetadata: null } as Asset.AssetInfo
  ];

  const AssetInfoIdx = {
    PXL: 0,
    TSA: 1,
    Unit: 2
  };

  const assetProvider = createMockAssetProvider(assetInfos);

  const timeout = 6000 as Milliseconds;

  describe('Token Transfer Inspector', () => {
    it('does not include addresses which net difference is 0 (assets and coins)', async () => {
      // Arrange
      const tx = buildMockTx({
        inputs: [
          {
            address: addresses[0],
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: addresses[1],
            index: 1,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: addresses[2],
            index: 2,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],
        outputs: [
          {
            address: addresses[0],
            value: {
              assets: new Map([[AssetIds.TSLA, 1n]]),
              coins: 4_500_000n
            }
          },
          {
            address: addresses[0],
            value: {
              assets: new Map([[AssetIds.TSLA, 15n]]),
              coins: 5_000_000n
            }
          },
          {
            address: addresses[1],
            value: {
              assets: new Map([[AssetIds.TSLA, 25n]]),
              coins: 2_000_000n
            }
          }
        ]
      });

      const histTx: Cardano.HydratedTx[] = [
        {
          body: {
            outputs: [
              {
                address: addresses[0],
                value: {
                  assets: new Map([[AssetIds.TSLA, 16n]]),
                  coins: 9_500_000n
                }
              },
              {
                address: addresses[1],
                value: {
                  assets: new Map([[AssetIds.PXL, 15n]]),
                  coins: 5_000_000n
                }
              },
              {
                address: addresses[2],
                value: {
                  assets: new Map([[AssetIds.TSLA, 25n]]),
                  coins: 2_000_000n
                }
              }
            ]
          },
          id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        } as unknown as Cardano.HydratedTx
      ];

      const inspectTx = createTxInspector({
        tokenTransfer: tokenTransferInspector({
          fromAddressAssetProvider: assetProvider,
          inputResolver: createMockInputResolver(histTx),
          logger,
          timeout,
          toAddressAssetProvider: assetProvider
        })
      });

      // Act
      const { tokenTransfer } = await inspectTx(tx);

      // Assert
      expect(tokenTransfer.fromAddress).toEqual(
        new Map([
          [addresses[1], buildTokenTransferValue(-3_000_000n, [[assetInfos[AssetInfoIdx.PXL], -15n]])],
          [addresses[2], buildTokenTransferValue(-2_000_000n, [[assetInfos[AssetInfoIdx.TSA], -25n]])]
        ])
      );
      expect(tokenTransfer.toAddress).toEqual(
        new Map([[addresses[1], buildTokenTransferValue(0n, [[assetInfos[AssetInfoIdx.TSA], 25n]])]])
      );
    });

    it('adds assets with a positive net difference to the address in the toAddress list', async () => {
      // Arrange

      // This TX is not balanced, but it's not the point of this test
      const tx = buildMockTx({
        inputs: [
          {
            address: addresses[0],
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],
        outputs: [
          {
            address: addresses[0],
            value: {
              assets: new Map([[AssetIds.TSLA, 20n]]),
              coins: 10_500_000n
            }
          }
        ]
      });

      const histTx: Cardano.HydratedTx[] = [
        {
          body: {
            outputs: [
              {
                address: addresses[0],
                value: {
                  assets: new Map([[AssetIds.TSLA, 16n]]),
                  coins: 9_500_000n
                }
              }
            ]
          },
          id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        } as unknown as Cardano.HydratedTx
      ];

      const inspectTx = createTxInspector({
        tokenTransfer: tokenTransferInspector({
          fromAddressAssetProvider: assetProvider,
          inputResolver: createMockInputResolver(histTx),
          logger,
          timeout,
          toAddressAssetProvider: assetProvider
        })
      });

      // Act
      const { tokenTransfer } = await inspectTx(tx);

      // Assert
      expect(tokenTransfer.fromAddress).toEqual(new Map([]));
      expect(tokenTransfer.toAddress).toEqual(
        new Map([[addresses[0], buildTokenTransferValue(1_000_000n, [[assetInfos[AssetInfoIdx.TSA], 4n]])]])
      );
    });

    it('adds assets with a negative net difference to the address in the fromAddress list', async () => {
      // Arrange

      // This TX is not balanced, but it's not the point of this test
      const tx = buildMockTx({
        inputs: [
          {
            address: addresses[0],
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],
        outputs: [
          {
            address: addresses[0],
            value: {
              assets: new Map([[AssetIds.TSLA, 12n]]),
              coins: 8_500_000n
            }
          }
        ]
      });

      const histTx: Cardano.HydratedTx[] = [
        {
          body: {
            outputs: [
              {
                address: addresses[0],
                value: {
                  assets: new Map([[AssetIds.TSLA, 16n]]),
                  coins: 9_500_000n
                }
              }
            ]
          },
          id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        } as unknown as Cardano.HydratedTx
      ];

      const inspectTx = createTxInspector({
        tokenTransfer: tokenTransferInspector({
          fromAddressAssetProvider: assetProvider,
          inputResolver: createMockInputResolver(histTx),
          logger,
          timeout,
          toAddressAssetProvider: assetProvider
        })
      });

      // Act
      const { tokenTransfer } = await inspectTx(tx);

      // Assert
      expect(tokenTransfer.fromAddress).toEqual(
        new Map([[addresses[0], buildTokenTransferValue(-1_000_000n, [[assetInfos[AssetInfoIdx.TSA], -4n]])]])
      );
      expect(tokenTransfer.toAddress).toEqual(new Map([]));
    });

    it('coalesce all inputs from a each address', async () => {
      // Arrange

      // This TX is not balanced, but it's not the point of this test
      const tx = buildMockTx({
        inputs: [
          {
            address: addresses[0],
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: addresses[0],
            index: 1,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: addresses[0],
            index: 2,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],
        outputs: []
      });

      const histTx: Cardano.HydratedTx[] = [
        {
          body: {
            outputs: [
              {
                address: addresses[0],
                value: {
                  assets: new Map([[AssetIds.TSLA, 15n]]),
                  coins: 10_000_000n
                }
              },
              {
                address: addresses[0],
                value: {
                  assets: new Map([
                    [AssetIds.PXL, 25n],
                    [AssetIds.TSLA, 15n]
                  ]),
                  coins: 10_500_000n
                }
              },
              {
                address: addresses[0],
                value: {
                  assets: new Map([[AssetIds.Unit, 5n]]),
                  coins: 10_500_000n
                }
              }
            ]
          },
          id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        } as unknown as Cardano.HydratedTx
      ];

      const inspectTx = createTxInspector({
        tokenTransfer: tokenTransferInspector({
          fromAddressAssetProvider: assetProvider,
          inputResolver: createMockInputResolver(histTx),
          logger,
          timeout,
          toAddressAssetProvider: assetProvider
        })
      });

      // Act
      const { tokenTransfer } = await inspectTx(tx);

      // Assert
      expect(tokenTransfer.fromAddress).toEqual(
        new Map([
          [
            addresses[0],
            buildTokenTransferValue(-31_000_000n, [
              [assetInfos[AssetInfoIdx.TSA], -30n],
              [assetInfos[AssetInfoIdx.PXL], -25n],
              [assetInfos[AssetInfoIdx.Unit], -5n]
            ])
          ]
        ])
      );
      expect(tokenTransfer.toAddress).toEqual(new Map([]));
    });

    it('coalesce all outputs from a each address', async () => {
      // Arrange

      // This TX is not balanced, but it's not the point of this test
      const tx = buildMockTx({
        inputs: [],
        outputs: [
          {
            address: addresses[0],
            value: {
              assets: new Map([[AssetIds.TSLA, 15n]]),
              coins: 10_000_000n
            }
          },
          {
            address: addresses[0],
            value: {
              assets: new Map([
                [AssetIds.PXL, 25n],
                [AssetIds.TSLA, 15n]
              ]),
              coins: 10_500_000n
            }
          },
          {
            address: addresses[0],
            value: {
              assets: new Map([[AssetIds.Unit, 5n]]),
              coins: 10_500_000n
            }
          }
        ]
      });

      const histTx: Cardano.HydratedTx[] = [
        {
          body: { outputs: [] },
          id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        } as unknown as Cardano.HydratedTx
      ];

      const inspectTx = createTxInspector({
        tokenTransfer: tokenTransferInspector({
          fromAddressAssetProvider: assetProvider,
          inputResolver: createMockInputResolver(histTx),
          logger,
          timeout,
          toAddressAssetProvider: assetProvider
        })
      });

      // Act
      const { tokenTransfer } = await inspectTx(tx);

      // Assert
      expect(tokenTransfer.toAddress).toEqual(
        new Map([
          [
            addresses[0],
            buildTokenTransferValue(31_000_000n, [
              [assetInfos[AssetInfoIdx.TSA], 30n],
              [assetInfos[AssetInfoIdx.PXL], 25n],
              [assetInfos[AssetInfoIdx.Unit], 5n]
            ])
          ]
        ])
      );
      expect(tokenTransfer.fromAddress).toEqual(new Map([]));
    });

    it('distributes assets from a single address in toAddress and fromAddress depending on their net values', async () => {
      // Arrange

      // This TX is not balanced, but it's not the point of this test
      const tx = buildMockTx({
        inputs: [
          {
            address: addresses[0],
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: addresses[1],
            index: 1,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: addresses[2],
            index: 2,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: addresses[3],
            index: 3,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],

        outputs: [
          {
            address: addresses[0],
            value: {
              assets: new Map([[AssetIds.TSLA, 210n]]),
              coins: 4_500_000n
            }
          },
          {
            address: addresses[1],
            value: {
              assets: new Map([
                [AssetIds.TSLA, 15n],
                [AssetIds.PXL, 1n],
                [AssetIds.Unit, 12n]
              ]),
              coins: 5_000_000n
            }
          },
          {
            address: addresses[2],
            value: {
              assets: new Map([
                [AssetIds.TSLA, 5000n],
                [AssetIds.PXL, 1000n],
                [AssetIds.Unit, 12n]
              ]),
              coins: 10_000_000n
            }
          },
          {
            address: addresses[3],
            value: {
              assets: new Map([
                [AssetIds.PXL, 1000n],
                [AssetIds.Unit, 12n]
              ]),
              coins: 1_000_000n
            }
          }
        ]
      });

      const histTx: Cardano.HydratedTx[] = [
        {
          body: {
            outputs: [
              {
                address: addresses[0],
                value: {
                  assets: new Map([
                    [AssetIds.TSLA, 100n],
                    [AssetIds.PXL, 50n],
                    [AssetIds.Unit, 25n]
                  ]),
                  coins: 9_500_000n
                }
              },
              {
                address: addresses[1],
                value: {
                  assets: new Map([
                    [AssetIds.TSLA, 1n],
                    [AssetIds.PXL, 2n],
                    [AssetIds.Unit, 100n]
                  ]),
                  coins: 5_000_000n
                }
              },
              {
                address: addresses[2],
                value: {
                  assets: new Map([
                    [AssetIds.TSLA, 10_000n],
                    [AssetIds.PXL, 789n],
                    [AssetIds.Unit, 10n]
                  ]),
                  coins: 2_000_000n
                }
              },
              {
                address: addresses[3],
                value: {
                  assets: new Map([
                    [AssetIds.TSLA, 2n],
                    [AssetIds.PXL, 9n],
                    [AssetIds.Unit, 1120n]
                  ]),
                  coins: 2_000_000n
                }
              }
            ]
          },
          id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        } as unknown as Cardano.HydratedTx
      ];

      const inspectTx = createTxInspector({
        tokenTransfer: tokenTransferInspector({
          fromAddressAssetProvider: assetProvider,
          inputResolver: createMockInputResolver(histTx),
          logger,
          timeout,
          toAddressAssetProvider: assetProvider
        })
      });

      // Act
      const { tokenTransfer } = await inspectTx(tx);

      // Assert
      expect(tokenTransfer.toAddress).toEqual(
        new Map([
          [addresses[0], buildTokenTransferValue(0n, [[assetInfos[AssetInfoIdx.TSA], 110n]])],
          [addresses[1], buildTokenTransferValue(0n, [[assetInfos[AssetInfoIdx.TSA], 14n]])],
          [
            addresses[2],
            buildTokenTransferValue(8_000_000n, [
              [assetInfos[AssetInfoIdx.PXL], 211n],
              [assetInfos[AssetInfoIdx.Unit], 2n]
            ])
          ],
          [addresses[3], buildTokenTransferValue(0n, [[assetInfos[AssetInfoIdx.PXL], 991n]])]
        ])
      );

      expect(tokenTransfer.fromAddress).toEqual(
        new Map([
          [
            addresses[0],
            buildTokenTransferValue(-5_000_000n, [
              [assetInfos[AssetInfoIdx.PXL], -50n],
              [assetInfos[AssetInfoIdx.Unit], -25n]
            ])
          ],
          [
            addresses[1],
            buildTokenTransferValue(0n, [
              [assetInfos[AssetInfoIdx.PXL], -1n],
              [assetInfos[AssetInfoIdx.Unit], -88n]
            ])
          ],
          [addresses[2], buildTokenTransferValue(0n, [[assetInfos[AssetInfoIdx.TSA], -5000n]])],
          [
            addresses[3],
            buildTokenTransferValue(-1_000_000n, [
              [assetInfos[AssetInfoIdx.TSA], -2n],
              [assetInfos[AssetInfoIdx.Unit], -1108n]
            ])
          ]
        ])
      );
    });

    it('does not include assets which net values are 0', async () => {
      // Arrange

      // This TX is not balanced, but it's not the point of this test
      const tx = buildMockTx({
        inputs: [
          {
            address: addresses[0],
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: addresses[0],
            index: 1,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: addresses[0],
            index: 2,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],

        outputs: [
          {
            address: addresses[0],
            value: {
              assets: new Map([
                [AssetIds.TSLA, 100n],
                [AssetIds.PXL, 50n],
                [AssetIds.Unit, 30n]
              ]),
              coins: 3_000_000n
            }
          }
        ]
      });

      const histTx: Cardano.HydratedTx[] = [
        {
          body: {
            outputs: [
              {
                address: addresses[0],
                value: {
                  assets: new Map([
                    [AssetIds.TSLA, 25n],
                    [AssetIds.PXL, 10n],
                    [AssetIds.Unit, 5n]
                  ]),
                  coins: 1_000_000n
                }
              },
              {
                address: addresses[0],
                value: {
                  assets: new Map([
                    [AssetIds.TSLA, 25n],
                    [AssetIds.PXL, 10n],
                    [AssetIds.Unit, 10n]
                  ]),
                  coins: 1_000_000n
                }
              },
              {
                address: addresses[0],
                value: {
                  assets: new Map([
                    [AssetIds.TSLA, 50n],
                    [AssetIds.PXL, 30n],
                    [AssetIds.Unit, 10n]
                  ]),
                  coins: 1_000_000n
                }
              }
            ]
          },
          id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        } as unknown as Cardano.HydratedTx
      ];

      const inspectTx = createTxInspector({
        tokenTransfer: tokenTransferInspector({
          fromAddressAssetProvider: assetProvider,
          inputResolver: createMockInputResolver(histTx),
          logger,
          timeout,
          toAddressAssetProvider: assetProvider
        })
      });

      // Act
      const { tokenTransfer } = await inspectTx(tx);

      // Assert
      expect(tokenTransfer.toAddress).toEqual(
        new Map([[addresses[0], buildTokenTransferValue(0n, [[assetInfos[AssetInfoIdx.Unit], 5n]])]])
      );
      expect(tokenTransfer.fromAddress).toEqual(new Map([]));
    });

    it('uses different asset providers for the fromAddress and toAddress field', async () => {
      // Arrange

      // This TX is not balanced, but it's not the point of this test
      const tx = buildMockTx({
        inputs: [
          {
            address: addresses[0],
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: addresses[1],
            index: 1,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: addresses[2],
            index: 2,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: addresses[3],
            index: 3,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],

        outputs: [
          {
            address: addresses[0],
            value: {
              assets: new Map([[AssetIds.TSLA, 210n]]),
              coins: 4_500_000n
            }
          },
          {
            address: addresses[1],
            value: {
              assets: new Map([
                [AssetIds.TSLA, 15n],
                [AssetIds.PXL, 1n],
                [AssetIds.Unit, 12n]
              ]),
              coins: 5_000_000n
            }
          },
          {
            address: addresses[2],
            value: {
              assets: new Map([
                [AssetIds.TSLA, 5000n],
                [AssetIds.PXL, 1000n],
                [AssetIds.Unit, 12n]
              ]),
              coins: 10_000_000n
            }
          },
          {
            address: addresses[3],
            value: {
              assets: new Map([
                [AssetIds.PXL, 1000n],
                [AssetIds.Unit, 12n]
              ]),
              coins: 1_000_000n
            }
          }
        ]
      });

      const histTx: Cardano.HydratedTx[] = [
        {
          body: {
            outputs: [
              {
                address: addresses[0],
                value: {
                  assets: new Map([
                    [AssetIds.TSLA, 100n],
                    [AssetIds.PXL, 50n],
                    [AssetIds.Unit, 25n]
                  ]),
                  coins: 9_500_000n
                }
              },
              {
                address: addresses[1],
                value: {
                  assets: new Map([
                    [AssetIds.TSLA, 1n],
                    [AssetIds.PXL, 2n],
                    [AssetIds.Unit, 100n]
                  ]),
                  coins: 5_000_000n
                }
              },
              {
                address: addresses[2],
                value: {
                  assets: new Map([
                    [AssetIds.TSLA, 10_000n],
                    [AssetIds.PXL, 789n],
                    [AssetIds.Unit, 10n]
                  ]),
                  coins: 2_000_000n
                }
              },
              {
                address: addresses[3],
                value: {
                  assets: new Map([
                    [AssetIds.TSLA, 2n],
                    [AssetIds.PXL, 9n],
                    [AssetIds.Unit, 1120n]
                  ]),
                  coins: 2_000_000n
                }
              }
            ]
          },
          id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        } as unknown as Cardano.HydratedTx
      ];

      const inspectTx = createTxInspector({
        tokenTransfer: tokenTransferInspector({
          fromAddressAssetProvider: createMockAssetProvider(oldAssetInfos),
          inputResolver: createMockInputResolver(histTx),
          logger,
          timeout,
          toAddressAssetProvider: assetProvider
        })
      });

      // Act
      const { tokenTransfer } = await inspectTx(tx);

      // Assert
      expect(tokenTransfer.toAddress).toEqual(
        new Map([
          [addresses[0], buildTokenTransferValue(0n, [[assetInfos[AssetInfoIdx.TSA], 110n]])],
          [addresses[1], buildTokenTransferValue(0n, [[assetInfos[AssetInfoIdx.TSA], 14n]])],
          [
            addresses[2],
            buildTokenTransferValue(8_000_000n, [
              [assetInfos[AssetInfoIdx.PXL], 211n],
              [assetInfos[AssetInfoIdx.Unit], 2n]
            ])
          ],
          [addresses[3], buildTokenTransferValue(0n, [[assetInfos[AssetInfoIdx.PXL], 991n]])]
        ])
      );

      expect(tokenTransfer.fromAddress).toEqual(
        new Map([
          [
            addresses[0],
            buildTokenTransferValue(-5_000_000n, [
              [oldAssetInfos[AssetInfoIdx.PXL], -50n],
              [oldAssetInfos[AssetInfoIdx.Unit], -25n]
            ])
          ],
          [
            addresses[1],
            buildTokenTransferValue(0n, [
              [oldAssetInfos[AssetInfoIdx.PXL], -1n],
              [oldAssetInfos[AssetInfoIdx.Unit], -88n]
            ])
          ],
          [addresses[2], buildTokenTransferValue(0n, [[oldAssetInfos[AssetInfoIdx.TSA], -5000n]])],
          [
            addresses[3],
            buildTokenTransferValue(-1_000_000n, [
              [oldAssetInfos[AssetInfoIdx.TSA], -2n],
              [oldAssetInfos[AssetInfoIdx.Unit], -1108n]
            ])
          ]
        ])
      );
    });

    it('has no resolved fromAddresses on inputResolver timeout', async () => {
      const resolveDelay = Milliseconds(5);
      const timeoutAfter = Milliseconds(1);

      const tx = buildMockTx({
        inputs: [
          {
            address: addresses[0],
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: addresses[1],
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],
        outputs: [
          {
            address: addresses[0],
            value: {
              assets: new Map([
                [AssetIds.TSLA, 100n],
                [AssetIds.PXL, 50n],
                [AssetIds.Unit, 30n]
              ]),
              coins: 3_000_000n
            }
          }
        ]
      });

      const histTx: Cardano.HydratedTx[] = [
        {
          body: {
            outputs: [
              {
                address: addresses[0],
                value: {
                  assets: new Map([
                    [AssetIds.TSLA, 25n],
                    [AssetIds.PXL, 10n],
                    [AssetIds.Unit, 5n]
                  ]),
                  coins: 3_000_000n
                }
              }
            ]
          },
          id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        } as unknown as Cardano.HydratedTx
      ];

      const inspectTx = createTxInspector({
        tokenTransfer: tokenTransferInspector({
          fromAddressAssetProvider: assetProvider,
          inputResolver: createMockInputResolver(histTx, resolveDelay),
          logger,
          timeout: timeoutAfter,
          toAddressAssetProvider: assetProvider
        })
      });

      // Act
      const { tokenTransfer } = await inspectTx(tx);

      // Assert
      expect(tokenTransfer.fromAddress).toEqual(new Map([]));
    });

    it('should have fromAddress and toAddress without metadata on AssetProvider.getAssets error', async () => {
      const failingAssetProvider = {
        ...assetProvider,
        getAssets: () => Promise.reject('Failed to get assets')
      };

      const tx = buildMockTx({
        inputs: [
          {
            address: addresses[1],
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],
        outputs: [
          {
            address: addresses[0],
            value: {
              assets: new Map([
                [AssetIds.TSLA, 100n],
                [AssetIds.PXL, 50n],
                [AssetIds.Unit, 30n]
              ]),
              coins: 3_000_000n
            }
          }
        ]
      });

      const histTx: Cardano.HydratedTx[] = [
        {
          body: {
            outputs: [
              {
                address: addresses[1],
                value: {
                  assets: new Map([
                    [AssetIds.TSLA, 25n],
                    [AssetIds.PXL, 10n],
                    [AssetIds.Unit, 5n]
                  ]),
                  coins: 3_000_000n
                }
              }
            ]
          },
          id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        } as unknown as Cardano.HydratedTx
      ];

      const inspectTx = createTxInspector({
        tokenTransfer: tokenTransferInspector({
          fromAddressAssetProvider: failingAssetProvider,
          inputResolver: createMockInputResolver(histTx),
          logger,
          timeout,
          toAddressAssetProvider: failingAssetProvider
        })
      });

      // Act
      const { tokenTransfer } = await inspectTx(tx);

      // Assert
      expect(tokenTransfer.fromAddress).toMatchInlineSnapshot(`
        Map {
          "addr1z8phkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gten0d3vllmyqwsx5wktcd8cc3sq835lu7drv2xwl2wywfgs9yc0hh" => Object {
            "assets": Map {
              "659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41" => Object {
                "amount": -25n,
                "assetInfo": Object {
                  "assetId": "659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41",
                  "fingerprint": "asset1rqluyux4nxv6kjashz626c8usp8g88unmqwnyh",
                  "name": "54534c41",
                  "policyId": "659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82",
                  "quantity": 0n,
                  "supply": 0n,
                },
              },
              "1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c960150584c" => Object {
                "amount": -10n,
                "assetInfo": Object {
                  "assetId": "1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c960150584c",
                  "fingerprint": "asset1376eat26n9qnucrkkcy4pjps8d536nh5gds0gt",
                  "name": "50584c",
                  "policyId": "1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c9601",
                  "quantity": 0n,
                  "supply": 0n,
                },
              },
              "a5425bd7bc4182325188af2340415827a73f845846c165d9e14c5aed556e6974" => Object {
                "amount": -5n,
                "assetInfo": Object {
                  "assetId": "a5425bd7bc4182325188af2340415827a73f845846c165d9e14c5aed556e6974",
                  "fingerprint": "asset1947w6qxce5w35ur5q4s62z9fml2np9st3v20d9",
                  "name": "556e6974",
                  "policyId": "a5425bd7bc4182325188af2340415827a73f845846c165d9e14c5aed",
                  "quantity": 0n,
                  "supply": 0n,
                },
              },
            },
            "coins": -3000000n,
          },
        }
      `);
      expect(tokenTransfer.toAddress).toMatchInlineSnapshot(`
        Map {
          "addr1qx2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3n0d3vllmyqwsx5wktcd8cc3sq835lu7drv2xwl2wywfgse35a3x" => Object {
            "assets": Map {
              "659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41" => Object {
                "amount": 100n,
                "assetInfo": Object {
                  "assetId": "659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41",
                  "fingerprint": "asset1rqluyux4nxv6kjashz626c8usp8g88unmqwnyh",
                  "name": "54534c41",
                  "policyId": "659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82",
                  "quantity": 0n,
                  "supply": 0n,
                },
              },
              "1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c960150584c" => Object {
                "amount": 50n,
                "assetInfo": Object {
                  "assetId": "1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c960150584c",
                  "fingerprint": "asset1376eat26n9qnucrkkcy4pjps8d536nh5gds0gt",
                  "name": "50584c",
                  "policyId": "1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c9601",
                  "quantity": 0n,
                  "supply": 0n,
                },
              },
              "a5425bd7bc4182325188af2340415827a73f845846c165d9e14c5aed556e6974" => Object {
                "amount": 30n,
                "assetInfo": Object {
                  "assetId": "a5425bd7bc4182325188af2340415827a73f845846c165d9e14c5aed556e6974",
                  "fingerprint": "asset1947w6qxce5w35ur5q4s62z9fml2np9st3v20d9",
                  "name": "556e6974",
                  "policyId": "a5425bd7bc4182325188af2340415827a73f845846c165d9e14c5aed",
                  "quantity": 0n,
                  "supply": 0n,
                },
              },
            },
            "coins": 3000000n,
          },
        }
      `);
    });
  });
});
