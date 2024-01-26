import * as AssetIds from '../AssetId';
import * as Cardano from '../../src/Cardano';
import {
  CertificateType,
  CredentialType,
  RewardAccount,
  createStakeDeregistrationCert,
  createStakeRegistrationCert
} from '../../src/Cardano';
import { Ed25519KeyHashHex, Ed25519PublicKeyHex, Ed25519SignatureHex, Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { createTxInspector, transactionSummaryInspector } from '../../src';
import { jsonToMetadatum } from '../../src/util/metadatum';

const buildValue = (coins: bigint, assets: Array<[Cardano.AssetId, bigint]>): Cardano.Value => ({
  assets: new Map(assets),
  coins
});

const createMockInputResolver = (historicalTxs: Cardano.HydratedTx[]): Cardano.InputResolver => ({
  async resolveInput(input: Cardano.TxIn) {
    const tx = historicalTxs.find((historicalTx) => historicalTx.id === input.txId);

    if (!tx || tx.body.outputs.length <= input.index) return Promise.resolve(null);

    return Promise.resolve(tx.body.outputs[input.index]);
  }
});

// eslint-disable-next-line max-statements
const externalAddress1 = Cardano.PaymentAddress(
  'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
);
const externalAddress2 = Cardano.PaymentAddress(
  'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
);

const protocolParameters = {
  poolDeposit: 2_000_000,
  stakeKeyDeposit: 2_000_000
} as unknown as Cardano.ProtocolParameters;
const rewardAccounts = [
  Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27'),
  Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d')
];
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
    collaterals?: Cardano.HydratedTxIn[];
    totalCollateral?: Cardano.Lovelace;
    collateralReturn?: Cardano.TxOut;
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
      collateralReturn: args.collateralReturn ?? undefined,
      collaterals: args.collaterals ?? undefined,
      fee: 170_000n,
      inputs: args.inputs ?? [
        {
          address: addresses[0],
          index: 0,
          txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        }
      ],
      mint: args.mint ?? undefined,
      outputs: args.outputs ?? [
        {
          address: addresses[1],
          value: { coins: 5_000_000n }
        },
        {
          address: addresses[1],
          value: {
            assets: new Map([
              [AssetIds.PXL, 3n],
              [AssetIds.TSLA, 4n]
            ]),
            coins: 2_000_000n
          }
        },
        {
          address: addresses[1],
          value: {
            assets: new Map([[AssetIds.PXL, 6n]]),
            coins: 2_000_000n
          }
        },
        {
          address: addresses[0],
          value: {
            assets: new Map([[AssetIds.PXL, 1n]]),
            coins: 2_000_000n
          }
        }
      ],
      totalCollateral: args.totalCollateral ?? undefined,
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

describe('Transaction Summary Inspector', () => {
  it('computes the correct asset and coin difference', async () => {
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
      mint: new Map([
        [Cardano.AssetId('b8fdbcbe003cef7e47eb5307d328e10191952bd02901a850699e7e3500000000000000'), 1n],
        [Cardano.AssetId('5ba141e401cfebf1929d539e48d14f4b20679c5409526814e0f17121ffffffffffffff'), 100_000n],
        [Cardano.AssetId('00000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaa'), -1n]
      ]),
      outputs: [
        {
          address: externalAddress1,
          value: {
            assets: new Map([[AssetIds.TSLA, 5n]]),
            coins: 5_000_000n
          }
        },
        {
          address: externalAddress2,
          value: {
            assets: new Map([
              [AssetIds.PXL, 6n],
              [AssetIds.Unit, 7n]
            ]),
            coins: 5_000_000n
          }
        },
        {
          address: addresses[0],
          value: {
            assets: new Map([
              [AssetIds.TSLA, 5n],
              [AssetIds.PXL, 5n],
              [AssetIds.Unit, 5n],
              // added by mint
              [Cardano.AssetId('b8fdbcbe003cef7e47eb5307d328e10191952bd02901a850699e7e3500000000000000'), 1n],
              [Cardano.AssetId('5ba141e401cfebf1929d539e48d14f4b20679c5409526814e0f17121ffffffffffffff'), 100_000n]
            ]),
            coins: 6_000_000n
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
                  [AssetIds.TSLA, 10n],
                  // to be burned
                  [Cardano.AssetId('00000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaa'), 1n]
                ]),
                coins: 9_000_000n
              }
            },
            {
              address: addresses[1],
              value: {
                assets: new Map([[AssetIds.PXL, 11n]]),
                coins: 5_000_000n
              }
            },
            {
              address: addresses[2],
              value: {
                assets: new Map([[AssetIds.Unit, 12n]]),
                coins: 2_000_000n
              }
            }
          ]
        },
        id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
      } as unknown as Cardano.HydratedTx
    ];

    const inspectTx = createTxInspector({
      summary: transactionSummaryInspector({
        addresses,
        inputResolver: createMockInputResolver(histTx),
        protocolParameters,
        rewardAccounts
      })
    });

    // Act
    const { summary } = await inspectTx(tx);

    // Assert
    expect(summary).toEqual({
      assets: buildValue(0n, [
        [Cardano.AssetId('b8fdbcbe003cef7e47eb5307d328e10191952bd02901a850699e7e3500000000000000'), 1n],
        [Cardano.AssetId('00000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaa'), -1n],
        [Cardano.AssetId('5ba141e401cfebf1929d539e48d14f4b20679c5409526814e0f17121ffffffffffffff'), 100_000n],
        [AssetIds.TSLA, -5n],
        [AssetIds.PXL, -6n],
        [AssetIds.Unit, -7n]
      ]).assets,
      coins: -10_000_000n,
      collateral: 0n,
      deposit: 0n,
      fee: 170_000n,
      returnedDeposit: 0n,
      unresolved: {
        inputs: [],
        value: { assets: new Map(), coins: 0n }
      }
    });
  });

  it('computes legacy collateral', async () => {
    // Arrange
    const tx = buildMockTx({
      collaterals: [
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
            assets: new Map([[AssetIds.TSLA, 5n]]),
            coins: 5_000_000n
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
                assets: new Map([[AssetIds.TSLA, 5n]]),
                coins: 5_000_000n
              }
            },
            {
              address: addresses[1],
              value: {
                coins: 5_000_000n
              }
            },
            {
              address: addresses[2],
              value: {
                coins: 5_000_000n
              }
            }
          ]
        },
        id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
      } as unknown as Cardano.HydratedTx
    ];

    const inspectTx = createTxInspector({
      summary: transactionSummaryInspector({
        addresses,
        inputResolver: createMockInputResolver(histTx),
        protocolParameters,
        rewardAccounts
      })
    });

    // Act
    const { summary } = await inspectTx(tx);

    // Assert
    expect(summary).toEqual({
      assets: new Map(),
      coins: 0n,
      collateral: 10_000_000n,
      deposit: 0n,
      fee: 170_000n,
      returnedDeposit: 0n,
      unresolved: {
        inputs: [],
        value: { assets: new Map(), coins: 0n }
      }
    });
  });

  it('computes CIP-40 collateral', async () => {
    // Arrange
    const tx = buildMockTx({
      collateralReturn: { address: addresses[0], value: { coins: 7_000_000n } },
      collaterals: [
        {
          address: addresses[0],
          index: 0,
          txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        },
        {
          address: addresses[1],
          index: 1,
          txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        }
      ],
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
            assets: new Map([[AssetIds.TSLA, 5n]]),
            coins: 27_000_000n
          }
        }
      ],
      totalCollateral: 25_000_000n
    });

    const histTx: Cardano.HydratedTx[] = [
      {
        body: {
          outputs: [
            {
              address: addresses[0],
              value: {
                assets: new Map([[AssetIds.TSLA, 5n]]),
                coins: 27_000_000n
              }
            },
            {
              address: addresses[1],
              value: {
                coins: 5_000_000n
              }
            },
            {
              address: addresses[2],
              value: {
                coins: 5_000_000n
              }
            }
          ]
        },
        id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
      } as unknown as Cardano.HydratedTx
    ];

    const inspectTx = createTxInspector({
      summary: transactionSummaryInspector({
        addresses,
        inputResolver: createMockInputResolver(histTx),
        protocolParameters,
        rewardAccounts
      })
    });

    // Act
    const { summary } = await inspectTx(tx);

    // Assert
    expect(summary).toEqual({
      assets: new Map(),
      coins: 0n,
      collateral: 25_000_000n,
      deposit: 0n,
      fee: 170_000n,
      returnedDeposit: 0n,
      unresolved: {
        inputs: [],
        value: { assets: new Map(), coins: 0n }
      }
    });
  });

  it('only displays collateral coming from own addresses', async () => {
    // Arrange
    const tx = buildMockTx({
      collaterals: [
        {
          address: addresses[0],
          index: 0,
          txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        },
        {
          address: externalAddress1,
          index: 1,
          txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        }
      ],
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
            assets: new Map([[AssetIds.TSLA, 5n]]),
            coins: 5_000_000n
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
                assets: new Map([[AssetIds.TSLA, 5n]]),
                coins: 5_000_000n
              }
            },
            {
              address: externalAddress1,
              value: {
                coins: 15_000_000n
              }
            }
          ]
        },
        id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
      } as unknown as Cardano.HydratedTx
    ];

    const inspectTx = createTxInspector({
      summary: transactionSummaryInspector({
        addresses,
        inputResolver: createMockInputResolver(histTx),
        protocolParameters,
        rewardAccounts
      })
    });

    // Act
    const { summary } = await inspectTx(tx);

    // Assert
    expect(summary).toEqual({
      assets: new Map(),
      coins: 0n,
      collateral: 5_000_000n,
      deposit: 0n,
      fee: 170_000n,
      returnedDeposit: 0n,
      unresolved: {
        inputs: [],
        value: { assets: new Map(), coins: 0n }
      }
    });
  });

  it('computes deposits from shelley era certificates', async () => {
    // Arrange
    const tx = buildMockTx({
      certificates: [createStakeRegistrationCert(rewardAccounts[0])],
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
            assets: new Map([[AssetIds.TSLA, 5n]]),
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
                assets: new Map([[AssetIds.TSLA, 5n]]),
                coins: 5_000_000n
              }
            }
          ]
        },
        id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
      } as unknown as Cardano.HydratedTx
    ];

    const inspectTx = createTxInspector({
      summary: transactionSummaryInspector({
        addresses,
        inputResolver: createMockInputResolver(histTx),
        protocolParameters,
        rewardAccounts
      })
    });

    // Act
    const { summary } = await inspectTx(tx);

    // Assert
    expect(summary).toEqual({
      assets: new Map(),
      coins: -2_000_000n,
      collateral: 0n,
      deposit: 2_000_000n,
      fee: 170_000n,
      returnedDeposit: 0n,
      unresolved: {
        inputs: [],
        value: { assets: new Map(), coins: 0n }
      }
    });
  });

  it('computes return deposits from shelley era certificates', async () => {
    // Arrange
    const tx = buildMockTx({
      certificates: [createStakeDeregistrationCert(rewardAccounts[0])],
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
            assets: new Map([[AssetIds.TSLA, 5n]]),
            coins: 5_000_000n
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
                assets: new Map([[AssetIds.TSLA, 5n]]),
                coins: 3_000_000n
              }
            }
          ]
        },
        id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
      } as unknown as Cardano.HydratedTx
    ];

    const inspectTx = createTxInspector({
      summary: transactionSummaryInspector({
        addresses,
        inputResolver: createMockInputResolver(histTx),
        protocolParameters,
        rewardAccounts
      })
    });

    // Act
    const { summary } = await inspectTx(tx);

    // Assert
    expect(summary).toEqual({
      assets: new Map(),
      coins: 2_000_000n,
      collateral: 0n,
      deposit: 0n,
      fee: 170_000n,
      returnedDeposit: 2_000_000n,
      unresolved: {
        inputs: [],
        value: { assets: new Map(), coins: 0n }
      }
    });
  });

  it('computes deposits from conway era certificates', async () => {
    // Arrange
    const tx = buildMockTx({
      certificates: [
        {
          __typename: CertificateType.Registration,
          deposit: 15_000_000n,
          stakeCredential: {
            hash: Hash28ByteBase16.fromEd25519KeyHashHex(RewardAccount.toHash(rewardAccounts[0])),
            type: CredentialType.KeyHash
          }
        }
      ],
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
            assets: new Map([[AssetIds.TSLA, 5n]]),
            coins: 5_000_000n
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
                assets: new Map([[AssetIds.TSLA, 5n]]),
                coins: 20_000_000n
              }
            }
          ]
        },
        id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
      } as unknown as Cardano.HydratedTx
    ];

    const inspectTx = createTxInspector({
      summary: transactionSummaryInspector({
        addresses,
        inputResolver: createMockInputResolver(histTx),
        protocolParameters,
        rewardAccounts
      })
    });

    // Act
    const { summary } = await inspectTx(tx);

    // Assert
    expect(summary).toEqual({
      assets: new Map(),
      coins: -15_000_000n,
      collateral: 0n,
      deposit: 15_000_000n,
      fee: 170_000n,
      returnedDeposit: 0n,
      unresolved: {
        inputs: [],
        value: { assets: new Map(), coins: 0n }
      }
    });
  });

  it('computes returned deposits from conway era certificates', async () => {
    // Arrange
    const tx = buildMockTx({
      certificates: [
        {
          __typename: CertificateType.Unregistration,
          deposit: 15_000_000n,
          stakeCredential: {
            hash: Hash28ByteBase16.fromEd25519KeyHashHex(RewardAccount.toHash(rewardAccounts[0])),
            type: CredentialType.KeyHash
          }
        }
      ],
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
            assets: new Map([[AssetIds.TSLA, 5n]]),
            coins: 20_000_000n
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
                assets: new Map([[AssetIds.TSLA, 5n]]),
                coins: 5_000_000n
              }
            }
          ]
        },
        id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
      } as unknown as Cardano.HydratedTx
    ];

    const inspectTx = createTxInspector({
      summary: transactionSummaryInspector({
        addresses,
        inputResolver: createMockInputResolver(histTx),
        protocolParameters,
        rewardAccounts
      })
    });

    // Act
    const { summary } = await inspectTx(tx);

    // Assert
    expect(summary).toEqual({
      assets: new Map(),
      coins: 15_000_000n,
      collateral: 0n,
      deposit: 0n,
      fee: 170_000n,
      returnedDeposit: 15_000_000n,
      unresolved: {
        inputs: [],
        value: { assets: new Map(), coins: 0n }
      }
    });
  });

  it('computes unresolved inputs and value', async () => {
    // Arrange
    const tx = buildMockTx({
      inputs: [
        {
          address: addresses[0],
          index: 0,
          txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        },
        {
          address: externalAddress1,
          index: 1,
          txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        },
        {
          address: externalAddress2,
          index: 2,
          txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        }
      ],
      outputs: [
        {
          address: addresses[0],
          value: {
            assets: new Map([[AssetIds.TSLA, 5n]]),
            coins: 20_000_000n
          }
        },
        {
          address: addresses[0],
          value: {
            assets: new Map([
              [AssetIds.TSLA, 1n],
              [AssetIds.PXL, 1n],
              [AssetIds.Unit, 1n]
            ]),
            coins: 100_000_000n
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
                assets: new Map([[AssetIds.TSLA, 5n]]),
                coins: 20_000_000n
              }
            }
          ]
        },
        id: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
      } as unknown as Cardano.HydratedTx
    ];

    const inspectTx = createTxInspector({
      summary: transactionSummaryInspector({
        addresses,
        inputResolver: createMockInputResolver(histTx),
        protocolParameters,
        rewardAccounts
      })
    });

    // Act
    const { summary } = await inspectTx(tx);

    // Assert
    expect(summary).toEqual({
      assets: new Map([
        [AssetIds.TSLA, 1n],
        [AssetIds.PXL, 1n],
        [AssetIds.Unit, 1n]
      ]),
      coins: 100_000_000n,
      collateral: 0n,
      deposit: 0n,
      fee: 170_000n,
      returnedDeposit: 0n,
      unresolved: {
        inputs: [
          {
            address: externalAddress1,
            index: 1,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: externalAddress2,
            index: 2,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],
        value: {
          assets: new Map([
            [AssetIds.TSLA, 1n],
            [AssetIds.PXL, 1n],
            [AssetIds.Unit, 1n]
          ]),
          coins: 100_000_000n
        }
      }
    });
  });
});
