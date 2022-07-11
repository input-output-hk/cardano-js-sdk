/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
import { Connection } from '@cardano-ogmios/client';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../src/NetworkInfo';
import { EraSummary, TxSubmitProvider } from '@cardano-sdk/core';
import {
  HttpServer,
  HttpServerConfig,
  TxSubmitHttpService,
  createDnsResolver,
  getOgmiosTxSubmitProvider,
  getPool,
  getRabbitMqTxSubmitProvider
} from '../../src';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../src/InMemoryCache';
import { Pool } from 'pg';
import { SrvRecord } from 'dns';
import { createConnectionObject } from '@cardano-sdk/ogmios';
import { createHealthyMockOgmiosServer, ogmiosServerReady } from '../util';
import { createLogger } from 'bunyan';
import { getPort } from 'get-port-please';
import { listenPromise, serverClosePromise } from '../../src/util';
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
  const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, cache, logger);
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
      db = await getPool(dnsResolver, {
        cacheTtl: 10_000,
        epochPollInterval: 1000,
        postgresDb: process.env.POSTGRES_DB!,
        postgresPassword: process.env.POSTGRES_PASSWORD!,
        postgresSrvServiceName: process.env.POSTGRES_SRV_SERVICE_NAME!,
        postgresUser: process.env.POSTGRES_USER!,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryBackoffTimeout: 1000
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
      db = await getPool(dnsResolver, {
        cacheTtl: 10_000,
        dbConnectionString: process.env.DB_CONNECTION_STRING,
        epochPollInterval: 1000
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
      ogmiosConnection = createConnectionObject();
      await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
      await ogmiosServerReady(ogmiosConnection);
    });

    describe('Established connection', () => {
      beforeAll(async () => {
        port = await getPort();
        apiUrlBase = `http://localhost:${port}/tx-submit`;
        config = { listen: { port } };
        txSubmitProvider = await getOgmiosTxSubmitProvider(dnsResolver, {
          cacheTtl: 10_000,
          ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME,
          serviceDiscoveryBackoffFactor: 1.1,
          serviceDiscoveryBackoffTimeout: 1000
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
      ogmiosConnection = createConnectionObject();
      await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
      await ogmiosServerReady(ogmiosConnection);
    });

    describe('Established connection', () => {
      beforeAll(async () => {
        port = await getPort();
        apiUrlBase = `http://localhost:${port}/tx-submit`;
        config = { listen: { port } };
        txSubmitProvider = await getOgmiosTxSubmitProvider(dnsResolver, {
          cacheTtl: 10_000,
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
        txSubmitProvider = await getRabbitMqTxSubmitProvider(dnsResolver, {
          cacheTtl: 10_000,
          rabbitmqSrvServiceName: process.env.RABBITMQ_SRV_SERVICE_NAME,
          serviceDiscoveryBackoffFactor: 1.1,
          serviceDiscoveryBackoffTimeout: 1000
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
        txSubmitProvider = await getRabbitMqTxSubmitProvider(dnsResolver, {
          cacheTtl: 10_000,
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
});
