import { DataMocks } from '../../data-mocks';
import { NetworkInfoBuilder } from '../../../src/NetworkInfo/DbSyncNetworkInfoProvider/NetworkInfoBuilder';
import { NetworkInfoFixtureBuilder } from '../fixtures/FixtureBuilder';
import { Pool } from 'pg';
import { logger } from '@cardano-sdk/util-dev';

describe('NetworkInfoBuilder', () => {
  let dbConnection: Pool;
  let builder: NetworkInfoBuilder;
  let fixtureBuilder: NetworkInfoFixtureBuilder;

  beforeAll(async () => {
    dbConnection = new Pool({
      connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC
    });
    builder = new NetworkInfoBuilder(dbConnection, logger);
    fixtureBuilder = new NetworkInfoFixtureBuilder(dbConnection, logger);
  });

  afterAll(async () => {
    await dbConnection.end();
  });

  describe('queryCirculatingSupply', () => {
    test('query circulating supply', async () => {
      const result = await builder.queryCirculatingSupply();
      expect(BigInt(result)).toBeGreaterThan(0n);
    });
  });

  describe('queryTotalSupply', () => {
    test('query total supply', async () => {
      const maxSupply = await fixtureBuilder.getMaxSupply();
      const result = await builder.queryTotalSupply(maxSupply);
      expect(BigInt(result)).toBeGreaterThan(0n);
    });
  });

  describe('queryActiveStake', () => {
    test('query active stake', async () => {
      const result = await builder.queryActiveStake();
      expect(BigInt(result)).toBeGreaterThan(0n);
    });
  });

  describe('queryLatestEpoch', () => {
    test('query latest epoch', async () => {
      const result = await builder.queryLatestEpoch();
      expect(result).toBeGreaterThan(0);
    });
  });

  describe('queryLedgerTip', () => {
    test('query ledger tip', async () => {
      const result = await builder.queryLedgerTip();
      expect({ ...result, hash: result.hash.toString('hex') }).toMatchShapeOf(DataMocks.Ledger.tip);
    });
  });

  describe('queryProtocolParams', () => {
    test('query wallet protocol params from current epoch', async () => {
      const result = await builder.queryProtocolParams();
      expect(result).toMatchShapeOf(DataMocks.Ledger.parameters);
    });
  });
});
