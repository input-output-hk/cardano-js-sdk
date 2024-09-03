import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import {
  NoCache,
  PAGINATION_PAGE_SIZE_LIMIT_ASSETS,
  TokenMetadataService,
  TypeormAssetProvider,
  createDnsResolver,
  getConnectionConfig,
  getEntities
} from '../../../src';
import { Observable } from 'rxjs';
import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { TypeormAssetFixtureBuilder, TypeormAssetWith } from './TypeormAssetFixtureBuilder';
import { logger } from '@cardano-sdk/util-dev';

const tokenMetadata = {
  assetId: '4abc',
  decimals: 8,
  desc: 'SingularityNET',
  icon: 'testLogo',
  name: 'SingularityNet AGIX Token',
  ticker: 'AGIX',
  url: 'https://singularitynet.io/'
};

describe('TypeormAssetProvider', () => {
  let provider: TypeormAssetProvider;
  let fixtureBuilder: TypeormAssetFixtureBuilder;
  let connectionConfig$: Observable<PgConnectionConfig>;
  let tokenMetadataService: jest.Mocked<TokenMetadataService>;

  beforeEach(async () => {
    const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);
    const entities = getEntities(['asset']);
    connectionConfig$ = getConnectionConfig(dnsResolver, 'test', 'Asset', {
      postgresConnectionStringAsset: process.env.POSTGRES_CONNECTION_STRING_ASSET!
    });
    tokenMetadataService = {
      getTokenMetadata: jest.fn().mockResolvedValue([tokenMetadata]),
      shutdown: jest.fn()
    };

    provider = new TypeormAssetProvider(
      {
        paginationPageSizeLimit: PAGINATION_PAGE_SIZE_LIMIT_ASSETS
      },
      { connectionConfig$, entities, healthCheckCache: new NoCache(), logger, tokenMetadataService }
    );
    fixtureBuilder = new TypeormAssetFixtureBuilder({
      connectionConfig$,
      entities,
      healthCheckCache: new NoCache(),
      logger
    });

    await provider.initialize();
    await provider.start();
    await fixtureBuilder.initialize();
    await fixtureBuilder.start();
  });

  afterEach(async () => {
    jest.restoreAllMocks();

    await provider.shutdown();
    await fixtureBuilder.shutdown();
  });

  describe('getAsset', () => {
    it('should return asset info for a given asset id', async () => {
      const assetQuery = await fixtureBuilder.getAssets(1);
      const testAsset = assetQuery[0];
      const asset = await provider.getAsset({ assetId: testAsset.assetId });
      expect(asset).toEqual(testAsset);
    });

    it('should throw an error if the asset does not exist', async () => {
      const assetId = Cardano.AssetId('64190c10b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a68656c6c6f68616e646c65');
      await expect(provider.getAsset({ assetId })).rejects.toThrowError(ProviderError);
    });

    it('should return metadata if the asset has metadata', async () => {
      const assetQuery = await fixtureBuilder.getAssets(1, { with: [TypeormAssetWith.metadata] });
      const testAsset = assetQuery[0];
      const asset = await provider.getAsset({ assetId: testAsset.assetId, extraData: { nftMetadata: true } });
      expect(asset).toEqual(testAsset);
    });

    it('should return both nftMetadata and tokenMetadata if the asset has both', async () => {
      const assetQuery = await fixtureBuilder.getAssets(1, { with: [TypeormAssetWith.metadata] });
      const testAsset = assetQuery[0];
      const asset = await provider.getAsset({
        assetId: testAsset.assetId,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
      expect(asset.tokenMetadata).toEqual(tokenMetadata);
      expect(asset.nftMetadata).toEqual(testAsset.nftMetadata);
    });

    it('should return undefined asset token metadata if the token registry throws a server error', async () => {
      tokenMetadataService.getTokenMetadata.mockRejectedValue(new ProviderError(ProviderFailure.Unhealthy));

      const assetQuery = await fixtureBuilder.getAssets(1, { with: [TypeormAssetWith.metadata] });
      const testAsset = assetQuery[0];

      const asset = await provider.getAsset({
        assetId: testAsset.assetId,
        extraData: { tokenMetadata: true }
      });

      expect(asset.tokenMetadata).toBeUndefined();
    });
  });

  describe('getAssets', () => {
    it('should return multiple asset info for every assetId in a given array', async () => {
      const testAssets = await fixtureBuilder.getAssets(4);
      const assetIds = testAssets.map((asset) => asset.assetId);
      const assets = await provider.getAssets({ assetIds });
      expect(assets).toEqual(testAssets);
    });

    it('Should return multiple asset info with nftMetadata for every assetId in a given array', async () => {
      const testAssets = await fixtureBuilder.getAssets(3, { with: [TypeormAssetWith.metadata] });
      const assetIds = testAssets.map((asset) => asset.assetId);
      const assets = await provider.getAssets({ assetIds, extraData: { nftMetadata: true } });
      expect(assets).toEqual(testAssets);
    });

    it('Should throw error when one of the assetIds does not exist', async () => {
      const testAssets = await fixtureBuilder.getAssets(1);
      const invalidAssetId = Cardano.AssetId(
        '64190c10b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a68656c6c6f68616e646c65'
      );
      const assetIds = [...testAssets.map((asset) => asset.assetId), invalidAssetId];
      await expect(provider.getAssets({ assetIds })).rejects.toThrowError(ProviderError);
    });

    it('should fetch multiple token metadata for multiple assetIds', async () => {
      const testAssets = await fixtureBuilder.getAssets(4);
      const assetIds = testAssets.map((asset) => asset.assetId);
      const asset = await provider.getAssets({
        assetIds,
        extraData: { tokenMetadata: true }
      });
      expect(asset).toHaveLength(testAssets.length);
      expect(asset[0].tokenMetadata).toBeTruthy();
    });
  });
});
