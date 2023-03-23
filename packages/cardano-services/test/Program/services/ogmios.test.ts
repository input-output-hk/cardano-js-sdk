/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
import { CardanoNodeErrors } from '@cardano-sdk/core';
import { Connection } from '@cardano-ogmios/client';
import { DbSyncEpochPollService, listenPromise, loadGenesisData, serverClosePromise } from '../../../src/util';
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
import { LedgerTipModel, findLedgerTip } from '../../../src/util/DbSyncProvider';
import { Ogmios, OgmiosCardanoNode, OgmiosTxSubmitProvider } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { SrvRecord } from 'dns';
import { bufferToHexString } from '@cardano-sdk/util';
import { createHealthyMockOgmiosServer, ogmiosServerReady } from '../../util';
import { createMockOgmiosServer } from '../../../../ogmios/test/mocks/mockOgmiosServer';
import { getPort, getRandomPort } from 'get-port-please';
import { healthCheckResponseMock } from '../../../../core/test/CardanoNode/mocks';
import { logger } from '@cardano-sdk/util-dev';
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
  const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);
  let lastBlockNoInDb: LedgerTipModel;
  let db: Pool | undefined;

  beforeAll(async () => {
    db = await getPool(dnsResolver, logger, {
      postgresDb: process.env.POSTGRES_DB!,
      postgresPassword: process.env.POSTGRES_PASSWORD!,
      postgresSrvServiceName: process.env.POSTGRES_SRV_SERVICE_NAME!,
      postgresUser: process.env.POSTGRES_USER!
    });

    lastBlockNoInDb = (await db!.query<LedgerTipModel>(findLedgerTip)).rows[0];
  });

  afterAll(async () => {
    await db!.end();
  });

  describe('Ogmios-dependant services with service discovery', () => {
    let apiUrlBase: string;
    let ogmiosServer: http.Server;
    let ogmiosConnection: Connection;
    let txSubmitProvider: OgmiosTxSubmitProvider;
    let ogmiosCardanoNode: OgmiosCardanoNode;
    let httpServer: HttpServer;
    let port: number;
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
            ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
          });
          httpServer = new HttpServer(config, {
            logger,
            runnableDependencies: [],
            services: [new TxSubmitHttpService({ logger, txSubmitProvider })]
          });
          await httpServer.initialize();
          await httpServer.start();
        });

        afterAll(async () => {
          await httpServer.shutdown();
        });

        it('txSubmitProvider state should be running when http server has started', () => {
          expect(txSubmitProvider.state).toEqual('running');
        });

        it('txSubmitProvider should be instance of a Proxy ', () => {
          expect(types.isProxy(txSubmitProvider)).toEqual(true);
        });

        it('forwards the TxSubmitHttpService health response', async () => {
          const res = await axios.post(`${apiUrlBase}/health`, {
            headers: { 'Content-Type': APPLICATION_JSON }
          });
          expect(res.status).toBe(200);
          expect(res.data).toEqual(healthCheckResponseMock({ withTip: false }));
        });

        it('TxSubmitHttpService replies with status 200 OK when /submit endpoint is reached', async () => {
          const res = await axios.post(
            `${apiUrlBase}/submit`,
            { signedTransaction: bufferToHexString(Buffer.from(new Uint8Array())) },
            { headers: { 'Content-Type': APPLICATION_JSON } }
          );
          expect(res.status).toBe(200);
        });
      });

      describe('NetworkInfoHttpService', () => {
        beforeAll(async () => {
          port = await getPort();
          apiUrlBase = `http://localhost:${port}/network-info`;
          config = { listen: { port } };
          ogmiosCardanoNode = await getOgmiosCardanoNode(dnsResolver, logger, {
            ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
          });
          const genesisData = await loadGenesisData(cardanoNodeConfigPath);
          const epochMonitor = new DbSyncEpochPollService(db!, 10_000);
          const deps = { cache, cardanoNode: ogmiosCardanoNode, db: db!, epochMonitor, genesisData, logger };
          const networkInfoProvider = new DbSyncNetworkInfoProvider(deps);

          httpServer = new HttpServer(config, {
            logger,
            runnableDependencies: [ogmiosCardanoNode],
            services: [new NetworkInfoHttpService({ logger, networkInfoProvider })]
          });
          await httpServer.initialize();
          await httpServer.start();
        });

        afterAll(async () => {
          await cache.shutdown();
          await httpServer.shutdown();
        });

        it('ogmiosCardanoNode state should be running when http server has started', () => {
          expect(ogmiosCardanoNode.state).toEqual('running');
        });

        it('ogmiosCardanoNode should be instance of a Proxy ', () => {
          expect(types.isProxy(ogmiosCardanoNode)).toEqual(true);
        });

        it('forwards the NetworkInfoHttpService health response', async () => {
          const res = await axios.post(`${apiUrlBase}/health`, {
            headers: { 'Content-Type': APPLICATION_JSON }
          });
          expect(res.status).toBe(200);
          expect(res.data).toEqual(
            healthCheckResponseMock({
              projectedTip: {
                blockNo: lastBlockNoInDb.block_no,
                hash: lastBlockNoInDb.hash.toString('hex'),
                slot: Number(lastBlockNoInDb.slot_no)
              },
              withTip: true
            })
          );
        });

        it('NetworkInfoHttpService replies with status 200 OK when /stake endpoint is reached', async () => {
          const res = await axios.post(`${apiUrlBase}/stake`, undefined, {
            headers: { 'Content-Type': APPLICATION_JSON }
          });
          expect(res.status).toBe(200);
        });
      });
    });
  });

  describe('Ogmios-dependant services with static config', () => {
    let apiUrlBase: string;
    let ogmiosServer: http.Server;
    let ogmiosConnection: Connection;
    let txSubmitProvider: OgmiosTxSubmitProvider;
    let ogmiosCardanoNode: OgmiosCardanoNode;
    let httpServer: HttpServer;
    let port: number;
    let config: HttpServerConfig;

    beforeAll(async () => {
      ogmiosServer = createHealthyMockOgmiosServer();
      ogmiosConnection = Ogmios.createConnectionObject();
      await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
      await ogmiosServerReady(ogmiosConnection);
      lastBlockNoInDb = (await db!.query<LedgerTipModel>(findLedgerTip)).rows[0];
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
            logger,
            runnableDependencies: [],
            services: [new TxSubmitHttpService({ logger, txSubmitProvider })]
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
          expect(res.data).toEqual(healthCheckResponseMock({ withTip: false }));
        });
      });

      describe('NetworkInfoHttpService', () => {
        beforeAll(async () => {
          port = await getPort();
          apiUrlBase = `http://localhost:${port}/network-info`;
          config = { listen: { port } };

          ogmiosCardanoNode = await getOgmiosCardanoNode(dnsResolver, logger, {
            ogmiosUrl: new URL(ogmiosConnection.address.webSocket)
          });
          const genesisData = await loadGenesisData(cardanoNodeConfigPath);
          const epochMonitor = new DbSyncEpochPollService(db!, 10_000);
          const deps = { cache, cardanoNode: ogmiosCardanoNode, db: db!, epochMonitor, genesisData, logger };
          const networkInfoProvider = new DbSyncNetworkInfoProvider(deps);

          httpServer = new HttpServer(config, {
            logger,
            runnableDependencies: [ogmiosCardanoNode],
            services: [new NetworkInfoHttpService({ logger, networkInfoProvider })]
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
          expect(res.data).toEqual(
            healthCheckResponseMock({
              projectedTip: {
                blockNo: lastBlockNoInDb.block_no,
                hash: lastBlockNoInDb.hash.toString('hex'),
                slot: Number(lastBlockNoInDb.slot_no)
              },
              withTip: true
            })
          );
        });
      });
    });
  });

  describe('TxSubmitProvider with service discovery and Ogmios server failover', () => {
    let mockServer: http.Server;
    let connection: Connection;
    let provider: OgmiosTxSubmitProvider;
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

    it('should resolve initialize without reconnection logic with one time ws connection type', async () => {
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
        ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
      });

      await expect(provider.initialize()).resolves.toBeUndefined();
      // This test should fail once we switch to a long-running ws connection
      // dnsResolverMock should be called twice and try to dns resolve
      // while init the txSubmitClient within `provider.initialize()`
      expect(dnsResolverMock).toBeCalledTimes(1);
      await provider.start();
      await provider.shutdown();
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
        ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
      });

      await provider.initialize();
      await provider.start();
      await expect(
        provider.submitTx({ signedTransaction: bufferToHexString(Buffer.from(new Uint8Array([]))) })
      ).rejects.toBeInstanceOf(CardanoNodeErrors.TxSubmissionErrors.EraMismatchError);
      expect(dnsResolverMock).toBeCalledTimes(2);
      await provider.shutdown();
    });

    it('should execute a provider operation without to intercept it', async () => {
      provider = await getOgmiosTxSubmitProvider(dnsResolver, logger, {
        ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
      });

      await expect(provider.healthCheck()).resolves.toEqual(healthCheckResponseMock({ withTip: false }));
    });
  });

  describe('OgmiosCardanoNode with service discovery and Ogmios server failover', () => {
    let mockServer: http.Server;
    let connection: Connection;
    let node: OgmiosCardanoNode;
    const ogmiosPortDefault = 1337;

    beforeEach(async () => {
      connection = Ogmios.createConnectionObject({ port: ogmiosPortDefault });
      // Setup working a default Ogmios with stateQuery eraSummaries operation throwing a non-connection error
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.999, success: true } },
        stateQuery: {
          eraSummaries: { response: { failWith: { type: 'unknownResultError' }, success: false } },
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
        ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
      });

      await expect(node.initialize()).resolves.toBeUndefined();
      expect(dnsResolverMock).toBeCalledTimes(2);
      await node.start();
      await node.shutdown();
    });

    it('should initially fail with a connection error, then re-resolve the port and propagate the correct non-connection error to the caller', async () => {
      const failingOgmiosMockPort = await getRandomPort();
      const failConnection = Ogmios.createConnectionObject({ port: failingOgmiosMockPort });
      const failMockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.999, success: true } },
        stateQuery: {
          eraSummaries: { response: { failWith: { type: 'connectionError' }, success: false } },
          systemStart: { response: { success: true } }
        }
      });
      await listenPromise(failMockServer, failConnection);
      await ogmiosServerReady(failConnection);

      const srvRecord = { name: 'localhost', port: ogmiosPortDefault, priority: 1, weight: 1 };
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
        ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
      });

      await node.initialize();
      await node.start();
      await expect(node.eraSummaries()).rejects.toBeInstanceOf(
        CardanoNodeErrors.CardanoClientErrors.UnknownResultError
      );
      expect(dnsResolverMock).toBeCalledTimes(2);
      await node.shutdown();

      await serverClosePromise(failMockServer);
    });

    it('should execute a provider operation without to intercept it', async () => {
      node = await getOgmiosCardanoNode(dnsResolver, logger, {
        ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
      });
      await node.initialize();
      await node.start();
      await expect(node.shutdown()).resolves.toBeUndefined();
    });
  });
});
