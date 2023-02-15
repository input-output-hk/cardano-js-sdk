import * as Crypto from '@cardano-sdk/crypto';
import { Base64Blob, HexBlob } from '@cardano-sdk/util';
import { Cardano } from '@cardano-sdk/core';
import { generateRandomHexString } from '@cardano-sdk/util-dev';
export const rewardAccount = Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr');
export const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount);
export const poolId = Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34');
export const vrf = Cardano.VrfVkHex('8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0');
export const metadataJson = {
  hash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
  url: 'https://example.com'
};

export const script: Cardano.NativeScript = {
  __type: Cardano.ScriptType.Native,
  kind: Cardano.NativeScriptKind.RequireAnyOf,
  scripts: [
    {
      __type: Cardano.ScriptType.Native,
      keyHash: Crypto.Ed25519KeyHashHex('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538'),
      kind: Cardano.NativeScriptKind.RequireSignature
    },
    {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAllOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          kind: Cardano.NativeScriptKind.RequireTimeBefore,
          slot: Cardano.Slot(3000)
        },
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Crypto.Ed25519KeyHashHex('966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37'),
          kind: Cardano.NativeScriptKind.RequireSignature
        },
        {
          __type: Cardano.ScriptType.Native,
          kind: Cardano.NativeScriptKind.RequireTimeAfter,
          slot: Cardano.Slot(4000)
        }
      ]
    }
  ]
};

