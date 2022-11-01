import { Cardano } from '@cardano-sdk/core';
import { Pool } from 'pg';
import { TxMetadataService, createDbSyncMetadataService } from '../../src/Metadata';
import { logger } from '@cardano-sdk/util-dev';

describe('createDbSyncMetadataService', () => {
  let dbConnection: Pool;
  let service: TxMetadataService;

  beforeAll(() => {
    dbConnection = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });
    service = createDbSyncMetadataService(dbConnection, logger);
  });

  test('query transaction metadata by tx hashes', async () => {
    const result = await service.queryTxMetadataByHashes([
      Cardano.TransactionId('3d2278e9cef71c79720a11bc3e08acbbd5f2175f7015d358c867fc9b419ae0b2'),
      Cardano.TransactionId('545c4656544054045f5a4db0e962f6b09fc6d98b0303d42f3f006e3d920d3720')
    ]);
    expect(result.size).toEqual(2);
    expect(result).toMatchSnapshot();
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
