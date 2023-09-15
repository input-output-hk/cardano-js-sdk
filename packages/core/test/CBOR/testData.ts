import * as Crypto from '@cardano-sdk/crypto';
import { Base64Blob, HexBlob } from '@cardano-sdk/util';
import { Cardano } from '../../src';
import { NativeScript, NativeScriptKind, PlutusLanguageVersion, RedeemerPurpose, ScriptType } from '../../src/Cardano';
export const rewardAccount = Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr');
export const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount);
export const poolId = Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34');
export const ownerRewardAccount = Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr');
export const vrf = Cardano.VrfVkHex('8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0');
export const metadataJson = {
  hash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
  url: 'https://example.com'
};
export const poolParameters: Cardano.PoolParameters = {
  cost: 1000n,
  id: poolId,
  margin: { denominator: 5, numerator: 1 },
  metadataJson,
  owners: [ownerRewardAccount],
  pledge: 10_000n,
  relays: [
    { __typename: 'RelayByName', hostname: 'example.com', port: 5000 },
    {
      __typename: 'RelayByAddress',
      ipv4: '127.0.0.1',
      port: 6000
    },
    { __typename: 'RelayByNameMultihost', dnsName: 'example.com' }
  ],
  rewardAccount,
  vrf
};

export const script: NativeScript = {
  __type: ScriptType.Native,
  kind: NativeScriptKind.RequireAnyOf,
  scripts: [
    {
      __type: ScriptType.Native,
      keyHash: Crypto.Ed25519KeyHashHex('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538'),
      kind: NativeScriptKind.RequireSignature
    },
    {
      __type: ScriptType.Native,
      kind: NativeScriptKind.RequireAllOf,
      scripts: [
        {
          __type: ScriptType.Native,
          kind: NativeScriptKind.RequireTimeBefore,
          slot: Cardano.Slot(3000)
        },
        {
          __type: ScriptType.Native,
          keyHash: Crypto.Ed25519KeyHashHex('966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37'),
          kind: NativeScriptKind.RequireSignature
        },
        {
          __type: ScriptType.Native,
          kind: NativeScriptKind.RequireTimeAfter,
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

export const valueCoinOnly = { coins: 100_000n };
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

export const txInWithAddress: Cardano.HydratedTxIn = {
  address: Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  ...txIn
};

export const txOut: Cardano.TxOut = {
  address: Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  value: valueWithAssets
};

export const invalidBabbageTxOut: Cardano.TxOut = {
  address: Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  datum: 123n,
  datumHash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
  scriptReference: script,
  value: valueWithAssets
};

export const babbageTxOutWithDatumHash: Cardano.TxOut = {
  address: Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  datumHash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
  scriptReference: script,
  value: valueWithAssets
};

export const babbageTxOutWithInlineDatum: Cardano.TxOut = {
  address: Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  datum: 123n,
  scriptReference: script,
  value: valueWithAssets
};

export const txOutWithByron: Cardano.TxOut = {
  address: Cardano.PaymentAddress('5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg'),
  value: valueWithAssets
};

export const txOutWithDatum: Cardano.TxOut = {
  address: Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  datumHash: Crypto.Hash32ByteBase16('4c94610a582b748b8db506abb45ccd48d0d4934942daa87d191645b947a547a7'),
  value: valueWithAssets
};

export const txBody: Cardano.TxBody = {
  auxiliaryDataHash: Crypto.Hash32ByteBase16('2ceb364d93225b4a0f004a0975a13eb50c3cc6348474b4fe9121f8dc72ca0cfa'),
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
  },
  body: txBody,
  id: Cardano.TransactionId('8d2feeab1087e0aa4ad06e878c5269eaa2edcef5264bcc97542a28c189b2cbc5'),
  isValid: true,
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
    datums: [123n],
    redeemers: [
      {
        data: {
          cbor: HexBlob('d87a9f187bff'),
          constructor: 1n,
          fields: { cbor: HexBlob('9f187bff'), items: [123n] }
        },
        executionUnits: {
          memory: 3000,
          steps: 7000
        },
        index: 0,
        purpose: RedeemerPurpose.mint
      },
      {
        data: {
          cbor: HexBlob('d87a9f187bff'),
          constructor: 1n,
          fields: { cbor: HexBlob('9f187bff'), items: [123n] }
        },
        executionUnits: {
          memory: 5000,
          steps: 2000
        },
        index: 1,
        purpose: RedeemerPurpose.certificate
      }
    ],
    scripts: [
      {
        __type: ScriptType.Plutus,
        bytes: HexBlob('b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'),
        version: PlutusLanguageVersion.V1
      },
      {
        __type: ScriptType.Plutus,
        bytes: HexBlob('b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'),
        version: PlutusLanguageVersion.V2
      },
      {
        __type: ScriptType.Native,
        kind: NativeScriptKind.RequireTimeBefore,
        slot: Cardano.Slot(100)
      },
      {
        __type: ScriptType.Native,
        kind: NativeScriptKind.RequireTimeAfter,
        slot: Cardano.Slot(500)
      },
      {
        __type: ScriptType.Native,
        keyHash: Crypto.Ed25519KeyHashHex('b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54'),
        kind: NativeScriptKind.RequireSignature
      },
      {
        __type: ScriptType.Native,
        kind: NativeScriptKind.RequireAllOf,
        scripts: [
          {
            __type: ScriptType.Native,
            keyHash: Crypto.Ed25519KeyHashHex('b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54'),
            kind: NativeScriptKind.RequireSignature
          }
        ]
      },
      {
        __type: ScriptType.Native,
        kind: NativeScriptKind.RequireAnyOf,
        scripts: [
          {
            __type: ScriptType.Native,
            keyHash: Crypto.Ed25519KeyHashHex('b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54'),
            kind: NativeScriptKind.RequireSignature
          }
        ]
      },
      {
        __type: ScriptType.Native,
        kind: NativeScriptKind.RequireNOf,
        required: 1,
        scripts: [
          {
            __type: ScriptType.Native,
            keyHash: Crypto.Ed25519KeyHashHex('b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54'),
            kind: NativeScriptKind.RequireSignature
          }
        ]
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
