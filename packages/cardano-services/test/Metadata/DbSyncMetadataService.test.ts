import { Cardano } from '@cardano-sdk/core';
import { MetadataFixtureBuilder } from './fixtures/FixtureBuilder';
import { Pool } from 'pg';
import { TxMetadataService, createDbSyncMetadataService } from '../../src/Metadata';
import { logger } from '@cardano-sdk/util-dev';

describe('createDbSyncMetadataService', () => {
  let dbConnection: Pool;
  let service: TxMetadataService;
  let fixtureBuilder: MetadataFixtureBuilder;
  beforeAll(() => {
    dbConnection = new Pool({
      connectionString: process.env.LOCALNETWORK_INTEGRATION_TESTS_POSTGRES_CONNECTION_STRING
    });
    service = createDbSyncMetadataService(dbConnection, logger);
    fixtureBuilder = new MetadataFixtureBuilder(dbConnection, logger);
  });

  test('query transaction metadata by tx hashes', async () => {
    const hashes = await fixtureBuilder.getTxIds(2);
    const result = await service.queryTxMetadataByHashes(hashes);
    expect(result.size).toEqual(2);
    expect(result.get(hashes[0])).toBeDefined();
    expect(result.get(hashes[1])).toBeDefined();
  });

  test('query transaction metadata with empty array', async () => {
    const result = await service.queryTxMetadataByHashes([]);
    expect(result.size).toEqual(0);
  });

  test('query transaction metadata when tx not found or has no metadata', async () => {
    const result = await service.queryTxMetadataByHashes([
      Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
    ]);
    expect(result.size).toEqual(0);
  });
});
