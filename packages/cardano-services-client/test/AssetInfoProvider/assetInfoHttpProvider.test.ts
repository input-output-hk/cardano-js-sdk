import { Cardano } from '@cardano-sdk/core';
import { INFO, createLogger } from 'bunyan';
import { assetInfoHttpProvider } from '../../src';
import MockAdapter from 'axios-mock-adapter';

import axios from 'axios';

const config = {
  baseUrl: 'http://some-hostname:3000/asset',
  logger: createLogger({ level: INFO, name: 'unit tests' })
};

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
        provider.getAsset(Cardano.AssetId('f43a62fdc3965df486de8a0d32fe800963589c41b38946602a0dc53541474958'))
      ).resolves.toEqual({});
    });
  });
});
