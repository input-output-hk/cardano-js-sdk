import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { CardanoTokenRegistry, toCoreTokenMetadata } from '../../src/Asset';
import { InMemoryCache, Key } from '../../src/InMemoryCache';
import { IncomingMessage, createServer } from 'http';
import { dummyLogger } from 'ts-log';
import { getRandomPort } from 'get-port-please';
import { logger } from '@cardano-sdk/util-dev';

const mockResults: Record<string, unknown> = {
  '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65': {
    description: { value: 'This is my first NFT of the macaron cake' },
    name: { value: 'macaron cake token' },
    subject: '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65'
  },
  f43a62fdc3965df486de8a0d32fe800963589c41b38946602a0dc53541474958: {
    decimals: { value: 8 },
    description: { value: 'SingularityNET' },
    logo: { value: 'testLogo' },
    name: { value: 'SingularityNet AGIX Token' },
    subject: 'f43a62fdc3965df486de8a0d32fe800963589c41b38946602a0dc53541474958',
    ticker: { value: 'AGIX' },
    url: { value: 'https://singularitynet.io/' }
  }
};

export const mockTokenRegistry = (handler: (req?: IncomingMessage) => { body?: unknown; code?: number } = () => ({})) =>
  // eslint-disable-next-line func-call-spacing
  new Promise<{ closeMock: () => Promise<void>; tokenMetadataServerUrl: string }>(async (resolve, reject) => {
    try {
      const port = await getRandomPort();
      const server = createServer(async (req, res) => {
        const { body, code } = handler(req);

        res.setHeader('Content-Type', 'application/json');

        if (body) {
          res.statusCode = code || 200;

          return res.end(JSON.stringify(body));
        }

        const buffers: Buffer[] = [];
        for await (const chunk of req) buffers.push(chunk);
        const data = Buffer.concat(buffers).toString();
        const subjects: unknown[] = [];

        for (const subject of JSON.parse(data).subjects) {
          const mockResult = mockResults[subject as string];

          if (mockResult) subjects.push(mockResult);
        }

        return res.end(JSON.stringify({ subjects }));
      });

      let resolver: () => void = jest.fn();
      let rejecter: (reason: unknown) => void = jest.fn();

      // eslint-disable-next-line @typescript-eslint/no-shadow
      const closePromise = new Promise<void>((resolve, reject) => {
        resolver = resolve;
        rejecter = reject;
      });

      server.on('error', rejecter);
      server.listen(port, 'localhost', () =>
        resolve({
          closeMock: () => {
            server.close((error) => (error ? rejecter(error) : resolver()));
            return closePromise;
          },
          tokenMetadataServerUrl: `http://localhost:${port}`
        })
      );
    } catch (error) {
      reject(error);
    }
  });

const testDescription = 'test description';
const testName = 'test name';

describe('CardanoTokenRegistry', () => {
  const invalidAssetId = Cardano.AssetId('0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef');
  const validAssetId = Cardano.AssetId('f43a62fdc3965df486de8a0d32fe800963589c41b38946602a0dc53541474958');

  describe('toCoreTokenMetadata', () => {
    it('complete attributes', () =>
      expect(
        toCoreTokenMetadata({
          decimals: { value: 23 },
          description: { value: testDescription },
          logo: { value: 'test logo' },
          name: { value: testName },
          subject: 'test',
          ticker: { value: 'test ticker' },
          url: { value: 'test url' }
        })
      ).toStrictEqual({
        decimals: 23,
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
          subject: 'test'
        })
      ).toStrictEqual({ desc: testDescription, name: testName }));
  });

  describe('return value', () => {
    let closeMock: () => Promise<void> = jest.fn();
    let tokenMetadataServerUrl = '';
    let tokenRegistry = new CardanoTokenRegistry({ logger: dummyLogger });

    beforeAll(async () => {
      ({ closeMock, tokenMetadataServerUrl } = await mockTokenRegistry(() => ({})));
      tokenRegistry = new CardanoTokenRegistry({ logger: dummyLogger }, { tokenMetadataServerUrl });
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
    let tokenMetadataServerUrl = '';
    let tokenRegistry = new CardanoTokenRegistry({ logger: dummyLogger });

    beforeAll(async () => {
      ({ closeMock, tokenMetadataServerUrl } = await mockTokenRegistry(() => ({})));
      tokenRegistry = new CardanoTokenRegistry(
        { cache: new TestInMemoryCache(60), logger: dummyLogger },
        { tokenMetadataServerUrl }
      );
    });

    afterAll(async () => {
      tokenRegistry.shutdown();
      await closeMock();
    });

    it('metadata are cached', async () => {
      const firstResult = await tokenRegistry.getTokenMetadata([validAssetId]);
      const secondResult = await tokenRegistry.getTokenMetadata([validAssetId]);

      expect(gotValues[0]).toBeUndefined();
      expect(gotValues[1]).toEqual(firstResult![0]);
      expect(firstResult![0]).toEqual(secondResult![0]);
    });
  });

  describe('error cases are correctly handled', () => {
    let closeMock: () => Promise<void> = jest.fn();
    let tokenMetadataServerUrl: string;

    beforeEach(() => (closeMock = jest.fn()));

    afterEach(async () => await closeMock());

    it('null record', async () => {
      ({ closeMock, tokenMetadataServerUrl } = await mockTokenRegistry(() => ({ body: { subjects: [null] } })));
      const tokenRegistry = new CardanoTokenRegistry({ logger }, { tokenMetadataServerUrl });

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
      ({ closeMock, tokenMetadataServerUrl } = await mockTokenRegistry(() => ({ body: { subjects: [record] } })));
      const tokenRegistry = new CardanoTokenRegistry({ logger }, { tokenMetadataServerUrl });

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
      const succeededMetadata = { name: 'test' };

      let alreadyCalled = false;
      const record = () => {
        if (alreadyCalled) return { body: {}, code: 500 };

        alreadyCalled = true;

        return {
          body: {
            subjects: [
              { name: { value: 'test' }, subject: 'f43a62fdc3965df486de8a0d32fe800963589c41b38946602a0dc53541474958' }
            ]
          }
        };
      };

      ({ closeMock, tokenMetadataServerUrl } = await mockTokenRegistry(record));
      const tokenRegistry = new CardanoTokenRegistry({ logger }, { tokenMetadataServerUrl });
      const firstSucceedResult = await tokenRegistry.getTokenMetadata([invalidAssetId, validAssetId]);
      expect(firstSucceedResult).toEqual([failedMetadata, succeededMetadata]);

      await expect(tokenRegistry.getTokenMetadata([invalidAssetId, validAssetId])).rejects.toThrow(
        new ProviderError(
          ProviderFailure.ConnectionFailure,
          null,
          'CardanoTokenRegistry failed to fetch asset metadata from the token registry server'
        )
      );
    });
  });
});
