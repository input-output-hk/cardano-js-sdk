import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, KeyRole } from '@cardano-sdk/key-management';
import { Base64Blob, HexBlob } from '@cardano-sdk/util';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { LedgerTxTransformerContext } from '../src';
export const rewardAccount = Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d');
export const rewardAccount2 = Cardano.RewardAccount('stake_test1uqrw9tjymlm8wrwq7jk68n6v7fs9qz8z0tkdkve26dylmfc2ux2hj');
export const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount);
export const stakeCredential = {
  hash: stakeKeyHash,
  type: Cardano.CredentialType.KeyHash
};

export const dRepCredential = {
  hash: Crypto.Hash28ByteBase16('b276b4f7a706a81364de606d890343a76af570268d4bbfee2fc8fcab'),
  type: Cardano.CredentialType.KeyHash
};
export const paymentAddress = Cardano.PaymentAddress(
  'addr1qxdtr6wjx3kr7jlrvrfzhrh8w44qx9krcxhvu3e79zr7497tpmpxjfyhk3vwg6qjezjmlg5nr5dzm9j6nxyns28vsy8stu5lh6'
);
export const paymentHash = Crypto.Ed25519KeyHashHex('9ab1e9d2346c3f4be360d22b8ee7756a0316c3c1aece473e2887ea97');
export const poolId = Cardano.PoolId('pool10stzgpc5ag8p9dq6j98jj3tcftzffwce2ulsefs6pzh6sw2zet5');
export const poolId2 = Cardano.PoolId('pool1z5uqdk7dzdxaae5633fqfcu2eqzy3a3rgtuvy087fdld7yws0xt');
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
  owners: [rewardAccount],
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

export const pureAdaTxOut: Cardano.TxOut = {
  address: Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  value: { coins: 10n }
};

export const txOutWithDatum: Cardano.TxOut = {
  address: Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  datumHash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
  value: { coins: 10n }
};

export const txOut: Cardano.TxOut = {
  address: Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  datumHash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
  value: valueWithAssets
};

export const txOutToOwnedAddress: Cardano.TxOut = {
  address: paymentAddress,
  datumHash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
  value: valueWithAssets
};

export const txOutWithReferenceScript: Cardano.TxOut = {
  address: paymentAddress,
  datumHash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
  scriptReference: {
    __type: Cardano.ScriptType.Plutus,
    bytes: HexBlob('b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'),
    version: Cardano.PlutusLanguageVersion.V1
  },
  value: { coins: 10n }
};

export const txOutWithReferenceScriptWithInlineDatum: Cardano.TxOut = {
  address: paymentAddress,
  datum: 123n,
  scriptReference: {
    __type: Cardano.ScriptType.Plutus,
    bytes: HexBlob('b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'),
    version: Cardano.PlutusLanguageVersion.V1
  },
  value: { coins: 10n }
};

