/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable max-len */
import { Cardano, EraSummary, TxSubmitProvider } from '@cardano-sdk/core';
import { Connection } from '@cardano-ogmios/client';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../src/NetworkInfo';
import {
  HttpServer,
  HttpServerConfig,
  TxSubmitHttpService,
  createDnsResolver,
  getOgmiosTxSubmitProvider,
  getPool,
  getRabbitMqTxSubmitProvider,
  loadAndStartTxWorker
} from '../../src';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../src/InMemoryCache';
import { Ogmios } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { RunningTxSubmitWorker } from '../../src/TxWorker/utils';
import { SrvRecord } from 'dns';
import { createHealthyMockOgmiosServer, ogmiosServerReady } from '../util';
import { createLogger } from 'bunyan';
import { createMockOgmiosServer } from '../../../ogmios/test/mocks/mockOgmiosServer';
import { dummyLogger } from 'ts-log';
import { getPort, getRandomPort } from 'get-port-please';
import { listenPromise, serverClosePromise } from '../../src/util';
import { txsPromise } from '../../../rabbitmq/test/utils';
import { types } from 'util';
import axios from 'axios';
import http from 'http';

jest.mock('dns', () => ({
  promises: {
    resolveSrv: async (serviceName: string): Promise<SrvRecord[]> => {
      if (serviceName === process.env.POSTGRES_SRV_SERVICE_NAME)
        return [{ name: 'localhost', port: 5433, priority: 6, weight: 5 }];
      if (serviceName === process.env.OGMIOS_SRV_SERVICE_NAME)
        return [{ name: 'localhost', port: 1337, priority: 6, weight: 5 }];
      if (serviceName === process.env.RABBITMQ_SRV_SERVICE_NAME)
        return [{ name: 'localhost', port: 5672, priority: 6, weight: 5 }];
      return [];
    }
  }
}));

