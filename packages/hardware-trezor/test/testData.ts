import { AddressType, CardanoKeyConst, GroupedAddress, KeyRole, util } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';

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

export const rewardAccount = Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr');

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

export const knownAddressKeyPath = [
  util.harden(CardanoKeyConst.PURPOSE),
  util.harden(CardanoKeyConst.COIN_TYPE),
  util.harden(knownAddress.accountIndex),
  knownAddress.type,
  knownAddress.index
];

export const knownAddressStakingKeyPath = [
  util.harden(CardanoKeyConst.PURPOSE),
  util.harden(CardanoKeyConst.COIN_TYPE),
  util.harden(knownAddress.accountIndex),
  stakeKeyDerivationPath.role,
  stakeKeyDerivationPath.index
];

export const CONTEXT_WITH_KNOWN_ADDRESSES = {
  chainId: {
    networkId: Cardano.NetworkId.Testnet,
    networkMagic: 999
  },
  inputResolver: { resolveInput: () => Promise.resolve(txOutToOwnedAddress) },
  knownAddresses: [knownAddress]
};

export const CONTEXT_WITHOUT_KNOWN_ADDRESSES = {
  chainId: {
    networkId: Cardano.NetworkId.Testnet,
    networkMagic: 999
  },
  inputResolver: { resolveInput: () => Promise.resolve(null) },
  knownAddresses: []
};
