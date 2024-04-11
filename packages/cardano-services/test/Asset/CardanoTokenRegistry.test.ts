/* eslint-disable max-len */
import { Cardano, ProviderError, ProviderFailure, Seconds } from '@cardano-sdk/core';
import { CardanoTokenRegistry, DEFAULT_TOKEN_METADATA_REQUEST_TIMEOUT, toCoreTokenMetadata } from '../../src/Asset';
import { InMemoryCache, Key } from '../../src/InMemoryCache';
import { logger } from '@cardano-sdk/util-dev';
import { mockTokenRegistry } from './fixtures/mocks';
import { sleep } from '../util';

const testDescription = 'test description';
const testName = 'test name';
const testSubject = 'test id';

describe('CardanoTokenRegistry', () => {
  const invalidAssetId = Cardano.AssetId('0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef');
  const validAssetId = Cardano.AssetId('f43a62fdc3965df486de8a0d32fe800963589c41b38946602a0dc53541474958');
  const defaultTimeout = DEFAULT_TOKEN_METADATA_REQUEST_TIMEOUT;

  describe('toCoreTokenMetadata', () => {
    it('complete attributes', () =>
      expect(
        toCoreTokenMetadata({
          decimals: { value: 0 },
          description: { value: testDescription },
          logo: { value: 'test logo' },
          name: { value: testName },
          subject: testSubject,
          ticker: { value: 'test ticker' },
          url: { value: 'test url' }
        })
      ).toStrictEqual({
        assetId: testSubject,
        decimals: 0,
        desc: testDescription,
        icon: 'test logo',
        name: testName,
        ticker: 'test ticker',
        url: 'test url'
      }));

    it('incomplete attributes', () =>
      expect(
        toCoreTokenMetadata({
          description: { value: testDescription },
          name: { value: testName },
          subject: testSubject
        })
      ).toStrictEqual({ assetId: testSubject, desc: testDescription, name: testName }));
  });

  describe('return value', () => {
    let closeMock: () => Promise<void> = jest.fn();
    let serverUrl = '';
    let tokenRegistry = new CardanoTokenRegistry({ logger });

    beforeAll(async () => {
      ({ closeMock, serverUrl } = await mockTokenRegistry(async () => ({})));
      tokenRegistry = new CardanoTokenRegistry({ logger }, { tokenMetadataServerUrl: serverUrl });
    });

    afterAll(async () => {
      tokenRegistry.shutdown();
      await closeMock();
    });

    it('returns null for non-existent AssetId', async () => {
      expect(await tokenRegistry.getTokenMetadata([invalidAssetId])).toEqual([null]);
    });

    it('returns metadata when subject exists', async () => {
      const metadata = await tokenRegistry.getTokenMetadata([validAssetId]);

      expect(metadata![0]).not.toBeNull();

      const result = {
        assetId: validAssetId,
        decimals: 8,
        desc: 'SingularityNET',
        icon: 'testLogo',
        name: 'SingularityNet AGIX Token',
        ticker: 'AGIX',
        url: 'https://singularitynet.io/'
      };

      expect(metadata![0]).toEqual(result);
    });

    it('correctly returns null or metadata for request with good and bad assetIds', async () => {
      const firstResult = await tokenRegistry.getTokenMetadata([invalidAssetId, validAssetId]);
      const secondResult = await tokenRegistry.getTokenMetadata([validAssetId, invalidAssetId]);

      expect(firstResult![0]).toBeNull();
      expect(firstResult![1]).not.toBeNull();
      expect(secondResult![0]).not.toBeNull();
      expect(secondResult![1]).toBeNull();
    });
  });

  describe('cached return value', () => {
    const gotValues: unknown[] = [];

    class TestInMemoryCache extends InMemoryCache {
      public getVal<T>(key: Key): T | undefined {
        const value = super.getVal<T>(key);

        gotValues.push(value);

        return value;
      }
    }

    let closeMock: () => Promise<void> = jest.fn();
    let serverUrl = '';
    let tokenRegistry = new CardanoTokenRegistry({ logger });

    beforeAll(async () => {
      ({ closeMock, serverUrl } = await mockTokenRegistry(async () => ({})));
      tokenRegistry = new CardanoTokenRegistry(
        { cache: new TestInMemoryCache(Seconds(60)), logger },
        { tokenMetadataServerUrl: serverUrl }
      );
    });

    afterAll(async () => {
      tokenRegistry.shutdown();
      await closeMock();
    });

    it('metadata is cached', async () => {
      const firstResult = await tokenRegistry.getTokenMetadata([validAssetId]);
      const secondResult = await tokenRegistry.getTokenMetadata([validAssetId]);

      expect(gotValues[0]).toBeUndefined();
      expect(gotValues[1]).toEqual(firstResult![0]);
      expect(firstResult![0]).toEqual(secondResult![0]);
    });
  });

  describe('error cases are correctly handled', () => {
    let closeMock: () => Promise<void> = jest.fn();
    let serverUrl: string;

    beforeEach(() => (closeMock = jest.fn()));

    afterEach(async () => await closeMock());

    it('null record', async () => {
      ({ closeMock, serverUrl } = await mockTokenRegistry(async () => ({ body: { subjects: [null] } })));
      const tokenRegistry = new CardanoTokenRegistry(
        { logger },
        { tokenMetadataRequestTimeout: defaultTimeout, tokenMetadataServerUrl: serverUrl }
      );

      await expect(tokenRegistry.getTokenMetadata([validAssetId])).rejects.toThrow(
        new ProviderError(
          ProviderFailure.Unknown,
          new TypeError("Cannot destructure property 'subject' of 'record' as it is null."),
          "Cannot destructure property 'subject' of 'record' as it is null. while evaluating metadata record null"
        )
      );
    });

    it('record without the subject property', async () => {
      const record = { test: 'test' };
      ({ closeMock, serverUrl } = await mockTokenRegistry(async () => ({ body: { subjects: [record] } })));
      const tokenRegistry = new CardanoTokenRegistry(
        { logger },
        { tokenMetadataRequestTimeout: defaultTimeout, tokenMetadataServerUrl: serverUrl }
      );

      await expect(tokenRegistry.getTokenMetadata([validAssetId])).rejects.toThrow(
        new ProviderError(
          ProviderFailure.InvalidResponse,
          undefined,
          'Missing \'subject\' property in metadata record {"test":"test"}'
        )
      );
    });

    it('internal server error', async () => {
      const failedMetadata = null;
      const succeededMetadata = { assetId: validAssetId, name: 'test' };
      const innerError = 'AxiosError: Request failed with status code 500';

      let alreadyCalled = false;
      const record = async () => {
        if (alreadyCalled) return { body: {}, code: 500 };

        alreadyCalled = true;

        return {
          body: {
            subjects: [{ name: { value: 'test' }, subject: validAssetId }]
          }
        };
      };

      ({ closeMock, serverUrl } = await mockTokenRegistry(record));
      const tokenRegistry = new CardanoTokenRegistry(
        { logger },
        { tokenMetadataRequestTimeout: defaultTimeout, tokenMetadataServerUrl: serverUrl }
      );
      const firstSucceedResult = await tokenRegistry.getTokenMetadata([invalidAssetId, validAssetId]);
      expect(firstSucceedResult).toEqual([failedMetadata, succeededMetadata]);

      await expect(tokenRegistry.getTokenMetadata([invalidAssetId, validAssetId])).rejects.toThrow(
        new ProviderError(
          ProviderFailure.Unhealthy,
          innerError,
          'CardanoTokenRegistry failed to fetch asset metadata from the token registry server due to: Request failed with status code 500'
        )
      );
    });

    it('timeout server error', async () => {
      const exceededTimeout = defaultTimeout + 1000;
      const innerError = `AxiosError: timeout of ${defaultTimeout}ms exceeded`;
      const record = async () => {
        await sleep(exceededTimeout);

        return {
          body: {
            subjects: [{ name: { value: 'test' }, subject: validAssetId }]
          }
        };
      };

      ({ closeMock, serverUrl } = await mockTokenRegistry(record));
      const tokenRegistry = new CardanoTokenRegistry(
        { logger },
        { tokenMetadataRequestTimeout: defaultTimeout, tokenMetadataServerUrl: serverUrl }
      );

      await expect(tokenRegistry.getTokenMetadata([validAssetId])).rejects.toThrow(
        new ProviderError(
          ProviderFailure.Unhealthy,
          innerError,
          `CardanoTokenRegistry failed to fetch asset metadata from the token registry server due to: timeout of ${defaultTimeout}ms exceeded`
        )
      );
    });
  });
});
