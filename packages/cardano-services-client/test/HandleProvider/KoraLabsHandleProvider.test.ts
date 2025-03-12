/* eslint-disable no-magic-numbers */
/* eslint-disable camelcase */
import { Cardano, ProviderError } from '@cardano-sdk/core';
import { KoraLabsHandleProvider } from '../../src';
import {
  getAliceHandleAPIResponse,
  getAliceHandleProviderResponse,
  getBobHandleAPIResponse,
  getBobHandleProviderResponse
} from '../util';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

const config = {
  policyId: Cardano.PolicyId('50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb'),
  serverUrl: 'http://some-hostname:3000'
};

describe('KoraLabsHandleProvider', () => {
  let axiosMock: MockAdapter;
  let provider: KoraLabsHandleProvider;

  beforeAll(() => {
    axiosMock = new MockAdapter(axios);
    provider = new KoraLabsHandleProvider(config);
  });

  afterEach(() => {
    axiosMock.reset();
  });

  afterAll(() => {
    axiosMock.restore();
  });

  describe('resolveHandles', () => {
    test('HandleProvider should resolve a single handle', async () => {
      axiosMock.onGet().replyOnce(200, getAliceHandleAPIResponse);
      const args = {
        handles: ['alice']
      };
      await expect(provider.resolveHandles(args)).resolves.toEqual([getAliceHandleProviderResponse]);
    });

    test('HandleProvider should resolve multiple handles', async () => {
      axiosMock.onGet().replyOnce(200, getAliceHandleAPIResponse).onGet().replyOnce(200, getBobHandleAPIResponse);
      const args = {
        handles: ['alice', 'bob']
      };
      await expect(provider.resolveHandles(args)).resolves.toEqual([
        getAliceHandleProviderResponse,
        getBobHandleProviderResponse
      ]);
    });
  });

  describe('error checks', () => {
    test('HandleProvider should throw ProviderError with ConnectionFailure on request error', async () => {
      axiosMock.onGet('/handles/alice').networkError();
      const args = { handles: ['alice'] };
      await expect(provider.resolveHandles(args)).rejects.toThrowError(ProviderError);
    });
    test('HandleProvider should return null for 404 response from API', async () => {
      axiosMock.onGet('/handles/alice').reply(404);
      const args = { handles: ['alice'] };
      await expect(provider.resolveHandles(args)).resolves.toEqual([null]);
    });
    test('HandleProvider should throw ProviderError with Unhealthy on other Axios error', async () => {
      axiosMock.onGet('/handles/bob').reply(500);
      const args = { handles: ['bob'] };
      await expect(provider.resolveHandles(args)).rejects.toThrowError(ProviderError);
    });
    test('HandleProvider should throw ProviderError', async () => {
      axiosMock.onGet('/handles/bob').networkError();
      const args = { handles: ['bob'] };
      await expect(provider.resolveHandles(args)).rejects.toThrowError(ProviderError);
    });
    test('HandleProvider should throw ProviderError with Unknown, unable to resolve handle', async () => {
      axiosMock.onGet().replyOnce(304, getAliceHandleAPIResponse);
      const args = { handles: ['bob'] };
      await expect(provider.resolveHandles(args)).rejects.toThrowError(ProviderError);
    });
  });

  describe('health checks', () => {
    test('HandleProvider should get ok health check', async () => {
      axiosMock.onGet().replyOnce(200, {});
      const result = await provider.healthCheck();
      expect(result.ok).toEqual(true);
    });

    test('HandleProvider should get not ok health check', async () => {
      const providerWithBadConfig = new KoraLabsHandleProvider({
        policyId: Cardano.PolicyId('50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb'),
        serverUrl: ''
      });
      const result = await providerWithBadConfig.healthCheck();
      expect(result.ok).toEqual(false);
    });
  });

  describe('get policy ids', () => {
    test('HandleProvider should get handle policy ids', async () => {
      const policyIds = await provider.getPolicyIds();

      expect(policyIds.length).toEqual(1);
      expect(policyIds).toEqual([config.policyId]);
    });
  });
});
