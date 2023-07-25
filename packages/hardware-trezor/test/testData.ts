import { AddressType, GroupedAddress, KeyRole } from '@cardano-sdk/key-management';
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

export const rewardKey = 'stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr';
export const rewardScript = 'stake178phkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gtcccycj5';
export const rewardAccount = Cardano.RewardAccount(rewardKey);
export const rewardAddress = Cardano.Address.fromBech32(rewardAccount)?.asReward();
export const rewardAccountWithPaymentScriptCredential = Cardano.RewardAccount(rewardScript);
export const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount);
export const stakeScriptHash = Cardano.RewardAccount.toHash(rewardAccountWithPaymentScriptCredential);
export const knownAddressKeyPath = [2_147_485_500, 2_147_485_463, 2_147_483_648, 1, 0];
export const knownAddressStakeKeyPath = [2_147_485_500, 2_147_485_463, 2_147_483_648, 2, 0];

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

export const contextWithKnownAddresses = {
  chainId: {
    networkId: Cardano.NetworkId.Testnet,
    networkMagic: 999
  },
  inputResolver: { resolveInput: () => Promise.resolve(txOutToOwnedAddress) },
  knownAddresses: [knownAddress]
};

export const contextWithoutKnownAddresses = {
  chainId: {
    networkId: Cardano.NetworkId.Testnet,
    networkMagic: 999
  },
  inputResolver: { resolveInput: () => Promise.resolve(null) },
  knownAddresses: []
};

export const coreWithdrawalWithKeyHashCredential = {
  quantity: 5n,
  stakeAddress: rewardAccount
};

export const coreWithdrawalWithScriptHashCredential = {
  quantity: 5n,
  stakeAddress: rewardAccountWithPaymentScriptCredential
};
