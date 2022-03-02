import { Cardano } from '@cardano-sdk/core';
import { RequestAccess, WalletApi, WalletProperties } from '../src/Wallet';

export const api = <WalletApi>{
  getBalance: async () => '100',
  getChangeAddress: async () => 'change-address',
  getRewardAddresses: async () => ['reward-address-1', 'reward-address-2'],
  getUnusedAddresses: async () => ['unused-address-1', 'unused-address-2', 'unused-address-3'],
  getUsedAddresses: async () => ['used-address-1', 'used-address-2', 'used-address-3'],
  getUtxos: async (_amount) => [
    [
      {
        index: 0,
        txId: Cardano.TransactionId('886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8')
      },
      {
        address: Cardano.Address(
          'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
        ),
        value: { assets: {}, coins: 100n }
      }
    ]
  ],
  signData: async (_addr, _sig) => 'signedData',
  signTx: async (_tx) => 'signedTransaction',
  submitTx: async (_tx) => 'transactionId'
};

export const properties: WalletProperties = { apiVersion: '0.1.0', icon: 'imagelink', name: 'test-wallet' };

export const requestAccess: RequestAccess = async () => true;
