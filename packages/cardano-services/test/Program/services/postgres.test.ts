/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
import { DbSyncEpochPollService, loadGenesisData } from '../../../src/util/index.js';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../../src/NetworkInfo/index.js';
import { HttpServer, createDnsResolver, getPool } from '../../../src/index.js';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../../src/InMemoryCache/index.js';
import { clearDbPools, servicesWithVersionPath as services } from '../../util.js';
import { findLedgerTip } from '../../../src/util/DbSyncProvider/index.js';
import { getPort } from 'get-port-please';
import { healthCheckResponseMock, mockCardanoNode } from '../../../../core/test/CardanoNode/mocks.js';
import { logger } from '@cardano-sdk/util-dev';
import { mockDnsResolverFactory } from './util.js';
import { types } from 'util';
import axios from 'axios';
import type { DbPools, LedgerTipModel } from '../../../src/util/DbSyncProvider/index.js';
import type { EpochMonitor } from '../../../src/util/index.js';
import type { HttpServerConfig } from '../../../src/index.js';
import type { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import type { Pool } from 'pg';
import type { SrvRecord } from 'dns';

jest.mock('dns', () => ({
  promises: {
    resolveSrv: async (serviceName: string): Promise<SrvRecord[]> => {
      if (serviceName === process.env.POSTGRES_SRV_SERVICE_NAME_DB_SYNC)
        return [{ name: 'localhost', port: 5433, priority: 6, weight: 5 }];
      return [];
    }
  }
}));

describe('Service dependency abstractions', () => {
  const APPLICATION_JSON = 'application/json';
  const cache = { db: new InMemoryCache(UNLIMITED_CACHE_TTL), healthCheck: new InMemoryCache(UNLIMITED_CACHE_TTL) };
  const cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
  const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);

  describe('Postgres-dependant service with service discovery', () => {
    let httpServer: HttpServer;
    let dbPools: DbPools;
    let port: number;
    let apiUrlBase: string;
    let config: HttpServerConfig;
    let service: NetworkInfoHttpService;
    let networkInfoProvider: DbSyncNetworkInfoProvider;
    let epochMonitor: EpochMonitor;
    let cardanoNode: OgmiosCardanoNode;
    let lastBlockNoInDb: LedgerTipModel;

    beforeAll(async () => {
      dbPools = {
        healthCheck: (await getPool(dnsResolver, logger, {
          postgresDbDbSync: process.env.POSTGRES_DB_DB_SYNC!,
          postgresPasswordDbSync: process.env.POSTGRES_PASSWORD_DB_SYNC!,
          postgresSrvServiceNameDbSync: process.env.POSTGRES_SRV_SERVICE_NAME_DB_SYNC!,
          postgresUserDbSync: process.env.POSTGRES_USER_DB_SYNC!
        })) as Pool,
        main: (await getPool(dnsResolver, logger, {
          postgresDbDbSync: process.env.POSTGRES_DB_DB_SYNC!,
          postgresPasswordDbSync: process.env.POSTGRES_PASSWORD_DB_SYNC!,
          postgresSrvServiceNameDbSync: process.env.POSTGRES_SRV_SERVICE_NAME_DB_SYNC!,
          postgresUserDbSync: process.env.POSTGRES_USER_DB_SYNC!
        })) as Pool
      };
    });

    describe('Established connection', () => {
      beforeAll(async () => {
        port = await getPort();
        config = { listen: { port } };
        apiUrlBase = `http://localhost:${port}${services.networkInfo.versionPath}/${services.networkInfo.name}`;
        epochMonitor = new DbSyncEpochPollService(dbPools.main!, 10_000);
        lastBlockNoInDb = (await dbPools.main!.query<LedgerTipModel>(findLedgerTip)).rows[0];
        cardanoNode = mockCardanoNode(
          healthCheckResponseMock({
            blockNo: lastBlockNoInDb.block_no,
            hash: lastBlockNoInDb.hash.toString('hex'),
            projectedTip: {
              blockNo: lastBlockNoInDb.block_no,
              hash: lastBlockNoInDb.hash.toString('hex'),
              slot: Number(lastBlockNoInDb.slot_no)
            },
            slot: Number(lastBlockNoInDb.slot_no),
            withTip: true
          })
        ) as unknown as OgmiosCardanoNode;
        const genesisData = await loadGenesisData(cardanoNodeConfigPath);
        networkInfoProvider = new DbSyncNetworkInfoProvider({
          cache,
          cardanoNode,
          dbPools,
          epochMonitor,
          genesisData,
          logger
        });
        service = new NetworkInfoHttpService({ logger, networkInfoProvider });
        httpServer = new HttpServer(config, { logger, runnableDependencies: [cardanoNode], services: [service] });

        await httpServer.initialize();
        await httpServer.start();
      });

      afterAll(async () => {
        await clearDbPools(dbPools);
        await httpServer.shutdown();
        await cache.db.shutdown();
        jest.clearAllTimers();
      });

      it('db should be a instance of Proxy ', () => {
        expect(types.isProxy(dbPools.main!)).toEqual(true);
      });

      it('forwards the db health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual(
          healthCheckResponseMock({
            blockNo: lastBlockNoInDb.block_no,
            hash: lastBlockNoInDb.hash.toString('hex'),
            projectedTip: {
              blockNo: lastBlockNoInDb.block_no,
              hash: lastBlockNoInDb.hash.toString('hex'),
              slot: Number(lastBlockNoInDb.slot_no)
            },
            slot: Number(lastBlockNoInDb.slot_no),
            withTip: true
          })
        );
      });
    });
  });

  describe('Postgres-dependant service with static config', () => {
    let httpServer: HttpServer;
    let dbPools: DbPools;
    let port: number;
    let apiUrlBase: string;
    let config: HttpServerConfig;
    let service: NetworkInfoHttpService;
    let networkInfoProvider: DbSyncNetworkInfoProvider;
    let epochMonitor: EpochMonitor;
    let cardanoNode: OgmiosCardanoNode;
    let lastBlockNoInDb: LedgerTipModel;

    beforeAll(async () => {
      dbPools = {
        healthCheck: (await getPool(dnsResolver, logger, {
          postgresConnectionStringDbSync: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC
        })) as Pool,
        main: (await getPool(dnsResolver, logger, {
          postgresConnectionStringDbSync: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC
        })) as Pool
      };
    });

    describe('Established connection', () => {
      beforeAll(async () => {
        port = await getPort();
        config = { listen: { port } };
        apiUrlBase = `http://localhost:${port}${services.networkInfo.versionPath}/${services.networkInfo.name}`;
        epochMonitor = new DbSyncEpochPollService(dbPools.main!, 1000);
        lastBlockNoInDb = (await dbPools.main!.query<LedgerTipModel>(findLedgerTip)).rows[0];
        cardanoNode = mockCardanoNode(
          healthCheckResponseMock({
            blockNo: lastBlockNoInDb.block_no,
            hash: lastBlockNoInDb.hash.toString('hex'),
            projectedTip: {
              blockNo: lastBlockNoInDb.block_no,
              hash: lastBlockNoInDb.hash.toString('hex'),
              slot: Number(lastBlockNoInDb.slot_no)
            },
            slot: Number(lastBlockNoInDb.slot_no),
            withTip: true
          })
        ) as unknown as OgmiosCardanoNode;
        const genesisData = await loadGenesisData(cardanoNodeConfigPath);
        const deps = { cache, cardanoNode, dbPools, epochMonitor, genesisData, logger };
        networkInfoProvider = new DbSyncNetworkInfoProvider(deps);
        service = new NetworkInfoHttpService({ logger, networkInfoProvider });
        httpServer = new HttpServer(config, { logger, runnableDependencies: [cardanoNode], services: [service] });

        await httpServer.initialize();
        await httpServer.start();
      });

      afterAll(async () => {
        await clearDbPools(dbPools);
        await httpServer.shutdown();
        await cache.db.shutdown();
        jest.clearAllTimers();
      });

      it('forwards the db health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual(
          healthCheckResponseMock({
            blockNo: lastBlockNoInDb.block_no,
            hash: lastBlockNoInDb.hash.toString('hex'),
            projectedTip: {
              blockNo: lastBlockNoInDb.block_no,
              hash: lastBlockNoInDb.hash.toString('hex'),
              slot: Number(lastBlockNoInDb.slot_no)
            },
            slot: Number(lastBlockNoInDb.slot_no),
            withTip: true
          })
        );
      });
    });
  });

  describe('Db pool provider with service discovery and Postgres server failover', () => {
    let provider: Pool | undefined;
    const pgPortDefault = 5433;
    const mockDnsResolver = mockDnsResolverFactory(pgPortDefault);

    it('should resolve successfully if a connection error is thrown and re-connects to a new resolved record', async () => {
      const HEALTH_CHECK_QUERY = 'SELECT 1';

      // Resolves with a failing postgres port twice, then swap to the default one
      const dnsResolverMock = await mockDnsResolver(2);

      provider = await getPool(dnsResolverMock, logger, {
        postgresDbDbSync: process.env.POSTGRES_DB_DB_SYNC!,
        postgresPasswordDbSync: process.env.POSTGRES_PASSWORD_DB_SYNC!,
        postgresSrvServiceNameDbSync: process.env.POSTGRES_SRV_SERVICE_NAME_DB_SYNC!,
        postgresUserDbSync: process.env.POSTGRES_USER_DB_SYNC!
      });

      const result = await provider!.query(HEALTH_CHECK_QUERY);
      expect(result.rowCount).toBeTruthy();
      expect(dnsResolverMock).toBeCalledTimes(3);
      await provider!.end();
    });

    it('should execute a provider operation without to intercept it', async () => {
      provider = await getPool(dnsResolver, logger, {
        postgresDbDbSync: process.env.POSTGRES_DB_DB_SYNC!,
        postgresPasswordDbSync: process.env.POSTGRES_PASSWORD_DB_SYNC!,
        postgresSrvServiceNameDbSync: process.env.POSTGRES_SRV_SERVICE_NAME_DB_SYNC!,
        postgresUserDbSync: process.env.POSTGRES_USER_DB_SYNC!
      });

      await expect(provider!.end()).resolves.toBeUndefined();
    });
  });
});
