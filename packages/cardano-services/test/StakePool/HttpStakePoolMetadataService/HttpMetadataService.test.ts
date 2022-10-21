/* eslint-disable max-len */
import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { ExtMetadataFormat } from '../../../src/StakePool/types';
import { adaPoolsExtMetadataMock, cip6ExtMetadataMock, mainExtMetadataMock } from './mocks';
import { createGenericMockServer, logger } from '@cardano-sdk/util-dev';
import { createHttpStakePoolExtMetadataService } from '../../../src';
import url from 'url';

export const mockPoolExtMetadataServer = createGenericMockServer((handler) => async (req, res) => {
  const result = handler(req);

  res.setHeader('Content-Type', 'application/json');

  if (result.body) {
    res.statusCode = result.code || 200;
    return res.end(JSON.stringify(result.body));
  }

  const reqUrl = url.parse(req.url!).pathname;

  if (reqUrl === `/${ExtMetadataFormat.AdaPools}`) {
    return res.end(JSON.stringify(adaPoolsExtMetadataMock));
  } else if (reqUrl === `/${ExtMetadataFormat.CIP6}`) {
    return res.end(JSON.stringify(cip6ExtMetadataMock));
  }

  return res.end(JSON.stringify(adaPoolsExtMetadataMock));
});

describe('StakePoolExtMetadataService', () => {
  describe('healthy state', () => {
    let closeMock: () => Promise<void> = jest.fn();
    let serverUrl = '';
    const extendedMetadataService = createHttpStakePoolExtMetadataService(logger);

    beforeAll(async () => {
      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(() => ({})));
    });

    afterAll(async () => {
      await closeMock();
    });

    it('returns ada pools format when extended key is present in the metadata', async () => {
      const extMetadata: Cardano.StakePoolMetadata = {
        ...mainExtMetadataMock(),
        extended: `${serverUrl}/${ExtMetadataFormat.AdaPools}`
      };
      const result = await extendedMetadataService.getStakePoolExtendedMetadata(extMetadata);

      expect(result).not.toBeNull();
      expect(result).toMatchSnapshot();
    });

    it('returns CIP-6 format when extDataUrl is present in the metadata', async () => {
      const extMetadata: Cardano.StakePoolMetadata = {
        ...mainExtMetadataMock(),
        extDataUrl: `${serverUrl}/${ExtMetadataFormat.CIP6}`
      };
      const result = await extendedMetadataService.getStakePoolExtendedMetadata(extMetadata);

      expect(result).not.toBeNull();
      expect(result).toMatchSnapshot();
    });

    it('returns CIP-6 format with priority when the metadata including both extended properties', async () => {
      const extMetadata: Cardano.StakePoolMetadata = {
        ...mainExtMetadataMock(),
        extDataUrl: `${serverUrl}/${ExtMetadataFormat.CIP6}`,
        extended: `${serverUrl}/${ExtMetadataFormat.AdaPools}`
      };
      const result = await extendedMetadataService.getStakePoolExtendedMetadata(extMetadata);

      expect(result).not.toBeNull();
      expect(result?.serial).toBeDefined();
    });
  });

  describe('error cases are correctly handled', () => {
    const extendedMetadataService = createHttpStakePoolExtMetadataService(logger);
    let closeMock: () => Promise<void> = jest.fn();
    let serverUrl: string;

    beforeEach(() => (closeMock = jest.fn()));

    afterEach(async () => await closeMock());

    it('invalid CIP-6 response format', async () => {
      const invalidCip6ResponseFormat = { pool1: { ...cip6ExtMetadataMock.pool }, serial: 12_345 };
      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(() => ({ body: invalidCip6ResponseFormat })));

      const extMetadata: Cardano.StakePoolMetadata = {
        ...mainExtMetadataMock(),
        extDataUrl: `${serverUrl}/${ExtMetadataFormat.CIP6}`
      };

      await expect(extendedMetadataService.getStakePoolExtendedMetadata(extMetadata)).rejects.toThrow(
        new ProviderError(
          ProviderFailure.InvalidResponse,
          'instance requires property "pool"',
          'Extended metadata JSON format validation failed against the corresponding schema for correctness'
        )
      );
    });

    it('invalid AP response format', async () => {
      const invalidAdaPoolsResponseFormat = { info1: { ...adaPoolsExtMetadataMock.info } };
      ({ closeMock, serverUrl } = await mockPoolExtMetadataServer(() => ({ body: invalidAdaPoolsResponseFormat })));

      const extMetadata: Cardano.StakePoolMetadata = {
        ...mainExtMetadataMock(),
        extended: `${serverUrl}/${ExtMetadataFormat.AdaPools}`
      };

      await expect(extendedMetadataService.getStakePoolExtendedMetadata(extMetadata)).rejects.toThrow(
        new ProviderError(
          ProviderFailure.InvalidResponse,
          'instance requires property "info"',
          'Extended metadata JSON format validation failed against the corresponding schema for correctness'
        )
      );
    });

    it('internal server error', async () => {
      let alreadyCalled = false;
      const handler = () => {
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

      const result = await extendedMetadataService.getStakePoolExtendedMetadata(extMetadata);
      expect(result).toBeDefined();

      await expect(extendedMetadataService.getStakePoolExtendedMetadata(extMetadata)).rejects.toThrow(
        new ProviderError(
          ProviderFailure.ConnectionFailure,
          null,
          `StakePoolExtMetadataService failed to fetch extended metadata from ${serverUrl}/${ExtMetadataFormat.CIP6} due to connection error`
        )
      );
    });

    it('resource not found server error', async () => {
      let alreadyCalled = false;
      const handler = () => {
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

      const result = await extendedMetadataService.getStakePoolExtendedMetadata(extMetadata);
      expect(result).toBeDefined();

      await expect(extendedMetadataService.getStakePoolExtendedMetadata(extMetadata)).rejects.toThrow(
        new ProviderError(
          ProviderFailure.NotFound,
          null,
          `StakePoolExtMetadataService failed to fetch extended metadata from ${serverUrl}/${ExtMetadataFormat.CIP6} due to resource not found`
        )
      );
    });
  });
});