export const mintTokenMap = new Map([
  [Cardano.AssetId('2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740'), 20n],
  [Cardano.AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41'), -50n],
  [Cardano.AssetId('7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373'), 40n],
  [Cardano.AssetId('7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373504154415445'), 30n]
]);

export const valueWithAssets = {
  assets: new Map([
    [Cardano.AssetId('2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740'), 20n],
    [Cardano.AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41'), 50n],
    [Cardano.AssetId('7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373'), 40n],
    [Cardano.AssetId('7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373504154415445'), 30n]
  ]),
  coins: 10n
};

export const txIn = {
  index: 0,
  txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
};

export const txOut: Cardano.TxOut = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  value: valueWithAssets
};

export const txBody: Cardano.TxBody = {
  certificates: [
    {
      __typename: Cardano.CertificateType.PoolRetirement,
      epoch: Cardano.EpochNo(500),
      poolId: Cardano.PoolId('pool1y6chk7x7fup4ms9leesdr57r4qy9cwxuee0msan72x976a6u0nc')
    },
    {
      __typename: Cardano.CertificateType.GenesisKeyDelegation,
      genesisDelegateHash: Crypto.Hash28ByteBase16('a646474b8f5431261506b6c273d307c7569a4eb6c96b42dd4a29520a'),
      genesisHash: Crypto.Hash28ByteBase16('0d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4'),
      vrfKeyHash: Crypto.Hash32ByteBase16('03170a2e7597b7b7e3d84c05391d139a62b157e78786d8c082f29dcf4c111314')
    }
  ],
  collaterals: [{ ...txIn, index: txIn.index + 1 }],
  fee: 10n,
  inputs: [txIn],
  mint: mintTokenMap,
  outputs: [txOut],
  requiredExtraSignatures: [Crypto.Ed25519KeyHashHex('6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d39')],
  scriptIntegrityHash: Crypto.Hash32ByteBase16('6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d38abc123de'),
  validityInterval: {
    invalidBefore: Cardano.Slot(100),
    invalidHereafter: Cardano.Slot(1000)
  },
  withdrawals: [
    {
      quantity: 5n,
      stakeAddress: Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
    }
  ]
};

export const simpleTxBody: Cardano.TxBody = {
  fee: 10n,
  inputs: [txIn],
  outputs: [txOut],
  validityInterval: {
    invalidBefore: Cardano.Slot(100),
    invalidHereafter: Cardano.Slot(1000)
  }
};

export const babbageTxBody: Cardano.TxBody = {
  ...txBody,
  collateralReturn: txOut,
  referenceInputs: [txIn],
  totalCollateral: 100n
};

export const vkey = '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39';
export const signature =
  // eslint-disable-next-line max-len
  'bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c8918755bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c8918755';
export const tx: Cardano.Tx = {
  auxiliaryData: {
    body: {
      blob: new Map<bigint, Cardano.Metadatum>([
        [1n, 1234n],
        [2n, 'str'],
        [3n, [1234n, 'str']],
        [4n, new Uint8Array(Buffer.from('bytes'))],
        [
          5n,
          new Map<Cardano.Metadatum, Cardano.Metadatum>([
            ['strkey', 123n],
            [['listkey'], 'strvalue']
          ])
        ],
        [6n, -7n]
      ])
    }
  },
  body: txBody,
  id: Cardano.TransactionId('8d2feeab1087e0aa4ad06e878c5269eaa2edcef5264bcc97542a28c189b2cbc5'),
  witness: {
    // bootstrap values from ogmios.wsp.json
    bootstrap: [
      {
        addressAttributes: Base64Blob('oA=='),
        chainCode: HexBlob('b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'),
        key: Crypto.Ed25519PublicKeyHex('deeb8f82f2af5836ebbc1b450b6dbf0b03c93afe5696f10d49e8a8304ebfac01'),
        signature: Crypto.Ed25519SignatureHex(
          Buffer.from(
            'ZGdic3hnZ3RvZ2hkanB0ZXR2dGtjb2N2eWZpZHFxZ2d1cmpocmhxYWlpc3BxcnVlbGh2eXBxeGVld3ByeWZ2dw==',
            'base64'
          ).toString('hex')
        )
      }
    ],
    datums: [HexBlob('187b')],
    redeemers: [
      {
        data: HexBlob('d86682008101'),
        executionUnits: {
          memory: 3000,
          steps: 7000
        },
        index: 0,
        purpose: Cardano.RedeemerPurpose.mint
      },
      {
        data: HexBlob('d86682008102'),
        executionUnits: {
          memory: 5000,
          steps: 2000
        },
        index: 1,
        purpose: Cardano.RedeemerPurpose.certificate
      }
    ],
    scripts: [
      {
        __type: Cardano.ScriptType.Plutus,
        bytes: HexBlob('b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'),
        version: Cardano.PlutusLanguageVersion.V1
      },
      {
        __type: Cardano.ScriptType.Plutus,
        bytes: HexBlob('b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'),
        version: Cardano.PlutusLanguageVersion.V2
      },
      {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireTimeBefore,
        slot: Cardano.Slot(100)
      },
      {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireTimeAfter,
        slot: Cardano.Slot(500)
      },
      {
        __type: Cardano.ScriptType.Native,
        keyHash: Crypto.Ed25519KeyHashHex('b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54'),
        kind: Cardano.NativeScriptKind.RequireSignature
      },
      {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireAllOf,
        scripts: [
          {
            __type: Cardano.ScriptType.Native,
            keyHash: Crypto.Ed25519KeyHashHex('b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54'),
            kind: Cardano.NativeScriptKind.RequireSignature
          }
        ]
      },
      {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireAnyOf,
        scripts: [
          {
            __type: Cardano.ScriptType.Native,
            keyHash: Crypto.Ed25519KeyHashHex('b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54'),
            kind: Cardano.NativeScriptKind.RequireSignature
          }
        ]
      },
      {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireNOf,
        required: 1,
        scripts: [
          {
            __type: Cardano.ScriptType.Native,
            keyHash: Crypto.Ed25519KeyHashHex('b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54'),
            kind: Cardano.NativeScriptKind.RequireSignature
          }
        ]
      }
    ],
    signatures: new Map([[Crypto.Ed25519PublicKeyHex(vkey), Crypto.Ed25519SignatureHex(signature)]])
  }
};

export const babbageTxWithoutScript: Cardano.Tx = {
  body: simpleTxBody,
  id: Cardano.TransactionId('8d2feeab1087e0aa4ad06e878c5269eaa2edcef5264bcc97542a28c189b2cbc5'),
  witness: {
    bootstrap: [
      {
        addressAttributes: Base64Blob('oA=='),
        chainCode: HexBlob('b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'),
        key: Crypto.Ed25519PublicKeyHex('deeb8f82f2af5836ebbc1b450b6dbf0b03c93afe5696f10d49e8a8304ebfac01'),
        signature: Crypto.Ed25519SignatureHex(
          Buffer.from(
            'ZGdic3hnZ3RvZ2hkanB0ZXR2dGtjb2N2eWZpZHFxZ2d1cmpocmhxYWlpc3BxcnVlbGh2eXBxeGVld3ByeWZ2dw==',
            'base64'
          ).toString('hex')
        )
      }
    ],
    signatures: new Map([[Crypto.Ed25519PublicKeyHex(vkey), Crypto.Ed25519SignatureHex(signature)]])
  }
};

export const babbageTx: Cardano.Tx = {
  ...tx,
  body: babbageTxBody,
  id: Cardano.TransactionId('856c8bc6ce3725188b496d62fa389f2beff2f701e6d35af39d3f3464bbce0cec')
};

export const getBigBabbageTx = async () => {
  const bigTx = {
    ...tx,
    body: {
      ...txBody,
      collateralReturn: txOut,
      referenceInputs: [txIn],
      totalCollateral: 100n
    },
    id: Cardano.TransactionId('856c8bc6ce3725188b496d62fa389f2beff2f701e6d35af39d3f3464bbce0cec')
  };

  for (let i = 0; i < 10_000; ++i)
    bigTx.body.referenceInputs!.push({
      index: 0,
      txId: Cardano.TransactionId(generateRandomHexString(64))
    });

  return bigTx;
};

export const noMultiasset = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  value: {
    coins: 0n
  }
};

