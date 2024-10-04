import { ApiError } from '../src/errors';
import { Cip30Wallet } from '../src/WalletApi';
import { RemoteAuthenticator, WindowMaybeWithCardano, injectGlobal } from '../src';
import { api, properties, stubAuthenticator } from './testWallet';
import { dummyLogger as logger } from 'ts-log';
import { mocks } from 'mock-browser';

describe('injectGlobal', () => {
  let window: ReturnType<typeof mocks.MockBrowser>;

  beforeEach(() => {
    window = mocks.MockBrowser.createWindow();
  });

  it('creates the cardano scope when not exists, and injects the wallet public API into it', async () => {
    const wallet = new Cip30Wallet(properties, { api, authenticator: stubAuthenticator(), logger });
    expect(window.cardano).not.toBeDefined();
    injectGlobal(window, wallet, logger);
    expect(window.cardano).toBeDefined();
    expect(window.cardano[properties.walletName].name).toBe(properties.walletName);
    expect(typeof window.cardano[properties.walletName].apiVersion).toBe('string');
    expect(window.cardano[properties.walletName].icon).toBe(properties.icon);
    expect(await window.cardano[properties.walletName].isEnabled(window.location.hostname)).toBe(false);
    await window.cardano[properties.walletName].enable(window.location.hostname);
    expect(await window.cardano[properties.walletName].isEnabled(window.location.hostname)).toBe(true);
  });

  test('throws ApiError when not allowed', async () => {
    const requestAccess = jest.fn().mockResolvedValueOnce(false);
    const wallet = new Cip30Wallet(properties, {
      api,
      authenticator: { requestAccess } as unknown as RemoteAuthenticator,
      logger
    });

    injectGlobal(window, wallet, logger);

    await expect(window.cardano[properties.walletName].enable()).rejects.toThrow(ApiError);
  });

  describe('existing cardano object', () => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let anotherObj: any;

    beforeEach(() => {
      anotherObj = { anything: 'here', could: 'be' };
      expect(window.cardano).not.toBeDefined();
      window.cardano = {} as WindowMaybeWithCardano;
      window.cardano['another-obj'] = anotherObj;
      expect(window.cardano).toBeDefined();
    });

    it('injects the wallet public API into the existing cardano scope', () => {
      const wallet = new Cip30Wallet(properties, { api, authenticator: stubAuthenticator(), logger });
      expect(window.cardano).toBeDefined();
      injectGlobal(window, wallet, logger);
      expect(window.cardano[properties.walletName].name).toBe(properties.walletName);
      expect(typeof window.cardano[properties.walletName].apiVersion).toBe('string');
      expect(window.cardano[properties.walletName].icon).toBe(properties.icon);
      expect(window.cardano[properties.walletName].isEnabled).toBeDefined();
      expect(typeof window.cardano[properties.walletName].isEnabled).toBe('function');
      expect(window.cardano[properties.walletName].enable).toBeDefined();
      expect(typeof window.cardano[properties.walletName].enable).toBe('function');
      expect(Object.keys(window.cardano[properties.walletName])).toEqual([
        'apiVersion',
        'supportedExtensions',
        'icon',
        'name',
        'enable',
        'isEnabled'
      ]);
      expect(window.cardano['another-obj']).toBe(anotherObj);
    });

    it('injects the wallet public API using custom injection name', () => {
      const wallet = new Cip30Wallet(properties, { api, authenticator: stubAuthenticator(), logger });
      injectGlobal(window, wallet, logger, 'customKey');
      expect(window.cardano.customKey.name).toBe(properties.walletName);
      expect(Object.keys(window.cardano.customKey)).toEqual([
        'apiVersion',
        'supportedExtensions',
        'icon',
        'name',
        'enable',
        'isEnabled'
      ]);
    });
  });
});
