import { Cardano } from '../../src';
import { Ed25519KeyHash } from '../../src/Cardano';

export const rewardAccount = Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr');
export const stakeKeyHash = Ed25519KeyHash.fromRewardAccount(rewardAccount);
export const poolId = Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34');
export const ownerRewardAccount = Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr');
export const vrf = Cardano.VrfVkHex('8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0');
export const metadataJson = {
  hash: Cardano.util.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
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
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  ...txIn
};

export const txOut: Cardano.TxOut = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  value: valueWithAssets
};

export const txOutWithByron: Cardano.TxOut = {
  address: Cardano.Address('5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg'),
  value: valueWithAssets
};

export const txOutWithDatum: Cardano.TxOut = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  datum: Cardano.util.Hash32ByteBase16('4c94610a582b748b8db506abb45ccd48d0d4934942daa87d191645b947a547a7'),
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
      genesisDelegateHash: Cardano.util.Hash28ByteBase16('a646474b8f5431261506b6c273d307c7569a4eb6c96b42dd4a29520a'),
      genesisHash: Cardano.util.Hash28ByteBase16('0d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4'),
      vrfKeyHash: Cardano.util.Hash32ByteBase16('03170a2e7597b7b7e3d84c05391d139a62b157e78786d8c082f29dcf4c111314')
    }
  ],
  collaterals: [{ ...txIn, index: txIn.index + 1 }],
  fee: 10n,
  inputs: [txIn],
  mint: mintTokenMap,
  outputs: [txOut],
  requiredExtraSignatures: [Cardano.Ed25519KeyHash('6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d39')],
  scriptIntegrityHash: Cardano.util.Hash32ByteBase16(
    '6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d38abc123de'
  ),
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
    signatures: new Map([[Cardano.Ed25519PublicKey(vkey), Cardano.Ed25519Signature(signature)]])
  }
};