describe('Service dependency abstractions', () => {
  const APPLICATION_JSON = 'application/json';
  const cache = new InMemoryCache(UNLIMITED_CACHE_TTL);
  const cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
  const logger = createLogger({ level: 'error', name: 'test' });
  const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);
  const mockEraSummaries: EraSummary[] = [
    { parameters: { epochLength: 21_600, slotLength: 20_000 }, start: { slot: 0, time: new Date(1_563_999_616_000) } },
    {
      parameters: { epochLength: 432_000, slotLength: 1000 },
      start: { slot: 1_598_400, time: new Date(1_595_964_016_000) }
    }
  ];
  const cardanoNode = {
    eraSummaries: jest.fn(() => Promise.resolve(mockEraSummaries)),
    initialize: jest.fn(() => Promise.resolve()),
    shutdown: jest.fn(() => Promise.resolve()),
    systemStart: jest.fn(() => Promise.resolve(new Date(1_563_999_616_000)))
  };

  describe('Postgres-dependant service with service discovery', () => {
    let httpServer: HttpServer;
    let db: Pool | undefined;
    let port: number;
    let apiUrlBase: string;
    let config: HttpServerConfig;
    let service: NetworkInfoHttpService;
    let networkInfoProvider: DbSyncNetworkInfoProvider;

    beforeAll(async () => {
      db = await getPool(dnsResolver, logger, {
        dbCacheTtl: 10_000,
        epochPollInterval: 1000,
        postgresDb: process.env.POSTGRES_DB!,
        postgresPassword: process.env.POSTGRES_PASSWORD!,
        postgresSrvServiceName: process.env.POSTGRES_SRV_SERVICE_NAME!,
        postgresUser: process.env.POSTGRES_USER!,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });
    });

    describe('Established connection', () => {
      beforeAll(async () => {
        port = await getPort();
        config = { listen: { port } };
        apiUrlBase = `http://localhost:${port}/network-info`;
        networkInfoProvider = new DbSyncNetworkInfoProvider(
          { cardanoNodeConfigPath, epochPollInterval: 2000 },
          { cache, cardanoNode, db: db! }
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

      it('db should be a instance of Proxy ', () => {
        expect(types.isProxy(db!)).toEqual(true);
      });

      it('forwards the db health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
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
      db = await getPool(dnsResolver, logger, {
        dbCacheTtl: 10_000,
        epochPollInterval: 1000,
        postgresConnectionString: process.env.POSTGRES_CONNECTION_STRING
      });
    });

    describe('Established connection', () => {
      beforeAll(async () => {
        port = await getPort();
        config = { listen: { port } };
        apiUrlBase = `http://localhost:${port}/network-info`;
        networkInfoProvider = new DbSyncNetworkInfoProvider(
          { cardanoNodeConfigPath, epochPollInterval: 2000 },
          { cache, cardanoNode, db: db! }
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

      it('db should not be instance a of Proxy ', () => {
        expect(types.isProxy(db!)).toEqual(false);
      });

      it('forwards the db health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });
  });

  describe('Db provider with service discovery and Postgres server failover', () => {
    let provider: Pool | undefined;
    const pgPortDefault = 5433;

    it('should resolve successfully if a connection error is thrown and re-connects to a new resolved record', async () => {
      const HEALTH_CHECK_QUERY = 'SELECT 1';
      const srvRecord = { name: 'localhost', port: pgPortDefault, priority: 1, weight: 1 };
      const failingPostgresMockPort = await getRandomPort();
      let resolverAlreadyCalled = false;

      // Initially resolves with a failing postgres port, then swap to the default one
      const dnsResolverMock = jest.fn().mockImplementation(async () => {
        if (!resolverAlreadyCalled) {
          resolverAlreadyCalled = true;
          return { ...srvRecord, port: failingPostgresMockPort };
        }
        return srvRecord;
      });

      provider = await getPool(dnsResolverMock, logger, {
        dbCacheTtl: 10_000,
        epochPollInterval: 1000,
        postgresDb: process.env.POSTGRES_DB!,
        postgresPassword: process.env.POSTGRES_PASSWORD!,
        postgresSrvServiceName: process.env.POSTGRES_SRV_SERVICE_NAME!,
        postgresUser: process.env.POSTGRES_USER!,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });

      const result = await provider!.query(HEALTH_CHECK_QUERY);
      await expect(result.rowCount).toBeTruthy();
      expect(dnsResolverMock).toBeCalledTimes(2);
    });

    it('should execute a provider operation without to intercept it', async () => {
      provider = await getPool(dnsResolver, logger, {
        dbCacheTtl: 10_000,
        epochPollInterval: 1000,
        postgresDb: process.env.POSTGRES_DB!,
        postgresPassword: process.env.POSTGRES_PASSWORD!,
        postgresSrvServiceName: process.env.POSTGRES_SRV_SERVICE_NAME!,
        postgresUser: process.env.POSTGRES_USER!,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });

      await expect(provider!.end()).resolves.toBeUndefined();
    });
  });

  describe('Ogmios-dependant service with service discovery', () => {
    let apiUrlBase: string;
    let ogmiosServer: http.Server;
    let ogmiosConnection: Connection;
    let txSubmitProvider: TxSubmitProvider;
    let httpServer: HttpServer;
    let port: number;
    let config: HttpServerConfig;

    beforeAll(async () => {
      ogmiosServer = createHealthyMockOgmiosServer();
      ogmiosConnection = Ogmios.createConnectionObject();
      await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
      await ogmiosServerReady(ogmiosConnection);
    });

    describe('Established connection', () => {
      beforeAll(async () => {
        port = await getPort();
        apiUrlBase = `http://localhost:${port}/tx-submit`;
        config = { listen: { port } };
        txSubmitProvider = await getOgmiosTxSubmitProvider(dnsResolver, logger, {
          ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME,
          serviceDiscoveryBackoffFactor: 1.1,
          serviceDiscoveryTimeout: 1000
        });
        httpServer = new HttpServer(config, {
          services: [new TxSubmitHttpService({ txSubmitProvider })]
        });
        await httpServer.initialize();
        await httpServer.start();
      });

      afterAll(async () => {
        await httpServer.shutdown();
        await serverClosePromise(ogmiosServer);
      });

      it('txSubmitProvider should be instance of a Proxy ', () => {
        expect(types.isProxy(txSubmitProvider)).toEqual(true);
      });

      it('forwards the txSubmitProvider health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });
  });

  describe('Ogmios-dependant service with provided connection url', () => {
    let apiUrlBase: string;
    let ogmiosServer: http.Server;
    let ogmiosConnection: Connection;
    let txSubmitProvider: TxSubmitProvider;
    let httpServer: HttpServer;
    let port: number;
    let config: HttpServerConfig;

    beforeAll(async () => {
      ogmiosServer = createHealthyMockOgmiosServer();
      ogmiosConnection = Ogmios.createConnectionObject();
      await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
      await ogmiosServerReady(ogmiosConnection);
    });

    describe('Established connection', () => {
      beforeAll(async () => {
        port = await getPort();
        apiUrlBase = `http://localhost:${port}/tx-submit`;
        config = { listen: { port } };
        txSubmitProvider = await getOgmiosTxSubmitProvider(dnsResolver, logger, {
          ogmiosUrl: new URL(ogmiosConnection.address.webSocket)
        });
        httpServer = new HttpServer(config, {
          services: [new TxSubmitHttpService({ txSubmitProvider })]
        });
        await httpServer.initialize();
        await httpServer.start();
      });

      afterAll(async () => {
        await httpServer.shutdown();
        await serverClosePromise(ogmiosServer);
      });

      it('txSubmitProvider should not be a instance of Proxy ', () => {
        expect(types.isProxy(txSubmitProvider)).toEqual(false);
      });

      it('forwards the txSubmitProvider health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });
  });

  describe('TxSubmitProvider with service discovery and Ogmios server failover', () => {
    let mockServer: http.Server;
    let connection: Connection;
    let provider: TxSubmitProvider;
    const ogmiosPortDefault = 1337;

    beforeEach(async () => {
      connection = Ogmios.createConnectionObject({ port: ogmiosPortDefault });
      // Setup working a default Ogmios with submitTx operation throwing a non-connection error
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.999, success: true } },
        submitTx: { response: { failWith: { type: 'eraMismatch' }, success: false } }
      });
      await listenPromise(mockServer, connection);
      await ogmiosServerReady(connection);
    });

    afterEach(async () => {
      if (mockServer !== undefined) {
        await serverClosePromise(mockServer);
      }
    });

    it('should initially fail with a connection error, then re-resolve the port and propagate the correct non-connection error to the caller', async () => {
      const srvRecord = { name: 'localhost', port: ogmiosPortDefault, priority: 1, weight: 1 };
      const failingOgmiosMockPort = await getRandomPort();
      let resolverAlreadyCalled = false;

      // Initially resolves with a failing ogmios port, then swap to the default one
      const dnsResolverMock = jest.fn().mockImplementation(async () => {
        if (!resolverAlreadyCalled) {
          resolverAlreadyCalled = true;
          return { ...srvRecord, port: failingOgmiosMockPort };
        }
        return srvRecord;
      });

      provider = await getOgmiosTxSubmitProvider(dnsResolverMock, logger, {
        ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });

      await expect(provider.submitTx(new Uint8Array([]))).rejects.toBeInstanceOf(
        Cardano.TxSubmissionErrors.EraMismatchError
      );
      expect(dnsResolverMock).toBeCalledTimes(2);
    });

    it('should execute a provider operation without to intercept it', async () => {
      provider = await getOgmiosTxSubmitProvider(dnsResolver, logger, {
        ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });

      await expect(provider.healthCheck()).resolves.toEqual({ ok: true });
    });
  });

  describe('RabbitMQ-dependant service with service discovery', () => {
    let apiUrlBase: string;
    let txSubmitProvider: TxSubmitProvider;
    let httpServer: HttpServer;
    let port: number;
    let config: HttpServerConfig;

    describe('Established connection', () => {
      beforeAll(async () => {
        port = await getPort();
        apiUrlBase = `http://localhost:${port}/tx-submit`;
        config = { listen: { port } };
        txSubmitProvider = await getRabbitMqTxSubmitProvider(dnsResolver, logger, {
          rabbitmqSrvServiceName: process.env.RABBITMQ_SRV_SERVICE_NAME,
          serviceDiscoveryBackoffFactor: 1.1,
          serviceDiscoveryTimeout: 1000
        });
        httpServer = new HttpServer(config, {
          services: [new TxSubmitHttpService({ txSubmitProvider })]
        });
        await httpServer.initialize();
        await httpServer.start();
      });

      afterAll(async () => {
        await httpServer.shutdown();
      });

      it('txSubmitProvider should be instance of a Proxy ', () => {
        expect(types.isProxy(txSubmitProvider)).toEqual(true);
      });

      it('forwards the txSubmitProvider health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });
  });

  describe('RabbitMQ-dependant service with provided connection url', () => {
    let apiUrlBase: string;
    let txSubmitProvider: TxSubmitProvider;
    let httpServer: HttpServer;
    let port: number;
    let config: HttpServerConfig;

    describe('Established connection', () => {
      beforeAll(async () => {
        port = await getPort();
        apiUrlBase = `http://localhost:${port}/tx-submit`;
        config = { listen: { port } };
        txSubmitProvider = await getRabbitMqTxSubmitProvider(dnsResolver, logger, {
          rabbitmqUrl: new URL(process.env.RABBITMQ_URL!)
        });
        httpServer = new HttpServer(config, {
          services: [new TxSubmitHttpService({ txSubmitProvider })]
        });
        await httpServer.initialize();
        await httpServer.start();
      });

      afterAll(async () => {
        await httpServer.shutdown();
      });

      it('txSubmitProvider should not be a instance of Proxy ', () => {
        expect(types.isProxy(txSubmitProvider)).toEqual(false);
      });

      it('forwards the txSubmitProvider health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });
  });

  describe('TxSubmitProvider with service discovery and RabbitMQ server failover', () => {
    let mockServer: http.Server;
    let connection: Connection;
    let provider: TxSubmitProvider;
    let txSubmitWorker: RunningTxSubmitWorker;
    const ogmiosPortDefault = 1337;
    const rabbitmqPortDedault = 5672;

    beforeEach(async () => {
      connection = Ogmios.createConnectionObject({ port: ogmiosPortDefault });
      // Setup working a default Ogmios with submitTx operation throwing a non-connection error
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.999, success: true } },
        submitTx: { response: { failWith: { type: 'eraMismatch' }, success: false } }
      });
      await listenPromise(mockServer, connection);
      await ogmiosServerReady(connection);

      txSubmitWorker = await loadAndStartTxWorker(
        {
          options: {
            loggerMinSeverity: 'error',
            ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME,
            parallel: true,
            rabbitmqSrvServiceName: process.env.RABBITMQ_SRV_SERVICE_NAME,
            serviceDiscoveryBackoffFactor: 1.1,
            serviceDiscoveryTimeout: 1000
          }
        },
        dummyLogger
      );
    });

    afterEach(async () => {
      if (mockServer !== undefined) {
        await serverClosePromise(mockServer);
      }
      if (txSubmitWorker !== undefined) {
        await txSubmitWorker.stop();
      }
    });

    it('should initially fail with a connection error, then re-resolve the port and propagate the correct non-connection error to the caller', async () => {
      const srvRecord = { name: 'localhost', port: rabbitmqPortDedault, priority: 1, weight: 1 };
      const failingRabbitMqMockPort = await getRandomPort();
      let resolverAlreadyCalled = false;

      // Initially resolves with a failing rabbitmq port, then swap to the default one
      const dnsResolverMock = jest.fn().mockImplementation(async () => {
        if (!resolverAlreadyCalled) {
          resolverAlreadyCalled = true;
          return { ...srvRecord, port: failingRabbitMqMockPort };
        }
        return srvRecord;
      });

      provider = await getRabbitMqTxSubmitProvider(dnsResolverMock, logger, {
        rabbitmqSrvServiceName: process.env.RABBITMQ_SRV_SERVICE_NAME!,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });

      const txs = await txsPromise;
      await expect(provider.submitTx(txs[0].txBodyUint8Array)).rejects.toBeInstanceOf(
        Cardano.TxSubmissionErrors.EraMismatchError
      );
      expect(dnsResolverMock).toBeCalledTimes(2);
    });

    it('should execute a provider operation without to intercept it', async () => {
      provider = await getRabbitMqTxSubmitProvider(dnsResolver, logger, {
        rabbitmqSrvServiceName: process.env.RABBITMQ_SRV_SERVICE_NAME,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });

      await expect(provider.healthCheck()).resolves.toEqual({ ok: true });
    });
  });
});
