import { Asset, Cardano } from '@cardano-sdk/core';
import { AssetFixtureBuilder, AssetWith } from './fixtures/FixtureBuilder';
import { AssetPolicyIdAndName, DbSyncNftMetadataService, NftMetadataService } from '../../src/Asset';
import { Pool } from 'pg';
import { createDbSyncMetadataService } from '../../src/Metadata';
import { logger } from '@cardano-sdk/util-dev';

export const nonExistentAsset: AssetPolicyIdAndName = {
  name: Cardano.AssetName(''),
  policyId: Cardano.PolicyId('c0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7')
};

describe('DbSyncNftMetadataService', () => {
  let dbConnection: Pool;
  let service: NftMetadataService;
  let fixtureBuilder: AssetFixtureBuilder;
  beforeAll(() => {
    dbConnection = new Pool({ connectionString: process.env.LOCALNETWORK_INTEGRAION_TESTS_POSTGRES_CONNECTION_STRING });
    const metadataService = createDbSyncMetadataService(dbConnection, logger);
    service = new DbSyncNftMetadataService({ db: dbConnection, logger, metadataService });
    fixtureBuilder = new AssetFixtureBuilder(dbConnection, logger);
  });

  afterAll(async () => {
    await dbConnection.end();
  });

  it('returns null for non-existent asset', async () => {
    expect(await service.getNftMetadata(nonExistentAsset)).toBeNull();
  });

  it('returns null for non-nft asset', async () => {
    const assets = await fixtureBuilder.getAssets(1);
    expect(await service.getNftMetadata(assets[0])).toBeNull();
  });

  it('returns nft metadata when it exists', async () => {
    const assets = await fixtureBuilder.getAssets(1, { with: [AssetWith.CIP25Metadata] });
    expect(await service.getNftMetadata(assets[0])).toEqual(assets[0].metadata as Asset.NftMetadata);
  });
});
