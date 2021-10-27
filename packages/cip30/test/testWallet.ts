import { RequestAccess, WalletApi } from '../src/Wallet';

export const api = <WalletApi>{
  getUtxos: async (_amount) => [
    [
      {
        txId: '123456',
        index: 0
      },
      { address: 'asdf', value: { coins: 100n, assets: {} } }
    ]
  ],
  getBalance: async () => '100',
  getUsedAddresses: async () => ['used-address-1', 'used-address-2', 'used-address-3'],
  getUnusedAddresses: async () => ['unused-address-1', 'unused-address-2', 'unused-address-3'],
  getChangeAddress: async () => 'change-address',
  getRewardAddresses: async () => ['reward-address-1', 'reward-address-2'],
  signTx: async (_tx) => 'signedTransaction',
  signData: async (_addr, _sig) => 'signedData',
  submitTx: async (_tx) => 'transactionId'
};

export const properties = { name: 'test-wallet', version: '0.1.0' };

export const requestAccess: RequestAccess = async () => true;
