/* eslint-disable @typescript-eslint/no-shadow */
import { Asset, Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import {
  CardanoTokenRegistry,
  DbSyncAssetProvider,
  DbSyncNftMetadataService,
  NftMetadataService,
  TokenMetadataService
} from '../../src/Asset';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { createDbSyncMetadataService } from '../../src/Metadata';
import { dummyLogger as logger } from 'ts-log';
import { mockCardanoNode } from '../../../core/test/CardanoNode/mocks';
import { mockTokenRegistry } from './CardanoTokenRegistry.test';

export const notValidAssetId = Cardano.AssetId('0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef');
export const validAssetId = Cardano.AssetId(
  '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65'
);
describe('DbSyncAssetProvider', () => {
  let closeMock: () => Promise<void> = jest.fn();
  let db: Pool;
  let ntfMetadataService: NftMetadataService;
  let provider: DbSyncAssetProvider;
  let tokenMetadataServerUrl = '';
  let tokenMetadataService: TokenMetadataService;
  let cardanoNode: OgmiosCardanoNode;

  beforeAll(async () => {
    ({ closeMock, tokenMetadataServerUrl } = await mockTokenRegistry(() => ({})));
    db = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });
    cardanoNode = mockCardanoNode() as unknown as OgmiosCardanoNode;
    ntfMetadataService = new DbSyncNftMetadataService({
      db,
      logger,
      metadataService: createDbSyncMetadataService(db, logger)
    });
    tokenMetadataService = new CardanoTokenRegistry({ logger }, { tokenMetadataServerUrl });
    provider = new DbSyncAssetProvider({ cardanoNode, db, logger, ntfMetadataService, tokenMetadataService });
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
    expect(await provider.getAsset({ assetId: validAssetId })).toEqual({
      assetId: '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65',
      fingerprint: 'asset1f0azzptnr8dghzjh7egqvdjmt33e3lz5uy59th',
      mintOrBurnCount: 1,
      name: '6d616361726f6e2d63616b65',
      policyId: '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb',
      quantity: 1n
    });
  });
  it('returns an AssetInfo with extra data', async () => {
    const asset = await provider.getAsset({
      assetId: validAssetId,
      extraData: { history: true, nftMetadata: true, tokenMetadata: true }
    });
    expect(asset.history).toEqual([
      { quantity: BigInt(1), transactionId: 'f66791a0354c43d8c5a93671eb96d94633e3419f3ccbb0a00c00a152d3b6ca06' }
    ]);
    expect(asset.nftMetadata).toStrictEqual({
      description: ['This is my first NFT of the macaron cake'],
      files: undefined,
      image: [Asset.Uri('ipfs://QmcDAmZubQig7tGUgEwbWcgdvz4Aoa2EiRZyFoX3fXTVmr')],
      mediaType: undefined,
      name: 'macaron cake token',
      otherProperties: new Map([['id', 1n]]),
      version: '1.0'
    });
    expect(asset.tokenMetadata).toStrictEqual({
      desc: 'This is my first NFT of the macaron cake',
      name: 'macaron cake token'
    });
  });
  it('returns undefined asset token metadata if the token registry throws a network error', async () => {
    const { tokenMetadataServerUrl, closeMock } = await mockTokenRegistry(() => ({ body: {}, code: 500 }));
    const tokenMetadataService = new CardanoTokenRegistry({ logger }, { tokenMetadataServerUrl });

    provider = new DbSyncAssetProvider({ cardanoNode, db, logger, ntfMetadataService, tokenMetadataService });

    const asset = await provider.getAsset({
      assetId: validAssetId,
      extraData: { tokenMetadata: true }
    });
    expect(asset.tokenMetadata).toBeUndefined();
    tokenMetadataService.shutdown();
    await closeMock();
  });
});
