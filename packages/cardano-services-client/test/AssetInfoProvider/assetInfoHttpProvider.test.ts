import { Cardano } from '@cardano-sdk/core';
import { assetInfoHttpProvider } from '../../src';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

const url = 'http://some-hostname:3000/asset';

describe('assetInfoHttpProvider', () => {
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

  describe('getAsset', () => {
    test('getAsset doesnt throw', async () => {
      axiosMock.onPost().replyOnce(200, {});
      const provider = assetInfoHttpProvider(url);
      await expect(
        provider.getAsset(Cardano.AssetId('f43a62fdc3965df486de8a0d32fe800963589c41b38946602a0dc53541474958'))
      ).resolves.toEqual({});
    });
  });
});
