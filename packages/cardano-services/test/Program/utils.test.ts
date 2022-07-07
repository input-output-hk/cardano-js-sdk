/* eslint-disable sonarjs/no-identical-functions */
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../src/NetworkInfo';
import { HttpServer, HttpServerConfig, getDnsSrvResolveWithExponentialBackoff, getPool } from '../../src';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../src/InMemoryCache';
import { Pool } from 'pg';
import { SrvRecord } from 'dns';
import { createLogger } from 'bunyan';
import { getPort } from 'get-port-please';
import { types } from 'util';
import axios from 'axios';

jest.mock('dns', () => ({
  promises: {
    resolveSrv: async (serviceName: string): Promise<SrvRecord[]> => {
      if (serviceName === 'db-test-domain') return [{ name: '127.0.0.1', port: 5433, priority: 6, weight: 5 }];
      if (serviceName === 'ogmios-test-domain') return [{ name: '127.0.0.1', port: 1337, priority: 6, weight: 5 }];
      if (serviceName === 'rabbitmq-test-domain') return [{ name: '127.0.0.1', port: 5672, priority: 6, weight: 5 }];
      return [];
    }
  }
}));

const APPLICATION_JSON = 'application/json';
const cache = new InMemoryCache(UNLIMITED_CACHE_TTL);
const cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
const logger = createLogger({ level: 'error', name: 'test' });
const dnsSrvResolve = getDnsSrvResolveWithExponentialBackoff({ factor: 1.1, maxRetryTime: 1000 }, cache, logger);

describe('Postgres-dependant service with provided SRV service name', () => {
  let httpServer: HttpServer;
  let db: Pool | undefined;
  let port: number;
  let apiUrlBase: string;
  let config: HttpServerConfig;
  let service: NetworkInfoHttpService;
  let networkInfoProvider: DbSyncNetworkInfoProvider;

  beforeAll(async () => {
    db = await getPool(dnsSrvResolve, {
      dbPollInterval: 1000,
      dbQueriesCacheTtl: 10_000,
      postgresName: process.env.POSTGRES_NAME!,
      postgresPassword: process.env.POSTGRES_PASSWORD!,
      postgresSrvServiceName: process.env.POSTGRES_SRV_SERVICE_NAME!,
      postgresUser: process.env.POSTGRES_USER!,
      serviceDiscoveryBackoffFactor: 1.1,
      serviceDiscoveryTimeout: 1000
    });
  });

  describe('healthy state', () => {
    beforeAll(async () => {
      port = await getPort();
      config = { listen: { port } };
      apiUrlBase = `http://localhost:${port}/network-info`;
      networkInfoProvider = new DbSyncNetworkInfoProvider(
        { cardanoNodeConfigPath, dbPollInterval: 2000 },
        { cache, db: db! }
      );
      service = new NetworkInfoHttpService({ networkInfoProvider });
      httpServer = new HttpServer(config, { services: [service] });

      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await db!.end();
      await httpServer.shutdown();
      await cache.shutdown();
      jest.clearAllTimers();
    });

    it('db should be instance of a Proxy ', () => {
      expect(types.isProxy(db!)).toEqual(true);
    });

    it('forwards the networkInfoProvider health response', async () => {
      const res = await axios.post(`${apiUrlBase}/health`, {
        headers: { 'Content-Type': APPLICATION_JSON }
      });
      expect(res.status).toBe(200);
      expect(res.data).toEqual({ ok: true });
    });

    it('returns a 200 coded response with a well formed HTTP request', async () => {
      expect((await axios.post(`${apiUrlBase}/ledger-tip`, { args: [] })).status).toEqual(200);
    });
  });
});

describe('Postgres-dependant service with provided db connection string', () => {
  let httpServer: HttpServer;
  let db: Pool | undefined;
  let port: number;
  let apiUrlBase: string;
  let config: HttpServerConfig;
  let service: NetworkInfoHttpService;
  let networkInfoProvider: DbSyncNetworkInfoProvider;

  beforeAll(async () => {
    db = await getPool(dnsSrvResolve, {
      dbConnectionString: process.env.DB_CONNECTION_STRING,
      dbPollInterval: 1000,
      dbQueriesCacheTtl: 10_000,
      serviceDiscoveryBackoffFactor: 1.1,
      serviceDiscoveryTimeout: 1000
    });
  });

  describe('healthy state', () => {
    beforeAll(async () => {
      port = await getPort();
      config = { listen: { port } };
      apiUrlBase = `http://localhost:${port}/network-info`;
      networkInfoProvider = new DbSyncNetworkInfoProvider(
        { cardanoNodeConfigPath, dbPollInterval: 2000 },
        { cache, db: db! }
      );
      service = new NetworkInfoHttpService({ networkInfoProvider });
      httpServer = new HttpServer(config, { services: [service] });

      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await db!.end();
      await httpServer.shutdown();
      await cache.shutdown();
      jest.clearAllTimers();
    });

    it('db should not be instance of a Proxy ', () => {
      expect(types.isProxy(db!)).toEqual(false);
    });

    it('forwards the networkInfoProvider health response', async () => {
      const res = await axios.post(`${apiUrlBase}/health`, {
        headers: { 'Content-Type': APPLICATION_JSON }
      });
      expect(res.status).toBe(200);
      expect(res.data).toEqual({ ok: true });
    });

    it('returns a 200 coded response with a well formed HTTP request', async () => {
      expect((await axios.post(`${apiUrlBase}/ledger-tip`, { args: [] })).status).toEqual(200);
    });
  });
});
