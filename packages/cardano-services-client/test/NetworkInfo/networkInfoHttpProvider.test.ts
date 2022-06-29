/* eslint-disable max-len */
import { networkInfoHttpProvider } from '../../src';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

const url = 'http://hostname:3000/network';

describe('networkInfoHttpProvider', () => {
  let axiosMock: MockAdapter;

  beforeAll(() => {
    axiosMock = new MockAdapter(axios);
  });
  afterEach(() => {
    axiosMock.reset();
  });

  afterAll(() => {
    axiosMock.restore();
  });

  test('stake does not throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = networkInfoHttpProvider(url);
    await expect(provider.stake()).resolves.toEqual({});
  });

  test('lovelace  does not throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = networkInfoHttpProvider(url);
    await expect(provider.lovelaceSupply()).resolves.toEqual({});
  });

  test('timeSettings does not throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = networkInfoHttpProvider(url);
    await expect(provider.timeSettings()).resolves.toEqual({});
  });

  test('ledgerTip does not throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = networkInfoHttpProvider(url);
    await expect(provider.ledgerTip()).resolves.toEqual({});
  });

  test('genesisParameters does not throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = networkInfoHttpProvider(url);
    await expect(provider.genesisParameters()).resolves.toEqual({});
  });

  test('currentWalletProtocolParameters does not throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = networkInfoHttpProvider(url);
    await expect(provider.currentWalletProtocolParameters()).resolves.toEqual({});
  });
});
