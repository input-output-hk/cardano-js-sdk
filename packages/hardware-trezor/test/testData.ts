import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, GroupedAddress, KeyRole } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';
import { TrezorTxTransformerContext } from '../src';

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

export const txIn: Cardano.TxIn = {
  index: 0,
  txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
};

export const paymentAddress = Cardano.PaymentAddress(
  'addr1qxdtr6wjx3kr7jlrvrfzhrh8w44qx9krcxhvu3e79zr7497tpmpxjfyhk3vwg6qjezjmlg5nr5dzm9j6nxyns28vsy8stu5lh6'
);

export const txOut: Cardano.TxOut = {
  address: Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  value: {
    coins: 10n
  }
};

export const txOutWithAssets: Cardano.TxOut = {
  address: Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  value: valueWithAssets
};

export const txOutWithAssetsToOwnedAddress: Cardano.TxOut = {
  address: paymentAddress,
  value: valueWithAssets
};

export const txOutToOwnedAddress: Cardano.TxOut = {
  address: paymentAddress,
  value: {
    coins: 10n
  }
};

export const txOutWithDatumHash: Cardano.TxOut = {
  address: Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  datumHash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
  value: {
    coins: 10n
  }
};

export const txOutWithDatumHashAndOwnedAddress: Cardano.TxOut = {
  ...txOutToOwnedAddress,
  datumHash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
};

export const txOutWithInlineDatum: Cardano.TxOut = {
  address: Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  datum: 123n,
  value: {
    coins: 10n
  }
};

export const txOutWithInlineDatumAndOwnedAddress: Cardano.TxOut = {
  ...txOutToOwnedAddress,
  datum: 123n
};

export const txOutWithReferenceScriptAndDatumHash: Cardano.TxOut = {
  address: paymentAddress,
  datumHash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
  scriptReference: {
    __type: Cardano.ScriptType.Plutus,
    bytes: HexBlob('b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'),
    version: Cardano.PlutusLanguageVersion.V1
  },
  value: { coins: 10n }
};

export const txOutWithReferenceScriptAndInlineDatum: Cardano.TxOut = {
  address: paymentAddress,
  datum: 123n,
  scriptReference: {
    __type: Cardano.ScriptType.Plutus,
    bytes: HexBlob('b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'),
    version: Cardano.PlutusLanguageVersion.V1
  },
  value: {
    coins: 10n
  }
};

export const rewardKey = 'stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr';
export const rewardScript = 'stake178phkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gtcccycj5';
export const rewardAccount = Cardano.RewardAccount(rewardKey);
export const rewardAddress = Cardano.Address.fromBech32(rewardAccount)?.asReward() as Cardano.RewardAddress;
export const rewardAccountWithPaymentScriptCredential = Cardano.RewardAccount(rewardScript);
export const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount);
export const stakeCredential = {
  hash: stakeKeyHash as unknown as Crypto.Hash28ByteBase16,
  type: Cardano.CredentialType.KeyHash
};
export const stakeScriptHash = Cardano.RewardAccount.toHash(rewardAccountWithPaymentScriptCredential);
export const paymentHash = Crypto.Ed25519KeyHashHex('9ab1e9d2346c3f4be360d22b8ee7756a0316c3c1aece473e2887ea97');
export const knownAddressKeyPath = [2_147_485_500, 2_147_485_463, 2_147_483_648, 1, 0];
export const knownAddressStakeKeyPath = [2_147_485_500, 2_147_485_463, 2_147_483_648, 2, 0];
export const poolId = Cardano.PoolId('pool1ev8vy6fyj7693ergzty2t0azjvw35tvkt2vcjwpgajqs7z6u2vn');
export const poolId2 = Cardano.PoolId('pool1z5uqdk7dzdxaae5633fqfcu2eqzy3a3rgtuvy087fdld7yws0xt');
export const vrf = Cardano.VrfVkHex('8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0');
export const metadataJson = {
  hash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
  url: 'https://example.com'
};
export const auxiliaryDataHash = Crypto.Hash32ByteBase16(
  '2ceb364d93225b4a0f004a0975a13eb50c3cc6348474b4fe9121f8dc72ca0cfa'
);

const stakeKeyDerivationPath = {
  index: 0,
  role: KeyRole.Stake
};

export const knownAddress: GroupedAddress = {
  accountIndex: 0,
  address: paymentAddress,
  index: 0,
  networkId: Cardano.NetworkId.Testnet,
  rewardAccount,
  stakeKeyDerivationPath,
  type: AddressType.Internal
};