export const noMultiassetMinAda = 969_750n;

export const onePolicyOne0CharAsset = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  value: {
    assets: new Map([[Cardano.AssetId('8b8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56'), 1n]]),
    coins: 0n
  }
};

export const onePolicyOne0CharAssetMinAda = 1_120_600n;

export const onePolicyOne1CharAsset = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  value: {
    assets: new Map([[Cardano.AssetId('8b8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb5600'), 1n]]),
    coins: 0n
  }
};

export const onePolicyOne1CharAssetMinAda = 1_124_910n;

export const onePolicyThree1CharAsset = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  value: {
    assets: new Map([
      [Cardano.AssetId('8b8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb5600'), 1n],
      [Cardano.AssetId('8b8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb5601'), 1n],
      [Cardano.AssetId('8b8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb5602'), 1n]
    ]),
    coins: 1_555_554n
  }
};

export const onePolicyThree1CharAssetMinAda = 1_150_770n;

export const twoPoliciesOne0CharAsset = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  value: {
    assets: new Map([
      [Cardano.AssetId('ab8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56'), 1n],
      [Cardano.AssetId('bb8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56'), 1n]
    ]),
    coins: 0n
  }
};

export const twoPoliciesOne0CharAssetMinAda = 1_262_830n;

export const twoPoliciesOne1CharAsset = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  value: {
    assets: new Map([
      [Cardano.AssetId('ab8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb5600'), 1n],
      [Cardano.AssetId('bb8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56FF'), 1n]
    ]),
    coins: 0n
  }
};

export const twoPoliciesOne1CharAssetMinAda = 1_271_450n;

export const onePolicyOne0CharAssetDatumHash = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  datumHash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
  value: {
    assets: new Map([[Cardano.AssetId('ab8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56'), 1n]]),
    coins: 0n
  }
};

export const onePolicyOne0CharAssetDatumHashMinAda = 1_267_140n;

export const threePolicyThree32CharAssetDatumHash = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  datumHash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
  value: {
    assets: new Map([
      [
        Cardano.AssetId(
          // eslint-disable-next-line max-len
          'ab8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'
        ),
        1n
      ],
      [
        Cardano.AssetId(
          // eslint-disable-next-line max-len
          'ab8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'
        ),
        1n
      ],
      [
        Cardano.AssetId(
          // eslint-disable-next-line max-len
          'ab8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'
        ),
        1n
      ]
    ]),
    coins: 1_555_554n
  }
};

export const threePolicyThree32CharAssetDatumHashMinAda = 1_409_370n;

export const twoPolicyOne0CharAssetDatumHash = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  datumHash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
  value: {
    assets: new Map([
      [Cardano.AssetId('ab8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56'), 1n],
      [Cardano.AssetId('bb8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56'), 1n]
    ]),
    coins: 0n
  }
};

export const twoPolicyOne0CharAssetDatumHashMinAda = 1_409_370n;

export const twoPolicyOne0CharAssetDatum = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  datum: HexBlob('187b'),
  value: {
    assets: new Map([
      [Cardano.AssetId('ab8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56'), 1n],
      [Cardano.AssetId('bb8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56'), 1n]
    ]),
    coins: 0n
  }
};

export const twoPolicyOne0CharAssetDatumMinAda = 1_305_930n;

export const twoPolicyOne0CharAssetDatumAndScriptReference = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  datum: HexBlob('187b'),
  scriptReference: script,
  value: {
    assets: new Map([
      [Cardano.AssetId('ab8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56'), 1n],
      [Cardano.AssetId('bb8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56'), 1n]
    ]),
    coins: 0n
  }
};

export const twoPolicyOne0CharAssetDatumAndScriptReferenceMinAda = 1_680_900n;
