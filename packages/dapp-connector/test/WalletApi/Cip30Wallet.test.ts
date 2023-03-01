import * as testWallet from '../testWallet';
import { Cardano } from '@cardano-sdk/core';
import { Cip30Wallet, RemoteAuthenticator, WalletApi, WalletApiMethodNames } from '../../src';
import { dummyLogger } from 'ts-log';
import browser from 'webextension-polyfill';

describe('Wallet', () => {
  const logger = dummyLogger;
  let authenticator: RemoteAuthenticator;

  let wallet: Cip30Wallet;

  beforeEach(async () => {
    await browser.storage.local.clear();
    authenticator = testWallet.stubAuthenticator();
    wallet = new Cip30Wallet(testWallet.properties, {
      api: testWallet.api,
      authenticator,
      logger
    });
  });

  test('constructed state', async () => {
    expect(typeof wallet.apiVersion).toBe('string');
    expect(wallet.apiVersion).toBe('0.1.0');
    expect(typeof wallet.name).toBe('string');
    expect(wallet.name).toBe(testWallet.properties.walletName);
    expect(typeof wallet.isEnabled).toBe('function');
    const isEnabled = await wallet.isEnabled();
    expect(typeof isEnabled).toBe('boolean');
    expect(isEnabled).toBe(false);
    expect(typeof wallet.enable).toBe('function');
  });

  test('enable', async () => {
    expect(await wallet.isEnabled()).toBe(false);
    const api = await wallet.enable();
    expect(typeof api).toBe('object');
    const methods = new Set(Object.keys(api));
    expect(methods).toEqual(new Set(WalletApiMethodNames));
    expect(await wallet.isEnabled()).toBe(true);
  });

  test('prior enabling should persist', async () => {
    await authenticator.requestAccess();
    const persistedWallet = new Cip30Wallet(
      { ...testWallet.properties },
      { api: testWallet.api, authenticator, logger }
    );

    expect(await persistedWallet.isEnabled()).toBe(true);
  });

  describe('api', () => {
    let api: WalletApi;

    beforeAll(async () => {
      api = await wallet.enable();
    });

    test('getNetworkId', async () => {
      expect(api.getNetworkId).toBeDefined();
      expect(typeof api.getNetworkId).toBe('function');

      const networkId = await api.getNetworkId();
      expect(networkId).toEqual(0);
    });

    test('getUtxos', async () => {
      expect(api.getUtxos).toBeDefined();
      expect(typeof api.getUtxos).toBe('function');

      const utxos = await api.getUtxos();
      expect(typeof utxos![0]).toBe('string');
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

      const signedData = await api.signData(
        Cardano.PaymentAddress('addr_test1vrfxjeunkc9xu8rpnhgkluptaq0rm8kyxh8m3q9vtcetjwshvpnsm'),
        Buffer.from('').toString('hex')
      );
      expect(signedData).toEqual({});
    });

    test('signData accepts hex format address', async () => {
      jest.resetAllMocks();
      const signedData = await api.signData(
        '60d2696793b60a6e1c619dd16ff02be81e3d9ec435cfb880ac5e32b93a',
        Buffer.from('').toString('hex')
      );
      expect(signedData).toEqual({});
    });

    test('submitTx', async () => {
      expect(api.submitTx).toBeDefined();
      expect(typeof api.submitTx).toBe('function');

      const txId = await api.submitTx('tx');
      expect(txId).toEqual('transactionId');
    });
  });
});
