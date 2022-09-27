import { Asset, Cardano } from '@cardano-sdk/core';
import { AssetPolicyIdAndName, DbSyncNftMetadataService, NftMetadataService } from '../../src/Asset';
import { Pool } from 'pg';
import { createDbSyncMetadataService } from '../../src/Metadata';
import { dummyLogger as logger } from 'ts-log';

export const oneMintNft: AssetPolicyIdAndName = {
  name: Cardano.AssetName('6d616361726f6e2d63616b65'),
  policyId: Cardano.PolicyId('50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb')
};

export const nonExistentAsset: AssetPolicyIdAndName = {
  name: Cardano.AssetName(''),
  policyId: Cardano.PolicyId('c0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7')
};

export const nonNftAsset: AssetPolicyIdAndName = {
  name: Cardano.AssetName('744d494e'),
  policyId: Cardano.PolicyId('126b8676446c84a5cd6e3259223b16a2314c5676b88ae1c1f8579a8f')
};

describe('DbSyncNftMetadataService', () => {
  let dbConnection: Pool;
  let service: NftMetadataService;

  beforeAll(() => {
    dbConnection = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });
    const metadataService = createDbSyncMetadataService(dbConnection, logger);
    service = new DbSyncNftMetadataService({ db: dbConnection, logger, metadataService });
  });

  afterAll(async () => {
    await dbConnection.end();
  });

  it('returns null for non-existent asset', async () => {
    expect(await service.getNftMetadata(nonExistentAsset)).toBeNull();
  });

  it('returns null for non-nft asset', async () => {
    expect(await service.getNftMetadata(nonNftAsset)).toBeNull();
  });

  it('returns nft metadata when it exists', async () => {
    expect(await service.getNftMetadata(oneMintNft)).toEqual({
      description: ['This is my first NFT of the macaron cake'],
      image: [Asset.Uri('ipfs://QmcDAmZubQig7tGUgEwbWcgdvz4Aoa2EiRZyFoX3fXTVmr')],
      name: 'macaron cake token',
      otherProperties: new Map([['id', 1n]]),
      version: '1.0'
    } as Asset.NftMetadata);
  });
});