export const txBody: Cardano.TxBody = {
  auxiliaryDataHash: Crypto.Hash32ByteBase16('2ceb364d93225b4a0f004a0975a13eb50c3cc6348474b4fe9121f8dc72ca0cfa'),
  certificates: [
    {
      __typename: Cardano.CertificateType.PoolRetirement,
      epoch: Cardano.EpochNo(500),
      poolId
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
  outputs: [txOutWithReferenceScript],
  validityInterval: {
    invalidBefore: Cardano.Slot(100),
    invalidHereafter: Cardano.Slot(1000)
  }
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
        data: Serialization.PlutusData.fromCbor(HexBlob('d86682008101')).toCore(),
        executionUnits: {
          memory: 3000,
          steps: 7000
        },
        index: 0,
        purpose: Cardano.RedeemerPurpose.mint
      },
      {
        data: Serialization.PlutusData.fromCbor(HexBlob('d86682008102')).toCore(),
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

export const CONTEXT_WITH_KNOWN_ADDRESSES: LedgerTxTransformerContext = {
  accountIndex: 0,
  chainId: {
    networkId: Cardano.NetworkId.Testnet,
    networkMagic: 999
  },
  dRepKeyHashHex: Crypto.Ed25519KeyHashHex(dRepCredential.hash),
  knownAddresses: [
    {
      accountIndex: 0,
      address: paymentAddress,
      index: 0,
      networkId: Cardano.NetworkId.Testnet,
      rewardAccount,
      stakeKeyDerivationPath: {
        index: 0,
        role: KeyRole.Stake
      },
      type: AddressType.Internal
    }
  ],
  txInKeyPathMap: {},
  useBabbageOutputs: true
};

export const CONTEXT_WITHOUT_KNOWN_ADDRESSES: LedgerTxTransformerContext = {
  accountIndex: 0,
  chainId: {
    networkId: Cardano.NetworkId.Testnet,
    networkMagic: 999
  },
  knownAddresses: [],
  txInKeyPathMap: {},
  useBabbageOutputs: true
};

export const votes = [
  {
    actionId: {
      actionIndex: 1,
      id: Cardano.TransactionId('8d2feeab1087e0aa4ad06e878c5269eaa2edcef5264bcc97542a28c189b2cbc5')
    },
    votingProcedure: {
      anchor: {
        dataHash: metadataJson.hash,
        url: metadataJson.url
      },
      vote: Cardano.Vote.yes
    }
  },
  {
    actionId: {
      actionIndex: 2,
      id: Cardano.TransactionId('8d2feeab1087e0aa4ad06e878c5269eaa2edcef5264bcc97542a28c189b2cbc6')
    },
    votingProcedure: {
      anchor: null,
      vote: Cardano.Vote.no
    }
  },
  {
    actionId: {
      actionIndex: 3,
      id: Cardano.TransactionId('8d2feeab1087e0aa4ad06e878c5269eaa2edcef5264bcc97542a28c189b2cbc7')
    },
    votingProcedure: {
      anchor: null,
      vote: Cardano.Vote.abstain
    }
  }
];

export const dRepKeyHashVoter: Cardano.Voter = {
  __typename: Cardano.VoterType.dRepKeyHash,
  credential: {
    hash: dRepCredential.hash,
    type: Cardano.CredentialType.KeyHash
  }
};

export const dRepScriptHashVoter: Cardano.Voter = {
  __typename: Cardano.VoterType.dRepScriptHash,
  credential: {
    hash: stakeCredential.hash,
    type: Cardano.CredentialType.ScriptHash
  }
};

export const stakePoolKeyHashVoter: Cardano.Voter = {
  __typename: Cardano.VoterType.stakePoolKeyHash,
  credential: {
    hash: stakeCredential.hash,
    type: Cardano.CredentialType.KeyHash
  }
};

export const ccHotKeyHashVoter: Cardano.Voter = {
  __typename: Cardano.VoterType.ccHotKeyHash,
  credential: {
    hash: stakeCredential.hash,
    type: Cardano.CredentialType.KeyHash
  }
};

export const ccHotScriptHashVoter: Cardano.Voter = {
  __typename: Cardano.VoterType.ccHotScriptHash,
  credential: {
    hash: stakeCredential.hash,
    type: Cardano.CredentialType.ScriptHash
  }
};

export const singleVotingProcedure: Cardano.VotingProcedures = [
  {
    voter: dRepKeyHashVoter,
    votes: [votes[0]]
  }
];

export const singleVotingProcedureMultipleVotes: Cardano.VotingProcedures = [
  {
    voter: dRepKeyHashVoter,
    votes
  }
];

export const votingProcedureVotes = [
  {
    actionId: {
      actionIndex: 1,
      id: 'someActionId' as Cardano.TransactionId
    },
    votingProcedure: {
      anchor: {
        dataHash: 'datahash' as Crypto.Hash32ByteBase16,
        url: 'http://example.com'
      },
      vote: Cardano.Vote.yes
    }
  }
];

export const constitutionalCommitteeVotingProcedure = {
  voter: ccHotKeyHashVoter,
  votes: votingProcedureVotes
};
