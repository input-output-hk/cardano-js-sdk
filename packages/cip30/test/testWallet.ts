import { RequestAccess, WalletApi } from '../src/Wallet';

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
        txId: '123456'
      },
      { address: 'asdf', value: { assets: {}, coins: 100n } }
    ]
  ],
  signData: async (_addr, _sig) => 'signedData',
  signTx: async (_tx) => 'signedTransaction',
  submitTx: async (_tx) => 'transactionId'
};

export const properties = { name: 'test-wallet', version: '0.1.0' };

export const requestAccess: RequestAccess = async () => true;
