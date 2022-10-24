/* eslint-disable max-len */
import { Cardano } from '@cardano-sdk/core';
import { healthCheckResponseWithState } from '../util';
import { logger } from '@cardano-sdk/util-dev';
import { utxoHttpProvider } from '../../src';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

const config = { baseUrl: 'http://some-hostname:3000/utxo', logger };

describe('utxoHttpProvider', () => {
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
  describe('healtCheck', () => {
    it('is not ok if cannot connect', async () => {
      const provider = utxoHttpProvider(config);
      await expect(provider.healthCheck()).resolves.toEqual({ ok: false });
    });
    describe('mocked', () => {
      it('is ok if 200 response body is { ok: true, localNode }', async () => {
        axiosMock.onPost().replyOnce(200, healthCheckResponseWithState);
        const provider = utxoHttpProvider(config);
        await expect(provider.healthCheck()).resolves.toEqual(healthCheckResponseWithState);
      });

      it('is not ok if 200 response body is { ok: false }', async () => {
        axiosMock.onPost().replyOnce(200, { ok: false });
        const provider = utxoHttpProvider(config);
        await expect(provider.healthCheck()).resolves.toEqual({ ok: false });
      });
    });
  });
  describe('utxoByAddresses', () => {
    test('utxoByAddresses doesnt throw', async () => {
      axiosMock.onPost().replyOnce(200, []);
      const provider = utxoHttpProvider(config);
      await expect(
        provider.utxoByAddresses({
          addresses: [
            Cardano.Address(
              'addr_test1qretqkqqvc4dax3482tpjdazrfl8exey274m3mzch3dv8lu476aeq3kd8q8splpsswcfmv4y370e8r76rc8lnnhte49qqyjmtc'
            )
          ]
        })
      ).resolves.toEqual([]);
    });
  });
});
