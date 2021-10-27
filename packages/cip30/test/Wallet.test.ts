/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable @typescript-eslint/no-unused-vars */

import { Wallet, WalletApi, WalletOptions } from '../src/Wallet';
import { mocks } from 'mock-browser';
import * as testWallet from './testWallet';
const window = mocks.MockBrowser.createWindow();

// todo test persistAllowList: true when design is finalised
const options: WalletOptions = { persistAllowList: false };

if (process.env.DEBUG) {
  options.logger = console;
}

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
  let wallet: Wallet;

  beforeEach(() => {
    wallet = new Wallet(testWallet.properties, testWallet.api, testWallet.requestAccess, options);
  });

  test('constructed state', async () => {
    expect(typeof wallet.version).toBe('string');
    expect(wallet.version).toBe('0.1.0');
    expect(typeof wallet.name).toBe('string');
    expect(wallet.name).toBe('test-wallet');
    expect(typeof wallet.isEnabled).toBe('function');
    const isEnabled = await wallet.isEnabled(window);
    expect(typeof isEnabled).toBe('boolean');
    expect(isEnabled).toBe(false);
    expect(typeof wallet.enable).toBe('function');
  });

  test('getPublicApi', async () => {
    const publicApi = wallet.getPublicApi(window);
    expect(publicApi.name).toEqual('test-wallet');
    expect(await publicApi.isEnabled()).toEqual(false);
  });

  test('enable', async () => {
    const windowStub = { ...window, location: { hostname: 'test-dapp' } };
    expect(await wallet.isEnabled(window)).toBe(false);
    const api = await wallet.enable(windowStub);
    expect(typeof api).toBe('object');
    const methods = Object.keys(api);
    expect(methods).toEqual(apiMethods);
    expect(await wallet.isEnabled(windowStub)).toBe(true);
  });

  describe('api', () => {
    let api: WalletApi;

    beforeAll(async () => {
      api = await wallet.enable(window);
    });

    test('getUtxos', async () => {
      expect(api.getUtxos).toBeDefined();
      expect(typeof api.getUtxos).toBe('function');

      const uxtos = await api.getUtxos();
      expect(uxtos).toEqual([
        [
          { txId: '123456', index: 0 },
          { address: 'asdf', value: { coins: 100n, assets: {} } }
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
