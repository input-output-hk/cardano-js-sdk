import { Asset, Cardano, ProviderError } from '@cardano-sdk/core';
import { CardanoTokenRegistry } from '../../src/Asset';
import { InMemoryCache, Key } from '../../src/InMemoryCache';
import { createServer } from 'http';
import { dummyLogger } from 'ts-log';
import { getRandomPort } from 'get-port-please';
import { testLogger } from '../../../rabbitmq/test/utils';

const mockTokenRegistry = async (handler: () => { body: unknown; code?: number }) => {
  const port = await getRandomPort();
  const server = createServer((_req, res) => {
    const { body, code } = handler();
    res.statusCode = code || 200;
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify(body));
  });

  let resolver: () => void = jest.fn();
  let rejecter: (reason: unknown) => void = jest.fn();

  const closePromise = new Promise<void>((resolve, reject) => {
    resolver = resolve;
    rejecter = reject;
  });

  server.listen(port, 'localhost');
  server.on('error', rejecter);

  return {
    closeMock: () => {
      server.close((error) => (error ? rejecter(error) : resolver()));
      return closePromise;
    },
    tokenMetadataServerUrl: `http://localhost:${port}`
  };
};

describe('CardanoTokenRegistry', () => {
  const invalidAssetId = Cardano.AssetId('0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef');
  const validAssetId = Cardano.AssetId('f43a62fdc3965df486de8a0d32fe800963589c41b38946602a0dc53541474958');

  describe('return value', () => {
    const tokenRegistry = new CardanoTokenRegistry({ logger: dummyLogger });

    afterAll(() => tokenRegistry.shutdown());

    it('returns null for non-existent AssetId', async () => {
      expect(await tokenRegistry.getTokenMetadata([invalidAssetId])).toEqual([null]);
    });

    it('returns metadata when subject exists', async () => {
      const [metadata] = await tokenRegistry.getTokenMetadata([validAssetId]);

      expect(metadata).not.toBeNull();

      const { icon, ...rest } = metadata!;
      const result: Asset.TokenMetadata = {
        decimals: 8,
        // eslint-disable-next-line max-len
        desc: "SingularityNET lets anyone - create, share, and monetize AI services at scale. SingularityNET is the world's first decentralized AI network",
        name: 'SingularityNet AGIX Token',
        ticker: 'AGIX',
        url: 'https://singularitynet.io/'
      };

      // We do not check the entire icon value as it is a long long string
      expect(icon).toBeDefined();
      expect(rest).toEqual(result);
    });

    it('correctly returns null or metadata for request with good and bad assetIds', async () => {
      const firstResult = await tokenRegistry.getTokenMetadata([invalidAssetId, validAssetId]);
      const secondResult = await tokenRegistry.getTokenMetadata([validAssetId, invalidAssetId]);

      expect(firstResult[0]).toBeNull();
      expect(firstResult[1]).not.toBeNull();
      expect(secondResult[0]).not.toBeNull();
      expect(secondResult[1]).toBeNull();
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

    const tokenRegistry = new CardanoTokenRegistry({ cache: new TestInMemoryCache(1), logger: dummyLogger });

    afterAll(() => tokenRegistry.shutdown());

    it('metadata are cached', async () => {
      const [firstResult] = await tokenRegistry.getTokenMetadata([validAssetId]);
      const [secondResult] = await tokenRegistry.getTokenMetadata([validAssetId]);

      expect(gotValues[0]).toBeUndefined();
      expect(gotValues[1]).toEqual(firstResult);
      expect(firstResult).toEqual(secondResult);
    });
  });

  describe('error cases are correctly logged', () => {
    let closeMock: () => Promise<void> = jest.fn();
    let tokenMetadataServerUrl: string;

    beforeEach(() => (closeMock = jest.fn()));

    afterEach(async () => await closeMock());

    it('null record', async () => {
      const logger = testLogger();
      ({ closeMock, tokenMetadataServerUrl } = await mockTokenRegistry(() => ({ body: { subjects: [null] } })));
      const tokenRegistry = new CardanoTokenRegistry({ logger }, { tokenMetadataServerUrl });

      await expect(tokenRegistry.getTokenMetadata([validAssetId])).rejects.toThrow(ProviderError);
    });

    it('record without the subject property', async () => {
      const logger = testLogger();
      const record = { test: 'test' };
      ({ closeMock, tokenMetadataServerUrl } = await mockTokenRegistry(() => ({ body: { subjects: [record] } })));
      const tokenRegistry = new CardanoTokenRegistry({ logger }, { tokenMetadataServerUrl });

      await expect(tokenRegistry.getTokenMetadata([validAssetId])).rejects.toThrow(ProviderError);
    });

    it('internal server error', async () => {
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
      const logger = testLogger();
      ({ closeMock, tokenMetadataServerUrl } = await mockTokenRegistry(record));
      const tokenRegistry = new CardanoTokenRegistry({ logger }, { tokenMetadataServerUrl });

      const result = await tokenRegistry.getTokenMetadata([invalidAssetId, validAssetId]);

      await expect(tokenRegistry.getTokenMetadata([invalidAssetId, validAssetId])).rejects.toThrow(ProviderError);

      expect(result[0]).toBeNull();
      expect(result[1]).toEqual({ name: 'test' });
    });
  });
});
