import * as testWallet from '../testWallet.js';
import { ApiError, Cip30Wallet, CipMethodsMapping } from '../../src/index.js';
import { Cardano } from '@cardano-sdk/core';
import { dummyLogger } from 'ts-log';
import browser from 'webextension-polyfill';
import type {
  Cip30EnableOptions,
  Cip30WalletApiWithPossibleExtensions,
  RemoteAuthenticator,
  WalletApiExtension
} from '../../src/index.js';

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
    expect(wallet.supportedExtensions).toEqual<WalletApiExtension[]>([{ cip: 95 }]);
    expect(typeof wallet.isEnabled).toBe('function');
    const isEnabled = await wallet.isEnabled();
    expect(typeof isEnabled).toBe('boolean');
    expect(isEnabled).toBe(false);
    expect(typeof wallet.enable).toBe('function');
  });

  it('should return initial api as plain javascript object', () => {
    // Verbose to enable easy detection of which are missing
    expect(wallet.hasOwnProperty('apiVersion')).toBe(true);
    expect(wallet.hasOwnProperty('enable')).toBe(true);
    expect(wallet.hasOwnProperty('icon')).toBe(true);
    expect(wallet.hasOwnProperty('isEnabled')).toBe(true);
    expect(wallet.hasOwnProperty('name')).toBe(true);
    expect(wallet.hasOwnProperty('supportedExtensions')).toBe(true);
  });

  describe('enable', () => {
    test('no extensions', async () => {
      expect(await wallet.isEnabled()).toBe(false);
      const api = await wallet.enable();
      expect(typeof api).toBe('object');
      const methods = new Set(Object.keys(api));
      expect(methods).toEqual(new Set([...CipMethodsMapping[30], 'experimental']));
      expect(await wallet.isEnabled()).toBe(true);
      expect(await api.getExtensions()).toEqual([]);
    });

    test('with cip95 extension', async () => {
      const api = await wallet.enable({ extensions: [{ cip: 95 }] });
      expect(typeof api).toBe('object');
      const methods = new Set(Object.keys(api));
      expect(methods).toEqual(new Set([...CipMethodsMapping[30], 'cip95', 'experimental']));
      const cip95Methods = new Set(Object.keys(api.cip95!));
      expect(cip95Methods).toEqual(new Set(CipMethodsMapping[95]));
      expect(await wallet.isEnabled()).toBe(true);
      expect(await api.getExtensions()).toEqual([{ cip: 95 }]);
    });

    test('change extensions after enabling once', async () => {
      const cip30api = await wallet.enable();
      const cip30methods = new Set(Object.keys(cip30api));
      expect(cip30methods).toEqual(new Set([...CipMethodsMapping[30], 'experimental']));
      expect(await wallet.isEnabled()).toBe(true);
      expect(await cip30api.getExtensions()).toEqual([]);

      const cip95api = await wallet.enable({ extensions: [{ cip: 95 }] });
      const cip95methods = new Set(Object.keys(cip95api));
      expect(cip95methods).toEqual(new Set([...CipMethodsMapping[30], 'cip95', 'experimental']));
      const cip95InnerMethods = new Set(Object.keys(cip95api.cip95!));
      expect(cip95InnerMethods).toEqual(new Set(CipMethodsMapping[95]));
      expect(await wallet.isEnabled()).toBe(true);
      expect(await cip95api.getExtensions()).toEqual([{ cip: 95 }]);
    });

    test('unsupported extensions does not reject and returns cip30 methods', async () => {
      const api = await wallet.enable({ extensions: [{ cip: 9999 }] });
      expect(typeof api).toBe('object');
      const methods = new Set(Object.keys(api));
      expect(methods).toEqual(new Set([...CipMethodsMapping[30], 'experimental']));
      expect(await wallet.isEnabled()).toBe(true);
      expect(await api.getExtensions()).toEqual([]);
    });

    test('empty enable options does not reject and returns cip30 methods', async () => {
      const api = await wallet.enable({} as Cip30EnableOptions);
      expect(typeof api).toBe('object');
      const methods = new Set(Object.keys(api));
      expect(methods).toEqual(new Set([...CipMethodsMapping[30], 'experimental']));
      expect(await wallet.isEnabled()).toBe(true);
      expect(await api.getExtensions()).toEqual([]);
    });

    test('throws if access to wallet api is not authorized', async () => {
      (authenticator.requestAccess as jest.Mock).mockResolvedValueOnce(false);
      await expect(wallet.enable()).rejects.toThrow(ApiError);
      expect(await wallet.isEnabled()).toBe(false);
    });

    test('throws on invalid extensions parameter', async () => {
      // non-array extensions
      await expect(wallet.enable({ extensions: {} as unknown as WalletApiExtension[] })).rejects.toThrow(ApiError);
      await expect(wallet.enable({ extensions: 'cip30' as unknown as WalletApiExtension[] })).rejects.toThrow(ApiError);
      await expect(wallet.enable({ extensions: 95 as unknown as WalletApiExtension[] })).rejects.toThrow(ApiError);
      await expect(wallet.enable({ extensions: null as unknown as WalletApiExtension[] })).rejects.toThrow(ApiError);

      // extensions array with non-objects or null elements
      await expect(wallet.enable({ extensions: ['95'] as unknown as WalletApiExtension[] })).rejects.toThrow(ApiError);
      await expect(wallet.enable({ extensions: [95] as unknown as WalletApiExtension[] })).rejects.toThrow(ApiError);
      await expect(wallet.enable({ extensions: [undefined] as unknown as WalletApiExtension[] })).rejects.toThrow(
        ApiError
      );
      await expect(wallet.enable({ extensions: [null] as unknown as WalletApiExtension[] })).rejects.toThrow(ApiError);

      // extensions array with invalid cip objects
      await expect(
        wallet.enable({ extensions: [{ cip: 'ninety-five' }] as unknown as WalletApiExtension[] })
      ).rejects.toThrow(ApiError);
      await expect(
        wallet.enable({ extensions: [{ cip: undefined }] as unknown as WalletApiExtension[] })
      ).rejects.toThrow(ApiError);
      await expect(wallet.enable({ extensions: [{ cip: null }] as unknown as WalletApiExtension[] })).rejects.toThrow(
        ApiError
      );
      await expect(wallet.enable({ extensions: [{ notCip: 95 }] as unknown as WalletApiExtension[] })).rejects.toThrow(
        ApiError
      );

      expect(await wallet.isEnabled()).toBe(false);
    });
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
    let api: Cip30WalletApiWithPossibleExtensions;

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

    test('getExtensions', async () => {
      expect(api.getExtensions).toBeDefined();
      expect(typeof api.getExtensions).toBe('function');

      const extensions = await api.getExtensions();
      expect(extensions).toEqual([]);
    });
  });
});
