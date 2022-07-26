import { NetworkInfoBuilder } from '../../../src/NetworkInfo/DbSyncNetworkInfoProvider/NetworkInfoBuilder';
import { Pool } from 'pg';

describe('NetworkInfoBuilder', () => {
  let dbConnection: Pool;
  let builder: NetworkInfoBuilder;

  beforeAll(async () => {
    dbConnection = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });
    builder = new NetworkInfoBuilder(dbConnection);
  });

  afterAll(async () => {
    await dbConnection.end();
  });

  describe('queryCirculatingSupply', () => {
    test('query circulating supply', async () => {
      const result = await builder.queryCirculatingSupply();
      expect(BigInt(result)).toBeGreaterThan(0n);
      expect(result).toMatchSnapshot();
    });
  });

  describe('queryTotalSupply', () => {
    test('query total supply', async () => {
      const maxSupply = 45_000_000_000_000_000n;
      const result = await builder.queryTotalSupply(maxSupply);
      expect(BigInt(result)).toBeGreaterThan(0n);
      expect(result).toMatchSnapshot();
    });
  });

  describe('queryLiveStake', () => {
    test('query live stake', async () => {
      const result = await builder.queryLiveStake();
      expect(BigInt(result)).toBeGreaterThan(0n);
      expect(result).toMatchSnapshot();
    });
  });

  describe('queryActiveStake', () => {
    test('query active stake', async () => {
      const result = await builder.queryActiveStake();
      expect(BigInt(result)).toBeGreaterThan(0n);
      expect(result).toMatchSnapshot();
    });
  });

  describe('queryLatestEpoch', () => {
    test('query latest epoch', async () => {
      const result = await builder.queryLatestEpoch();
      expect(result).toBeGreaterThan(0);
      expect(result).toMatchSnapshot();
    });
  });

  describe('queryLedgerTip', () => {
    test('query ledger tip', async () => {
      const result = await builder.queryLedgerTip();
      expect({ ...result, hash: result.hash.toString('hex') }).toMatchSnapshot();
    });
  });

  describe('queryCurrentWalletProtocolParams', () => {
    test('query wallet protocol params from current epoch', async () => {
      const result = await builder.queryCurrentWalletProtocolParams();
      expect(result).toMatchSnapshot();
    });
  });
});
