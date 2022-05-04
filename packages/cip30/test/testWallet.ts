import { Cardano, coreToCsl } from '@cardano-sdk/core';
import { RemoteAuthenticator } from '../src';
import { WalletApi, WalletProperties } from '../src/WalletApi';

export const api = <WalletApi>{
  getBalance: async () => '100',
  getChangeAddress: async () => 'change-address',
  getNetworkId: async () => 0,
  getRewardAddresses: async () => ['reward-address-1', 'reward-address-2'],
  getUnusedAddresses: async () => ['unused-address-1', 'unused-address-2', 'unused-address-3'],
  getUsedAddresses: async () => ['used-address-1', 'used-address-2', 'used-address-3'],
  getUtxos: async (_amount) =>
    coreToCsl
      .utxo([
        [
          {
            address: Cardano.Address('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg'),
            index: 0,
            txId: Cardano.TransactionId('886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8')
          },
          {
            address: Cardano.Address(
              // eslint-disable-next-line max-len
              'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
            ),
            value: { coins: 100n }
          }
        ]
      ])
      .map((utxo) => Buffer.from(utxo.to_bytes()).toString('hex')),
  signData: async (_addr, _payload) => ({}),
  signTx: async (_tx) => 'signedTransaction',
  submitTx: async (_tx) => 'transactionId'
};

export const properties: WalletProperties = { icon: 'imagelink', walletName: 'testWallet' };

export const stubAuthenticator = () => {
  let isEnabled = false;
  return {
    haveAccess: async () => isEnabled,
    requestAccess: async () => (isEnabled = true)
  } as RemoteAuthenticator;
};
