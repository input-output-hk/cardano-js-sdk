import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '../../../src/index.js';
import { NativeScriptKind, ScriptType } from '../../../src/Cardano/index.js';
import type { NativeScript } from '../../../src/Cardano/index.js';
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

export const vkey = '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39';
export const signature =
  // eslint-disable-next-line max-len
  'bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c8918755bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c8918755';

export const vasilPlutusV1Costmdls = [
  205_665, 812, 1, 1, 1000, 571, 0, 1, 1000, 24_177, 4, 1, 1000, 32, 117_366, 10_475, 4, 23_000, 100, 23_000, 100,
  23_000, 100, 23_000, 100, 23_000, 100, 23_000, 100, 100, 100, 23_000, 100, 19_537, 32, 175_354, 32, 46_417, 4,
  221_973, 511, 0, 1, 89_141, 32, 497_525, 14_068, 4, 2, 196_500, 453_240, 220, 0, 1, 1, 1000, 28_662, 4, 2, 245_000,
  216_773, 62, 1, 1_060_367, 12_586, 1, 208_512, 421, 1, 187_000, 1000, 52_998, 1, 80_436, 32, 43_249, 32, 1000, 32,
  80_556, 1, 57_667, 4, 1000, 10, 197_145, 156, 1, 197_145, 156, 1, 204_924, 473, 1, 208_896, 511, 1, 52_467, 32,
  64_832, 32, 65_493, 32, 22_558, 32, 16_563, 32, 76_511, 32, 196_500, 453_240, 220, 0, 1, 1, 69_522, 11_687, 0, 1,
  60_091, 32, 196_500, 453_240, 220, 0, 1, 1, 196_500, 453_240, 220, 0, 1, 1, 806_990, 30_482, 4, 1_927_926, 82_523, 4,
  265_318, 0, 4, 0, 85_931, 32, 205_665, 812, 1, 1, 41_182, 32, 212_342, 32, 31_220, 32, 32_696, 32, 43_357, 32, 32_247,
  32, 38_314, 32, 57_996_947, 18_975, 10
];

export const params = {
  coinsPerUtxoByte: 35_000,
  costModels: new Map([[0, vasilPlutusV1Costmdls]]),
  decentralizationParameter: '0.2',
  desiredNumberOfPools: 900,
  extraEntropy: '0000000000000000000000000000000000000000000000000000000000000000',
  maxBlockBodySize: 300,
  maxBlockHeaderSize: 500,
  maxExecutionUnitsPerBlock: { memory: 4_294_967_296, steps: 4_294_967_296 },
  maxExecutionUnitsPerTransaction: { memory: 4_294_967_296, steps: 4_294_967_296 },
  maxTxSize: 400,
  maxValueSize: 954,
  minFeeCoefficient: 100,
  minFeeConstant: 200,
  minPoolCost: 1000,
  monetaryExpansion: '0.3333333333333333',
  poolDeposit: 200_000_000,
  poolInfluence: '0.5',
  poolRetirementEpochBound: 800,
  prices: { memory: 0.5, steps: 0.5 },
  protocolVersion: { major: 1, minor: 3 },
  stakeKeyDeposit: 2_000_000,
  treasuryExpansion: '0.25'
};