export const knownAddressPaymentKeyPath = { index: knownAddress.index, role: Number(knownAddress.type) };

export const knownAddressWithoutStakingPath: GroupedAddress = {
  accountIndex: 0,
  address: paymentAddress,
  index: 0,
  networkId: Cardano.NetworkId.Testnet,
  rewardAccount,
  type: AddressType.Internal
};

export const contextWithKnownAddresses: TrezorTxTransformerContext = {
  accountIndex: 0,
  chainId: {
    networkId: Cardano.NetworkId.Testnet,
    networkMagic: 999
  },
  knownAddresses: [knownAddress],
  txInKeyPathMap: {}
};

export const contextWithKnownAddressesWithoutStakingCredentials: TrezorTxTransformerContext = {
  accountIndex: 0,
  chainId: {
    networkId: Cardano.NetworkId.Testnet,
    networkMagic: 999
  },
  knownAddresses: [knownAddressWithoutStakingPath],
  txInKeyPathMap: {}
};

export const contextWithoutKnownAddresses: TrezorTxTransformerContext = {
  accountIndex: 0,
  chainId: {
    networkId: Cardano.NetworkId.Testnet,
    networkMagic: 999
  },
  knownAddresses: [],
  txInKeyPathMap: {}
};

export const coreWithdrawalWithKeyHashCredential = {
  quantity: 5n,
  stakeAddress: rewardAccount
};

export const coreWithdrawalWithScriptHashCredential = {
  quantity: 5n,
  stakeAddress: rewardAccountWithPaymentScriptCredential
};

export const stakeRegistrationCertificate = {
  __typename: Cardano.CertificateType.StakeRegistration,
  stakeCredential
} as Cardano.StakeAddressCertificate;

export const stakeDeregistrationCertificate = {
  __typename: Cardano.CertificateType.StakeDeregistration,
  stakeCredential
} as Cardano.StakeAddressCertificate;

export const stakeDelegationCertificate = {
  __typename: Cardano.CertificateType.StakeDelegation,
  poolId: poolId2,
  stakeCredential
} as Cardano.StakeDelegationCertificate;

export const poolRegistrationCertificate = {
  __typename: Cardano.CertificateType.PoolRegistration,
  poolParameters: {
    cost: 1000n,
    id: poolId,
    margin: { denominator: 5, numerator: 1 },
    metadataJson,
    owners: [rewardAccount],
    pledge: 10_000n,
    relays: [
      {
        __typename: 'RelayByAddress',
        ipv4: '127.0.0.1',
        port: 6000
      },
      { __typename: 'RelayByName', hostname: 'example.com', port: 5000 },
      { __typename: 'RelayByNameMultihost', dnsName: 'example.com' }
    ],
    rewardAccount,
    vrf
  }
} as Cardano.PoolRegistrationCertificate;

export const minValidTxBody: Cardano.TxBody = {
  fee: 10n,
  inputs: [txIn],
  outputs: [txOut]
};

export const txBody: Cardano.TxBody = {
  auxiliaryDataHash,
  certificates: [stakeDelegationCertificate],
  fee: 10n,
  inputs: [txIn],
  mint: mintTokenMap,
  outputs: [txOutWithAssets, txOutWithAssetsToOwnedAddress, txOutWithDatumHash],
  referenceInputs: [txIn],
  validityInterval: {
    invalidBefore: Cardano.Slot(100),
    invalidHereafter: Cardano.Slot(1000)
  },
  withdrawals: [coreWithdrawalWithKeyHashCredential]
};

export const babbageTxBodyWithScripts: Cardano.TxBody = {
  auxiliaryDataHash,
  certificates: [stakeDelegationCertificate],
  fee: 10n,
  inputs: [txIn],
  mint: mintTokenMap,
  outputs: [txOutWithReferenceScriptAndDatumHash, txOutWithReferenceScriptAndInlineDatum],
  validityInterval: {
    invalidBefore: Cardano.Slot(100),
    invalidHereafter: Cardano.Slot(1000)
  },
  withdrawals: [coreWithdrawalWithKeyHashCredential]
};

export const txBodyWithCollaterals = {
  ...minValidTxBody,
  collateralReturn: txOut,
  collaterals: [txIn]
};

export const plutusTxWithBabbage = {
  ...babbageTxBodyWithScripts,
  collateralReturn: txOut,
  collaterals: [txIn],
  requiredExtraSignatures: [Crypto.Ed25519KeyHashHex('6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d39')],
  totalCollateral: 1000n
};
