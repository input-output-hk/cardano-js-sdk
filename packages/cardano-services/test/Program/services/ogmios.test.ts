/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable max-len */
import { Cardano, TxSubmitProvider } from '@cardano-sdk/core';
import { Connection } from '@cardano-ogmios/client';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../../src/NetworkInfo';
import {
  HttpServer,
  HttpServerConfig,
  TxSubmitHttpService,
  createDnsResolver,
  getOgmiosCardanoNode,
  getOgmiosTxSubmitProvider,
  getPool
} from '../../../src';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../../src/InMemoryCache';
import { Ogmios, OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { SrvRecord } from 'dns';
import { createHealthyMockOgmiosServer, ogmiosServerReady } from '../../util';
import { createLogger } from 'bunyan';
import { createMockOgmiosServer } from '../../../../ogmios/test/mocks/mockOgmiosServer';
import { getPort, getRandomPort } from 'get-port-please';
import { listenPromise, serverClosePromise } from '../../../src/util';
import { mockCardanoNode } from '../../../../core/test/CardanoNode/mocks';
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
  const cardanoNode = mockCardanoNode();

  describe('Ogmios-dependant services with service discovery', () => {
    let apiUrlBase: string;
    let ogmiosServer: http.Server;
    let ogmiosConnection: Connection;
    let txSubmitProvider: TxSubmitProvider;
    let ogmiosCardanoNode: OgmiosCardanoNode;
    let httpServer: HttpServer;
    let port: number;
    let db: Pool | undefined;
    let config: HttpServerConfig;

    beforeAll(async () => {
      ogmiosServer = createHealthyMockOgmiosServer();
      ogmiosConnection = Ogmios.createConnectionObject();
      await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
      await ogmiosServerReady(ogmiosConnection);
    });

    afterAll(async () => {
      await serverClosePromise(ogmiosServer);
    });

    describe('Established connection', () => {
      describe('TxSubmitHttpService', () => {
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
        });

        it('txSubmitProvider should be instance of a Proxy ', () => {
          expect(types.isProxy(txSubmitProvider)).toEqual(true);
        });

        it('forwards the TxSubmitHttpService health response', async () => {
          const res = await axios.post(`${apiUrlBase}/health`, {
            headers: { 'Content-Type': APPLICATION_JSON }
          });
          expect(res.status).toBe(200);
          expect(res.data).toEqual({ ok: true });
        });
      });

      describe('NetworkInfoHttpService', () => {
        beforeAll(async () => {
          port = await getPort();
          apiUrlBase = `http://localhost:${port}/network-info`;
          config = { listen: { port } };
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
          ogmiosCardanoNode = await getOgmiosCardanoNode(dnsResolver, logger, {
            ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME,
            serviceDiscoveryBackoffFactor: 1.1,
            serviceDiscoveryTimeout: 1000
          });
          const networkInfoProvider = new DbSyncNetworkInfoProvider(
            {
              cardanoNodeConfigPath,
              epochPollInterval: 10_000
            },
            { cache, cardanoNode, db: db!, logger }
          );

          httpServer = new HttpServer(config, {
            services: [new NetworkInfoHttpService({ networkInfoProvider })]
          });
          await httpServer.initialize();
          await httpServer.start();
        });

        afterAll(async () => {
          await db!.end();
          await cache.shutdown();
          await httpServer.shutdown();
        });

        it('ogmiosCardanoNode should be instance of a Proxy ', () => {
          expect(types.isProxy(ogmiosCardanoNode)).toEqual(true);
        });

        it('forwards the NetworkInfoHttpService health response', async () => {
          const res = await axios.post(`${apiUrlBase}/health`, {
            headers: { 'Content-Type': APPLICATION_JSON }
          });
          expect(res.status).toBe(200);
          expect(res.data).toEqual({ ok: true });
        });
      });
    });
  });

  describe('Ogmios-dependant services with static config', () => {
    let apiUrlBase: string;
    let ogmiosServer: http.Server;
    let ogmiosConnection: Connection;
    let txSubmitProvider: TxSubmitProvider;
    let ogmiosCardanoNode: OgmiosCardanoNode;
    let httpServer: HttpServer;
    let port: number;
    let db: Pool | undefined;
    let config: HttpServerConfig;

    beforeAll(async () => {
      ogmiosServer = createHealthyMockOgmiosServer();
      ogmiosConnection = Ogmios.createConnectionObject();
      await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
      await ogmiosServerReady(ogmiosConnection);
    });

    afterAll(async () => {
      await serverClosePromise(ogmiosServer);
    });

    describe('Established connection', () => {
      describe('TxSubmitHttpService', () => {
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

      describe('NetworkInfoHttpService', () => {
        beforeAll(async () => {
          port = await getPort();
          apiUrlBase = `http://localhost:${port}/network-info`;
          config = { listen: { port } };
          db = await getPool(dnsResolver, logger, {
            dbCacheTtl: 10_000,
            epochPollInterval: 1000,
            postgresConnectionString: process.env.POSTGRES_CONNECTION_STRING!,
            serviceDiscoveryBackoffFactor: 1.1,
            serviceDiscoveryTimeout: 1000
          });
          ogmiosCardanoNode = await getOgmiosCardanoNode(dnsResolver, logger, {
            ogmiosUrl: new URL(ogmiosConnection.address.webSocket),
            serviceDiscoveryBackoffFactor: 1.1,
            serviceDiscoveryTimeout: 1000
          });
          const networkInfoProvider = new DbSyncNetworkInfoProvider(
            {
              cardanoNodeConfigPath,
              epochPollInterval: 10_000
            },
            { cache, cardanoNode, db: db!, logger }
          );

          httpServer = new HttpServer(config, {
            services: [new NetworkInfoHttpService({ networkInfoProvider })]
          });
          await httpServer.initialize();
          await httpServer.start();
        });

        afterAll(async () => {
          await httpServer.shutdown();
          await serverClosePromise(ogmiosServer);
        });

        it('ogmiosCardanoNode should not be a instance of Proxy ', () => {
          expect(types.isProxy(ogmiosCardanoNode)).toEqual(false);
        });

        it('forwards the NetworkInfoHttpService health response', async () => {
          const res = await axios.post(`${apiUrlBase}/health`, {
            headers: { 'Content-Type': APPLICATION_JSON }
          });
          expect(res.status).toBe(200);
          expect(res.data).toEqual({ ok: true });
        });
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

  describe('OgmiosCardanoNode with service discovery and Ogmios server failover', () => {
    let mockServer: http.Server;
    let connection: Connection;
    let node: OgmiosCardanoNode;
    const ogmiosPortDefault = 1337;

    beforeEach(async () => {
      connection = Ogmios.createConnectionObject({ port: ogmiosPortDefault });
      // Setup working a default Ogmios with healthCheck operation throwing a non-connection error
      mockServer = createMockOgmiosServer({
        stateQuery: {
          eraSummaries: {
            response: {
              success: true
            }
          },
          systemStart: { response: { success: true } }
        }
      });
      await listenPromise(mockServer, connection);
      await ogmiosServerReady(connection);
    });

    afterEach(async () => {
      if (mockServer !== undefined) {
        await serverClosePromise(mockServer);
      }
    });

    it('should initially fail with a connection error, then re-resolve the port and initialize', async () => {
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

      node = await getOgmiosCardanoNode(dnsResolverMock, logger, {
        ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });

      await expect(node.initialize()).resolves.toBeUndefined();
      expect(dnsResolverMock).toBeCalledTimes(2);
      await node.shutdown();
    });

    it('should initially fail with a connection error, then re-resolve the port and resolve eraSummaries', async () => {
      const srvRecord = { name: 'localhost', port: ogmiosPortDefault, priority: 1, weight: 1 };
      const failingOgmiosMockPort = await getRandomPort();
      let resolverAlreadyCalled = false;

      const failingConnection = Ogmios.createConnectionObject({ port: failingOgmiosMockPort });
      // Setup second Ogmios mock server with passing 'initialize' and 'systemStart' but 'eraSummaries' operation throws a connection error
      const failingMockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.999, success: true } },
        stateQuery: {
          eraSummaries: {
            response: {
              failWith: {
                type: 'connectionError'
              },
              success: false
            }
          },
          systemStart: { response: { success: true } }
        }
      });
      await listenPromise(failingMockServer, failingConnection);
      await ogmiosServerReady(failingConnection);

      // Initially resolves with a failing ogmios port, then swap to the default one
      const dnsResolverMock = jest.fn().mockImplementation(async () => {
        if (!resolverAlreadyCalled) {
          resolverAlreadyCalled = true;
          return { ...srvRecord, port: failingOgmiosMockPort };
        }
        return srvRecord;
      });

      node = await getOgmiosCardanoNode(dnsResolverMock, logger, {
        ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });

      // The Inizialization beforehand is mandatory for the sequential Cardano Node State Query Client's operations
      await node.initialize();

      await expect(node.eraSummaries()).resolves.toBeDefined();
      expect(dnsResolverMock).toBeCalledTimes(2);
      await node.shutdown();
      await serverClosePromise(failingMockServer);
    });

    it('should execute a provider operation without to intercept it', async () => {
      node = await getOgmiosCardanoNode(dnsResolver, logger, {
        ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });
      await node.initialize();
      await expect(node.shutdown()).resolves.toBeUndefined();
    });
  });
});
