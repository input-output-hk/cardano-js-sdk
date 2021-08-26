/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable @typescript-eslint/no-unused-vars */

import { RequestAccess, Wallet, WalletApi, WalletOptions } from '@src/Wallet';
import { mocks } from 'mock-browser';

const window = mocks.MockBrowser.createWindow();

const props = { name: 'test-wallet', version: '0.1.0' };
const _api = <WalletApi>{
  getUtxos: async (_amount) => [
    [
      { txId: '123456', index: 0 },
      { address: 'asdf', value: { coins: 100, assets: {} } }
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
const requestAccess: RequestAccess = async () => true;
// todo test persistAllowList: true when design is finalised
const options: WalletOptions = { persistAllowList: false };

if (process.env.DEBUG) {
  options.logger = console;
}
const wallet = new Wallet(props, _api, window, requestAccess, options);

describe('Wallet', () => {
  const apiMethods = [
    'getUtxos',
    'getBalance',
    'getUsedAddresses',
    'getUnusedAddresses',
    'getChangeAddress',
    'getRewardAddresses',
    'signTx',
    'signData',
    'submitTx'
  ];

  test('wallet version', () => {
    expect(wallet.version).toBeDefined();
    expect(typeof wallet.version).toBe('string');
    expect(wallet.version).toBe('0.1.0');
  });

  test('wallet name', () => {
    expect(wallet.name).toBeDefined();
    expect(typeof wallet.name).toBe('string');
    expect(wallet.name).toBe('test-wallet');
  });

  test('isEnabled should be false', async () => {
    expect(wallet.isEnabled).toBeDefined();
    expect(typeof wallet.isEnabled).toBe('function');

    const isEnabled = await wallet.isEnabled();
    expect(typeof isEnabled).toBe('boolean');
    expect(isEnabled).toBe(false);
  });

  test('enable', async () => {
    expect(wallet.enable).toBeDefined();
    expect(typeof wallet.enable).toBe('function');

    const api = await wallet.enable();
    expect(api).toBeTruthy();
    expect(typeof api).toBe('object');

    const methods = Object.keys(api);
    expect(methods).toEqual(apiMethods);
  });

  test('isEnabled should be true', async () => {
    const isEnabled = await wallet.isEnabled();
    expect(isEnabled).toBe(true);
  });

  test('cardano object exists in global scope', async () => {
    expect(window.cardano).toBeDefined();
  });

  test('cardano.walletName is type CardanoWalletPublic', async () => {
    expect(window.cardano['test-wallet']).toBeDefined();
    expect(Object.keys(window.cardano['test-wallet'])).toEqual(['name', 'version', 'enable', 'isEnabled']);
  });

  describe('api', () => {
    let api: WalletApi | null;

    beforeAll(async () => {
      api = await wallet.enable();
    });

    test('getUtxos', async () => {
      expect(api.getUtxos).toBeDefined();
      expect(typeof api.getUtxos).toBe('function');

      const uxtos = await api.getUtxos();
      expect(uxtos).toEqual([
        [
          { txId: '123456', index: 0 },
          { address: 'asdf', value: { coins: 100, assets: {} } }
        ]
      ]);
    });

    test('getBalance', async () => {
      expect(api.getBalance).toBeDefined();
      expect(typeof api.getBalance).toBe('function');

      const balance = await api.getBalance();
      expect(balance).toEqual('100');
    });

    test('getUsedAddresses', async () => {
      expect(api.getUsedAddresses).toBeDefined();
      expect(typeof api.getUsedAddresses).toBe('function');

      const usedAddresses = await api.getUsedAddresses();
      expect(usedAddresses).toEqual(['used-address-1', 'used-address-2', 'used-address-3']);
    });

    test('getUnusedAddresses', async () => {
      expect(api.getUnusedAddresses).toBeDefined();
      expect(typeof api.getUnusedAddresses).toBe('function');

      const unusedAddresses = await api.getUnusedAddresses();
      expect(unusedAddresses).toEqual(['unused-address-1', 'unused-address-2', 'unused-address-3']);
    });

    test('getChangeAddress', async () => {
      expect(api.getChangeAddress).toBeDefined();
      expect(typeof api.getChangeAddress).toBe('function');

      const changeAddress = await api.getChangeAddress();
      expect(changeAddress).toEqual('change-address');
    });

    test('getRewardAddresses', async () => {
      expect(api.getRewardAddresses).toBeDefined();
      expect(typeof api.getRewardAddresses).toBe('function');

      const rewardAddresses = await api.getRewardAddresses();
      expect(rewardAddresses).toEqual(['reward-address-1', 'reward-address-2']);
    });

    test('signTx', async () => {
      expect(api.signTx).toBeDefined();
      expect(typeof api.signTx).toBe('function');

      const signedTx = await api.signTx('tx');
      expect(signedTx).toEqual('signedTransaction');
    });

    test('signData', async () => {
      expect(api.signData).toBeDefined();
      expect(typeof api.signData).toBe('function');

      const signedData = await api.signData('addr', 'sig');
      expect(signedData).toEqual('signedData');
    });

    test('submitTx', async () => {
      expect(api.submitTx).toBeDefined();
      expect(typeof api.submitTx).toBe('function');

      const txId = await api.submitTx('tx');
      expect(txId).toEqual('transactionId');
    });
  });
});
