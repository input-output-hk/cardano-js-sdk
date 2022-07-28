/* eslint-disable sonarjs/no-duplicate-string */
import { INFO, createLogger } from 'bunyan';
import { ProviderFailure } from '@cardano-sdk/core';
import { axiosError } from '../util';
import { chainHistoryHttpProvider } from '../../src';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

const config = {
  baseUrl: 'http://some-hostname:3000/history',
  logger: createLogger({ level: INFO, name: 'unit tests' })
};

describe('chainHistoryProvider', () => {
  describe('healthCheck', () => {
    it('is not ok if cannot connect', async () => {
      const provider = chainHistoryHttpProvider(config);
      await expect(provider.healthCheck()).resolves.toEqual({ ok: false });
    });
  });
  describe('mocked', () => {
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
    describe('healthCheck', () => {
      it('is ok if 200 response body is { ok: true }', async () => {
        axiosMock.onPost().replyOnce(200, { ok: true });
        const provider = chainHistoryHttpProvider(config);
        await expect(provider.healthCheck()).resolves.toEqual({ ok: true });
      });

      it('is not ok if 200 response body is { ok: false }', async () => {
        axiosMock.onPost().replyOnce(200, { ok: false });
        const provider = chainHistoryHttpProvider(config);
        await expect(provider.healthCheck()).resolves.toEqual({ ok: false });
      });
    });

    describe('blocks', () => {
      it('resolves if successful', async () => {
        axiosMock.onPost().replyOnce(200, []);
        const provider = chainHistoryHttpProvider(config);
        await expect(provider.blocksByHashes([])).resolves.not.toThrow();
      });

      describe('errors', () => {
        it('maps unknown errors to ProviderFailure', async () => {
          axiosMock.onPost().replyOnce(() => {
            throw axiosError();
          });
          const provider = chainHistoryHttpProvider(config);
          await expect(provider.blocksByHashes([])).rejects.toThrow(ProviderFailure.Unknown);
        });
      });
    });

    describe('transactionsByHashes', () => {
      it('resolves if successful', async () => {
        axiosMock.onPost().replyOnce(200, []);
        const provider = chainHistoryHttpProvider(config);
        await expect(provider.transactionsByHashes([])).resolves.not.toThrow();
      });

      describe('errors', () => {
        it('maps unknown errors to ProviderFailure', async () => {
          axiosMock.onPost().replyOnce(() => {
            throw axiosError();
          });
          const provider = chainHistoryHttpProvider(config);
          await expect(provider.transactionsByHashes([])).rejects.toThrow(ProviderFailure.Unknown);
        });
      });
    });

    describe('transactionsByAddresses', () => {
      it('resolves if successful', async () => {
        axiosMock.onPost().replyOnce(200, []);
        const provider = chainHistoryHttpProvider(config);
        await expect(provider.transactionsByAddresses({ addresses: [] })).resolves.not.toThrow();
      });

      describe('errors', () => {
        it('maps unknown errors to ProviderFailure', async () => {
          axiosMock.onPost().replyOnce(() => {
            throw axiosError();
          });
          const provider = chainHistoryHttpProvider(config);
          await expect(provider.transactionsByAddresses({ addresses: [] })).rejects.toThrow(ProviderFailure.Unknown);
        });
      });
    });
  });
});
