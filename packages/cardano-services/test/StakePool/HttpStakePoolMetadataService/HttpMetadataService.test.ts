/* eslint-disable prefer-const */
/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import { DataMocks } from '../../data-mocks/index.js';
import { ExtMetadataFormat } from '../../../src/StakePool/types.js';
import {
  StakePoolMetadataServiceError,
  StakePoolMetadataServiceFailure,
  createHttpStakePoolMetadataService
} from '../../../src/index.js';
import { adaPoolsExtMetadataMock, cip6ExtMetadataMock, mainExtMetadataMock, stakePoolMetadata } from './mocks.js';
import { createGenericMockServer, logger } from '@cardano-sdk/util-dev';
import url from 'url';
import type { Cardano } from '@cardano-sdk/core';
import type { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import type { IncomingMessage } from 'http';

const UNFETCHABLE = 'http://some_url/unfetchable';
const INVALID_KEY = 'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a';

export const mockPoolExtMetadataServer = createGenericMockServer((handler) => async (req, res) => {
  const result = await handler(req);

  res.setHeader('Content-Type', 'application/json');

  if (result.body) {
    res.statusCode = result.code || 200;
    return res.end(JSON.stringify(result.body));
  }

  const reqUrl = url.parse(req.url!).pathname;

  switch (reqUrl) {
    case `/${ExtMetadataFormat.AdaPools}`: {
      return res.end(JSON.stringify(adaPoolsExtMetadataMock));
    }
    case `/${ExtMetadataFormat.CIP6}`: {
      return res.end(JSON.stringify(cip6ExtMetadataMock));
    }
    // No default
  }

  return res.end(JSON.stringify(adaPoolsExtMetadataMock));
});

describe('StakePoolMetadataService', () => {
  let closeMock: () => Promise<void> = jest.fn();
  let serverUrl = '';
  const metadataService = createHttpStakePoolMetadataService(logger);

  afterEach(async () => {
    await closeMock();
  });

  const innerError500 = 'AxiosError: Request failed with status code 500';
  const innerError404 = 'AxiosError: Request failed with status code 404';

  describe('getStakePoolMetadata', () => {
    it('fetch stake pool JSON metadata without extended data', async () => {
      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(async () => ({
        body: mainExtMetadataMock(),
        code: 200
      })));

      const result = await metadataService.getStakePoolMetadata(
        'da21f08d630cdebf39a808bace2a04eea5c2151e45d5de51fdfe8f485a5d7726' as Hash32ByteBase16,
        `${serverUrl}/metadata`
      );

      expect(result).toEqual(mainExtMetadataMock());
    });

    it('fetch stake pool JSON metadata and extended metadata', async () => {
      let metadata: any;

      // First fetch returns the metadata, second fetch return the extended metadata.
      let alreadyCalled = false;
      const handler = async () => {
        if (alreadyCalled) return { body: adaPoolsExtMetadataMock, code: 200 };
        alreadyCalled = true;

        return {
          body: metadata,
          code: 200
        };
      };

      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(handler));
      metadata = { ...stakePoolMetadata, extended: `${serverUrl}/extendedMetadata` };

      // Since the extended metadata URL will change each run and its part of the metadata, we must
      // recalculate metadata the hash.
      const metadataHash = Crypto.blake2b(Crypto.blake2b.BYTES)
        .update(Buffer.from(JSON.stringify(metadata), 'ascii'))
        .digest('hex');

      const resultMetadata = await metadataService.getStakePoolMetadata(
        metadataHash as Hash32ByteBase16,
        `${serverUrl}/metadata`
      );

      expect(resultMetadata).toEqual(metadata);

      const resultExtendedMetadata = await metadataService.getValidateStakePoolExtendedMetadata(
        resultMetadata as Cardano.StakePoolMetadata
      );

      expect(resultExtendedMetadata).toEqual(DataMocks.Pool.adaPoolExtendedMetadata);
    });

    it('returns StakePoolMetadataServiceError with FailedToFetchMetadata error code when it gets resource not found server error', async () => {
      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(async () => ({ body: {}, code: 500 })));

      const result = await metadataService.getStakePoolMetadata(
        '4781fffc4cc4a0d6074ae905869e8596f13246b79888af5a8d9580d3a372729a' as Hash32ByteBase16,
        serverUrl
      );

      expect(result).toEqual(
        new StakePoolMetadataServiceError(
          StakePoolMetadataServiceFailure.FailedToFetchMetadata,
          innerError500,
          `StakePoolMetadataService failed to fetch metadata JSON from ${serverUrl} due to Request failed with status code 500`
        )
      );
    });

    it('returns StakePoolMetadataServiceError with InvalidStakePoolHash error code when the hash doesnt match', async () => {
      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(async () => ({
        body: mainExtMetadataMock,
        code: 200
      })));

      const result = await metadataService.getStakePoolMetadata(
        '0000000000000000000000000000000000000000000000000000000000000000' as Hash32ByteBase16,
        `${serverUrl}/metadata`
      );

      expect(result).toEqual(
        new StakePoolMetadataServiceError(
          StakePoolMetadataServiceFailure.InvalidStakePoolHash,
          null,
          "Invalid stake pool hash. Computed '0e5751c026e543b2e8ab2eb06099daa1d1e5df47778f7787faab45cdf12fe3a8', expected '0000000000000000000000000000000000000000000000000000000000000000'"
        )
      );
    });

    it('returns StakePoolMetadataServiceError with InvalidMetadata error code when metadata has extDataUrl but is missing extSigUrl', async () => {
      const metadata = { ...mainExtMetadataMock(), extDataUrl: UNFETCHABLE };
      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(async () => ({
        body: metadata,
        code: 200
      })));

      const result = await metadataService.getValidateStakePoolExtendedMetadata(metadata);
      expect(result).toEqual(
        new StakePoolMetadataServiceError(
          StakePoolMetadataServiceFailure.InvalidMetadata,
          null,
          'Missing ext signature or public key'
        )
      );
    });

    it('returns StakePoolMetadataServiceError with InvalidMetadata error code when metadata has extDataUrl and extSigUrl but is missing extVkey', async () => {
      const metadata = {
        ...mainExtMetadataMock(),
        extDataUrl: UNFETCHABLE,
        extSigUrl: UNFETCHABLE
      };
      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(async () => ({
        body: metadata,
        code: 200
      })));

      const result = await metadataService.getValidateStakePoolExtendedMetadata(metadata);

      expect(result).toEqual(
        new StakePoolMetadataServiceError(
          StakePoolMetadataServiceFailure.InvalidMetadata,
          null,
          'Missing ext signature or public key'
        )
      );
    });

    it('returns StakePoolMetadataServiceError with FailedToFetchExtendedSignature error code when it cant fetch the signature', async () => {
      let metadata: any;

      const handler = async (req?: IncomingMessage) => {
        if (req?.url === '/cip-6') return { body: cip6ExtMetadataMock, code: 200 };
        if (req?.url === '/metadata') return { body: metadata, code: 200 };

        return { body: 'not found', code: 404 };
      };

      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(handler));

      metadata = {
        ...mainExtMetadataMock,
        extDataUrl: `${serverUrl}/${ExtMetadataFormat.CIP6}`,
        extSigUrl: `${serverUrl}/not/found`,
        extVkey: '00000000000000000000000000000000'
      };

      const result = await metadataService.getValidateStakePoolExtendedMetadata(metadata);

      expect(result).toEqual(
        new StakePoolMetadataServiceError(
          StakePoolMetadataServiceFailure.FailedToFetchExtendedSignature,
          innerError404,
          `StakePoolMetadataService failed to fetch extended signature from ${metadata.extSigUrl} due to connection error`
        )
      );
    });

    it('returns StakePoolMetadataServiceError with InvalidExtendedMetadataSignature error code when the signature is invalid', async () => {
      let metadata: any;

      let numFetch = 0;
      const handler = async () => {
        if (numFetch === 0) {
          ++numFetch;
          return {
            body: metadata,
            code: 200
          };
        } else if (numFetch === 1) {
          ++numFetch;
          return { body: DataMocks.Pool.cip6ExtendedMetadata, code: 200 };
        }

        return {
          body:
            'e5564300c360ac729086e2cc806e828a' +
            '84877f1eb8e5d974d873e06522490155' +
            '5fb8821590a33bacc61e39701cf9b46b' +
            'd25bf5f0595bbe24655141438e7a100b',
          code: 200
        };
      };

      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(handler));

      metadata = {
        ...mainExtMetadataMock,
        extDataUrl: `${serverUrl}/${ExtMetadataFormat.CIP6}`,
        extSigUrl: `${serverUrl}/invalidSignature`,
        extVkey: INVALID_KEY
      };

      const metadataHash = Crypto.blake2b(Crypto.blake2b.BYTES)
        .update(Buffer.from(JSON.stringify(metadata), 'ascii'))
        .digest('hex');

      const metadataResult = await metadataService.getStakePoolMetadata(
        metadataHash as Hash32ByteBase16,
        `${serverUrl}/metadata`
      );

      const result2 = await metadataService.getValidateStakePoolExtendedMetadata(
        metadataResult as Cardano.StakePoolMetadata
      );

      expect(result2).toEqual(
        new StakePoolMetadataServiceError(
          StakePoolMetadataServiceFailure.InvalidExtendedMetadataSignature,
          null,
          'Invalid extended metadata signature'
        )
      );
    });
  });

  describe('getStakePoolExtendedMetadata', () => {
    it('returns ada pools format when extended key is present in the metadata', async () => {
      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(async () => ({})));

      const extMetadata: Cardano.StakePoolMetadata = {
        ...mainExtMetadataMock(),
        extended: `${serverUrl}/${ExtMetadataFormat.AdaPools}`
      };
      const result = await metadataService.getStakePoolExtendedMetadata(extMetadata);

      expect(result).not.toBeNull();
      expect(result).toMatchShapeOf(DataMocks.Pool.adaPoolExtendedMetadata);
    });

    it('returns CIP-6 format when extDataUrl is present in the metadata', async () => {
      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(async () => ({})));

      const extMetadata: Cardano.StakePoolMetadata = {
        ...mainExtMetadataMock(),
        extDataUrl: `${serverUrl}/${ExtMetadataFormat.CIP6}`
      };
      const result = await metadataService.getStakePoolExtendedMetadata(extMetadata);

      expect(result).not.toBeNull();
      expect(result).toMatchShapeOf(DataMocks.Pool.cip6ExtendedMetadata);
    });

    it('returns CIP-6 format with priority when the metadata including both extended properties', async () => {
      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(async () => ({})));

      const extMetadata: Cardano.StakePoolMetadata = {
        ...mainExtMetadataMock(),
        extDataUrl: `${serverUrl}/${ExtMetadataFormat.CIP6}`,
        extended: `${serverUrl}/${ExtMetadataFormat.AdaPools}`
      };
      const result = await metadataService.getStakePoolExtendedMetadata(extMetadata);

      expect(result).not.toBeNull();
      expect(result?.serial).toBeDefined();
    });

    it('throws StakePoolMetadataServiceError with InvalidExtendedMetadataFormat error code when it gets an invalid CIP-6 response format', async () => {
      const invalidCip6ResponseFormat = { pool1: { ...cip6ExtMetadataMock.pool }, serial: 12_345 };
      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(async () => ({ body: invalidCip6ResponseFormat })));

      const extMetadata: Cardano.StakePoolMetadata = {
        ...mainExtMetadataMock(),
        extDataUrl: `${serverUrl}/${ExtMetadataFormat.CIP6}`
      };

      await expect(metadataService.getStakePoolExtendedMetadata(extMetadata)).rejects.toThrow(
        new StakePoolMetadataServiceError(
          StakePoolMetadataServiceFailure.InvalidExtendedMetadataFormat,
          'instance requires property "pool"',
          'Extended metadata JSON format validation failed against the corresponding schema for correctness'
        )
      );
    });

    it('throws StakePoolMetadataServiceError with InvalidExtendedMetadataFormat error code when it gets an invalid AP response format', async () => {
      const invalidAdaPoolsResponseFormat = { info1: { ...adaPoolsExtMetadataMock.info } };
      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(async () => ({
        body: invalidAdaPoolsResponseFormat
      })));

      const extMetadata: Cardano.StakePoolMetadata = {
        ...mainExtMetadataMock(),
        extended: `${serverUrl}/${ExtMetadataFormat.AdaPools}`
      };

      await expect(metadataService.getStakePoolExtendedMetadata(extMetadata)).rejects.toThrow(
        new StakePoolMetadataServiceError(
          StakePoolMetadataServiceFailure.InvalidExtendedMetadataFormat,
          'instance requires property "info"',
          'Extended metadata JSON format validation failed against the corresponding schema for correctness'
        )
      );
    });

    it('throws StakePoolMetadataServiceError with FailedToFetchExtendedMetadata error code when it gets internal server error response', async () => {
      let alreadyCalled = false;
      const handler = async () => {
        if (alreadyCalled) return { body: {}, code: 500 };
        alreadyCalled = true;

        return {
          body: cip6ExtMetadataMock
        };
      };

      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(handler));

      const extMetadata: Cardano.StakePoolMetadata = {
        ...mainExtMetadataMock(),
        extDataUrl: `${serverUrl}/${ExtMetadataFormat.CIP6}`
      };

      const result = await metadataService.getStakePoolExtendedMetadata(extMetadata);
      expect(result).toBeDefined();

      await expect(metadataService.getStakePoolExtendedMetadata(extMetadata)).rejects.toThrow(
        new StakePoolMetadataServiceError(
          StakePoolMetadataServiceFailure.FailedToFetchExtendedMetadata,
          innerError500,
          `StakePoolMetadataService failed to fetch extended metadata from ${serverUrl}/${ExtMetadataFormat.CIP6} due to connection error`
        )
      );
    });

    it('throws StakePoolMetadataServiceError with FailedToFetchExtendedMetadata error code when it gets resource not found server error', async () => {
      let alreadyCalled = false;
      const handler = async () => {
        if (alreadyCalled) return { body: {}, code: 404 };
        alreadyCalled = true;

        return {
          body: cip6ExtMetadataMock
        };
      };

      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(handler));

      const extMetadata: Cardano.StakePoolMetadata = {
        ...mainExtMetadataMock(),
        extDataUrl: `${serverUrl}/${ExtMetadataFormat.CIP6}`
      };

      const result = await metadataService.getStakePoolExtendedMetadata(extMetadata);
      expect(result).toBeDefined();

      await expect(metadataService.getStakePoolExtendedMetadata(extMetadata)).rejects.toThrow(
        new StakePoolMetadataServiceError(
          StakePoolMetadataServiceFailure.FailedToFetchExtendedMetadata,
          innerError404,
          `StakePoolMetadataService failed to fetch extended metadata from ${serverUrl}/${ExtMetadataFormat.CIP6} due to resource not found`
        )
      );
    });
  });
});
