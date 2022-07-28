/* eslint-disable max-len */
import { INFO, createLogger } from 'bunyan';
import { networkInfoHttpProvider } from '../../src';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

const config = {
  baseUrl: 'http://some-hostname:3000/network',
  logger: createLogger({ level: INFO, name: 'unit tests' })
};

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
    const provider = networkInfoHttpProvider(config);
    await expect(provider.stake()).resolves.toEqual({});
  });

  test('lovelace  does not throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = networkInfoHttpProvider(config);
    await expect(provider.lovelaceSupply()).resolves.toEqual({});
  });

  test('timeSettings does not throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = networkInfoHttpProvider(config);
    await expect(provider.timeSettings()).resolves.toEqual({});
  });

  test('ledgerTip does not throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = networkInfoHttpProvider(config);
    await expect(provider.ledgerTip()).resolves.toEqual({});
  });

  test('genesisParameters does not throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = networkInfoHttpProvider(config);
    await expect(provider.genesisParameters()).resolves.toEqual({});
  });

  test('currentWalletProtocolParameters does not throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = networkInfoHttpProvider(config);
    await expect(provider.currentWalletProtocolParameters()).resolves.toEqual({});
  });
});
