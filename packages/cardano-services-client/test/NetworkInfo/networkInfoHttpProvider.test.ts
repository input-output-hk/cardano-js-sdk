import { config } from '../util.js';
import { networkInfoHttpProvider } from '../../src/index.js';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

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

  test('eraSummaries does not throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = networkInfoHttpProvider(config);
    await expect(provider.eraSummaries()).resolves.toEqual({});
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

  test('protocolParameters does not throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = networkInfoHttpProvider(config);
    await expect(provider.protocolParameters()).resolves.toEqual({});
  });
});
