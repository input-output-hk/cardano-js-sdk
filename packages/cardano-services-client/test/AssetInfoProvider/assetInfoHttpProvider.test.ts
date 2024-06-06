import { Cardano } from '@cardano-sdk/core';
import { assetInfoHttpProvider } from '../../src/index.js';
import { config } from '../util.js';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

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
    test("getAsset doesn't throw", async () => {
      axiosMock.onPost().replyOnce(200, {});
      const provider = assetInfoHttpProvider(config);
      await expect(
        provider.getAsset({
          assetId: Cardano.AssetId('f43a62fdc3965df486de8a0d32fe800963589c41b38946602a0dc53541474958')
        })
      ).resolves.toEqual({});
    });

    test("getAssets doesn't throw", async () => {
      axiosMock.onPost().replyOnce(200, {});
      const provider = assetInfoHttpProvider(config);
      await expect(
        provider.getAssets({
          assetIds: [Cardano.AssetId('f43a62fdc3965df486de8a0d32fe800963589c41b38946602a0dc53541474958')]
        })
      ).resolves.toEqual({});
    });
  });
});
