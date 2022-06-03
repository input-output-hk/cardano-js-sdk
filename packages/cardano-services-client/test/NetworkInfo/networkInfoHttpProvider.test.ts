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

  describe('networkInfo request', () => {
    test('utxoByAddresses doesnt throw', async () => {
      axiosMock.onPost().replyOnce(200, []);
      const provider = networkInfoHttpProvider(url);
      await expect(provider.networkInfo()).resolves.toEqual([]);
    });
  });
});
