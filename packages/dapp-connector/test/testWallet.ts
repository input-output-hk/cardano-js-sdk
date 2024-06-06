import { Cardano, Serialization } from '@cardano-sdk/core';
import type { Cip30DataSignature, WalletApi, WalletProperties } from '../src/WalletApi/index.js';
import type { Ed25519PublicKeyHex } from '@cardano-sdk/crypto';
import type { RemoteAuthenticator } from '../src/index.js';

export const api = <WalletApi>{
  getBalance: async () => '100',
  getChangeAddress: async () => 'change-address',
  getCollateral: async () => null,
  getExtensions: async () => [{ cip: 95 }],
  getNetworkId: async () => 0,
  getPubDRepKey: async () => 'getPubDRepKey' as Ed25519PublicKeyHex,
  getRegisteredPubStakeKeys: async () =>
    ['registeredPubStakeKey-1', 'registeredPubStakeKey-2'] as Ed25519PublicKeyHex[],
  getRewardAddresses: async () => ['reward-address-1', 'reward-address-2'],
  getUnregisteredPubStakeKeys: async () =>
    ['unRegisteredPubStakeKey-1', 'unRegisteredPubStakeKey-2'] as Ed25519PublicKeyHex[],
  getUnusedAddresses: async () => ['unused-address-1', 'unused-address-2', 'unused-address-3'],
  getUsedAddresses: async () => ['used-address-1', 'used-address-2', 'used-address-3'],
  getUtxos: async (_amount) => [
    Serialization.TransactionUnspentOutput.fromCore([
      {
        index: 0,
        txId: Cardano.TransactionId('886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8')
      },
      {
        address: Cardano.PaymentAddress(
          // eslint-disable-next-line max-len
          'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
        ),
        value: { coins: 100n }
      }
    ]).toCbor()
  ],
  signData: async (_addr, _payload) => ({} as Cip30DataSignature),
  signTx: async (_tx) => 'signedTransaction',
  submitTx: async (_tx) => 'transactionId'
};

export const properties: WalletProperties = { icon: 'imagelink', walletName: 'testWallet' };

export const stubAuthenticator = () => {
  let isEnabled = false;
  return {
    haveAccess: jest.fn().mockImplementation(async () => isEnabled),
    requestAccess: jest.fn().mockImplementation(async () => (isEnabled = true))
  } as unknown as RemoteAuthenticator;
};
