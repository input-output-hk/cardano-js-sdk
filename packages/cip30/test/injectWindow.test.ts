import { Wallet } from '../src/Wallet';
import { WindowMaybeWithCardano, injectWindow } from '../src/injectWindow';
import { api, properties, requestAccess } from './testWallet';
import { mocks } from 'mock-browser';
import { ApiError } from '../src/errors';
import browser from 'webextension-polyfill';

describe('injectWindow', () => {
  let wallet: Wallet;
  let window: ReturnType<typeof mocks.MockBrowser>;

  beforeEach(async () => {
    await browser.storage.local.clear();

    wallet = new Wallet(properties, api, requestAccess);
    window = mocks.MockBrowser.createWindow();
  });

  it('creates the cardano scope when not exists, and injects the wallet public API into it', async () => {
    expect(window.cardano).not.toBeDefined();
    injectWindow(window, wallet);
    expect(window.cardano).toBeDefined();
    expect(window.cardano[properties.name].name).toBe(properties.name);
    expect(window.cardano[properties.name].apiVersion).toBe(properties.apiVersion);
    expect(window.cardano[properties.name].icon).toBe(properties.icon);
    expect(await window.cardano[properties.name].isEnabled(window.location.hostname)).toBe(false);
    await window.cardano[properties.name].enable(window.location.hostname);
    expect(await window.cardano[properties.name].isEnabled(window.location.hostname)).toBe(true);
  });

  describe('whitelisting with 2 dapps', () => {
    const firstHostname = 'hostname1';
    const secondHostname = 'hostname2';
    beforeEach(async () => {
      await browser.storage.local.clear();
    });

    test('Both allowed but not remembered', async () => {
      injectWindow(window, wallet);

      await window.cardano[properties.name].enable(firstHostname);
      await window.cardano[properties.name].enable(secondHostname);

      expect(await window.cardano[properties.name].isEnabled(firstHostname)).toBe(true);
      expect(await window.cardano[properties.name].isEnabled(secondHostname)).toBe(true);

      window = mocks.MockBrowser.createWindow();
      // re-inject window
      const newWallet = new Wallet(properties, api, requestAccess);
      injectWindow(window, newWallet);

      expect(await window.cardano[properties.name].isEnabled(firstHostname)).toBe(false);
      expect(await window.cardano[properties.name].isEnabled(secondHostname)).toBe(false);
    });

    test('Both allowed, one remembered', async () => {
      injectWindow(window, wallet);

      await window.cardano[properties.name].enable(firstHostname, true);
      await window.cardano[properties.name].enable(secondHostname);

      expect(await window.cardano[properties.name].isEnabled(firstHostname)).toBe(true);
      expect(await window.cardano[properties.name].isEnabled(secondHostname)).toBe(true);

      window = mocks.MockBrowser.createWindow();
      // re-inject window
      const newWallet = new Wallet(properties, api, requestAccess);
      injectWindow(window, newWallet);

      expect(await window.cardano[properties.name].isEnabled(firstHostname)).toBe(true);
      expect(await window.cardano[properties.name].isEnabled(secondHostname)).toBe(false);
    });

    test('One allowed, one disallowed', async () => {
      const allowAccess = jest.fn().mockReturnValueOnce(true).mockReturnValueOnce(false);
      const nextWallet = new Wallet(properties, api, allowAccess);

      injectWindow(window, nextWallet);

      await window.cardano[properties.name].enable(firstHostname);
      await expect(window.cardano[properties.name].enable(secondHostname)).rejects.toThrow(ApiError);
      expect(await window.cardano[properties.name].isEnabled(firstHostname)).toBe(true);
    });
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
      expect(window.cardano).toBeDefined();
      injectWindow(window, wallet);
      expect(window.cardano[properties.name].name).toBe(properties.name);
      expect(window.cardano[properties.name].apiVersion).toBe(properties.apiVersion);
      expect(window.cardano[properties.name].icon).toBe(properties.icon);
      expect(Object.keys(window.cardano[properties.name])).toEqual([
        'apiVersion',
        'enable',
        'icon',
        'isEnabled',
        'name'
      ]);
      expect(window.cardano['another-obj']).toBe(anotherObj);
    });
  });
});
