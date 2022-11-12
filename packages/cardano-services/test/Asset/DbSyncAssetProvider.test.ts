/* eslint-disable @typescript-eslint/no-shadow */
import { AssetFixtureBuilder, AssetWith } from './fixtures/FixtureBuilder';
import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import {
  CardanoTokenRegistry,
  DbSyncAssetProvider,
  DbSyncNftMetadataService,
  NftMetadataService,
  TokenMetadataService
} from '../../src';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { createDbSyncMetadataService } from '../../src/Metadata';
import { logger } from '@cardano-sdk/util-dev';
import { mockCardanoNode } from '../../../core/test/CardanoNode/mocks';
import { mockTokenRegistry } from './fixtures/mocks';

export const notValidAssetId = Cardano.AssetId('0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef');

describe('DbSyncAssetProvider', () => {
  let closeMock: () => Promise<void> = jest.fn();
  let db: Pool;
  let ntfMetadataService: NftMetadataService;
  let provider: DbSyncAssetProvider;
  let serverUrl = '';
  let tokenMetadataService: TokenMetadataService;
  let cardanoNode: OgmiosCardanoNode;
  let fixtureBuilder: AssetFixtureBuilder;

  beforeAll(async () => {
    ({ closeMock, serverUrl } = await mockTokenRegistry(() => ({})));
    db = new Pool({ connectionString: process.env.LOCALNETWORK_INTEGRATION_TESTS_POSTGRES_CONNECTION_STRING });
    cardanoNode = mockCardanoNode() as unknown as OgmiosCardanoNode;
    ntfMetadataService = new DbSyncNftMetadataService({
      db,
      logger,
      metadataService: createDbSyncMetadataService(db, logger)
    });
    tokenMetadataService = new CardanoTokenRegistry({ logger }, { tokenMetadataServerUrl: serverUrl });
    provider = new DbSyncAssetProvider({ cardanoNode, db, logger, ntfMetadataService, tokenMetadataService });
    fixtureBuilder = new AssetFixtureBuilder(db, logger);
  });

  afterAll(async () => {
    tokenMetadataService.shutdown();
    await db.end();
    await closeMock();
  });
  it('rejects for not found assetId', async () => {
    await expect(provider.getAsset({ assetId: notValidAssetId })).rejects.toThrow(
      new ProviderError(ProviderFailure.NotFound, undefined, 'No entries found in multi_asset table')
    );
  });
  it('returns an AssetInfo without extra data', async () => {
    const assets = await fixtureBuilder.getAssets(1, { with: [AssetWith.CIP25Metadata] });
    expect(await provider.getAsset({ assetId: assets[0].id })).toMatchShapeOf({
      assetId: '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65',
      fingerprint: 'asset1f0azzptnr8dghzjh7egqvdjmt33e3lz5uy59th',
      mintOrBurnCount: 1,
      name: '6d616361726f6e2d63616b65',
      policyId: '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb',
      quantity: 1n
    });
  });
  it('returns an AssetInfo with extra data', async () => {
    const assets = await fixtureBuilder.getAssets(1, { with: [AssetWith.CIP25Metadata] });
    const asset = await provider.getAsset({
      assetId: assets[0].id,
      extraData: { history: true, nftMetadata: true, tokenMetadata: true }
    });
    const history = await fixtureBuilder.getHistory(assets[0].policyId, assets[0].name);

    expect(asset.history).toEqual(history);
    expect(asset.nftMetadata).toStrictEqual(assets[0].metadata);
    expect(asset.tokenMetadata).toStrictEqual({
      desc: 'This is my first NFT of the macaron cake',
      name: 'macaron cake token'
    });
  });
  it('returns undefined asset token metadata if the token registry throws a network error', async () => {
    const { serverUrl, closeMock } = await mockTokenRegistry(() => ({ body: {}, code: 500 }));
    const tokenMetadataService = new CardanoTokenRegistry({ logger }, { tokenMetadataServerUrl: serverUrl });

    provider = new DbSyncAssetProvider({ cardanoNode, db, logger, ntfMetadataService, tokenMetadataService });

    const assets = await fixtureBuilder.getAssets(1, { with: [AssetWith.CIP25Metadata] });
    const asset = await provider.getAsset({
      assetId: assets[0].id,
      extraData: { tokenMetadata: true }
    });
    expect(asset.tokenMetadata).toBeUndefined();
    tokenMetadataService.shutdown();
    await closeMock();
  });
});
