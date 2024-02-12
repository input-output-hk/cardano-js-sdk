/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
import { Connection } from '@cardano-ogmios/client';
import { DbPools, LedgerTipModel, findLedgerTip } from '../../../src/util/DbSyncProvider';
import { DbSyncEpochPollService, listenPromise, loadGenesisData, serverClosePromise } from '../../../src/util';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../../src/NetworkInfo';
import {
  HttpServer,
  HttpServerConfig,
  TxSubmitHttpService,
  createDnsResolver,
  getOgmiosCardanoNode,
  getPool
} from '../../../src';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../../src/InMemoryCache';
import { Ogmios, OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { SrvRecord } from 'dns';
import { TxSubmissionError, TxSubmitProvider } from '@cardano-sdk/core';
import { bufferToHexString } from '@cardano-sdk/util';
import { clearDbPools, servicesWithVersionPath as services } from '../../util';
import { getPort, getRandomPort } from 'get-port-please';
import { handleProviderMocks, logger } from '@cardano-sdk/util-dev';
import { healthCheckResponseMock } from '../../../../core/test/CardanoNode/mocks';
import { mockDnsResolverFactory } from './util';
import { types } from 'util';
import axios from 'axios';
import http from 'http';

jest.mock('@cardano-sdk/cardano-services-client', () => ({
  ...jest.requireActual('@cardano-sdk/cardano-services-client'),
  KoraLabsHandleProvider: jest.fn().mockImplementation(() => ({
    healthCheck: jest.fn(),
    resolveHandles: jest.fn().mockResolvedValue([handleProviderMocks.getAliceHandleProviderResponse])
  }))
}));

// TODO: use a mock handle provider
// const handleProvider = new KoraLabsHandleProvider({
//   policyId: Cardano.PolicyId('50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb'),
//   serverUrl: 'https://localhost:3000'
// });

jest.mock('dns', () => ({
  promises: {
    resolveSrv: async (serviceName: string): Promise<SrvRecord[]> => {
      if (serviceName === process.env.POSTGRES_SRV_SERVICE_NAME_DB_SYNC)
        return [{ name: 'localhost', port: 5433, priority: 6, weight: 5 }];
      if (serviceName === process.env.OGMIOS_SRV_SERVICE_NAME)
        return [{ name: 'localhost', port: 1337, priority: 6, weight: 5 }];
      return [];
    }
  }
}));

describe.skip('Service dependency abstractions', () => {
  const APPLICATION_JSON = 'application/json';
  const cache = { db: new InMemoryCache(UNLIMITED_CACHE_TTL), healthCheck: new InMemoryCache(UNLIMITED_CACHE_TTL) };
  const cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
  const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);
  let lastBlockNoInDb: LedgerTipModel;
  let dbPools: DbPools;

  const ogmiosPortDefault = 1337;
  const mockDnsResolver = mockDnsResolverFactory(ogmiosPortDefault);

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

    lastBlockNoInDb = (await dbPools.main!.query<LedgerTipModel>(findLedgerTip)).rows[0];
  });

  afterAll(async () => {
    await clearDbPools(dbPools);
  });

  // TODO: rewrite these tests to not require ogmios server.
  // It is sufficient to unit test the logic of utils exported from ogmios.ts
  describe.skip('Ogmios-dependant services with service discovery', () => {
    let apiUrlBase: string;
    let ogmiosServer: http.Server;
    let ogmiosConnection: Connection;
    let txSubmitProvider: TxSubmitProvider;
    let ogmiosCardanoNode: OgmiosCardanoNode;
    let httpServer: HttpServer;
    let port: number;
    let config: HttpServerConfig;

    beforeAll(async () => {
      // ogmiosServer = createHealthyMockOgmiosServer();
      ogmiosConnection = Ogmios.createConnectionObject();
      await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
      // await ogmiosServerReady(ogmiosConnection);
    });

    afterAll(async () => {
      await serverClosePromise(ogmiosServer);
    });

    describe('Established connection', () => {
      describe('TxSubmitHttpService', () => {
        beforeAll(async () => {
          port = await getPort();
          apiUrlBase = `http://localhost:${port}${services.txSubmit.versionPath}/${services.txSubmit.name}`;
          config = { listen: { port } };
          // txSubmitProvider = await getOgmiosTxSubmitProvider(dnsResolver, logger, {
          //   ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
          // });
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

        it.skip('txSubmitProvider state should be running when http server has started', () => {
          // expect(txSubmitProvider.state).toEqual('running');
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
          apiUrlBase = `http://localhost:${port}${services.networkInfo.versionPath}/${services.networkInfo.name}`;
          config = { listen: { port } };
          ogmiosCardanoNode = await getOgmiosCardanoNode(dnsResolver, logger, {
            ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
          });
          const genesisData = await loadGenesisData(cardanoNodeConfigPath);
          const epochMonitor = new DbSyncEpochPollService(dbPools.main!, 10_000);
          const networkInfoProvider = new DbSyncNetworkInfoProvider({
            cache,
            cardanoNode: ogmiosCardanoNode,
            dbPools,
            epochMonitor,
            genesisData,
            logger
          });

          httpServer = new HttpServer(config, {
            logger,
            runnableDependencies: [ogmiosCardanoNode],
            services: [new NetworkInfoHttpService({ logger, networkInfoProvider })]
          });
          await httpServer.initialize();
          await httpServer.start();
        });

        afterAll(async () => {
          await cache.db.shutdown();
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
    let txSubmitProvider: TxSubmitProvider;
    let ogmiosCardanoNode: OgmiosCardanoNode;
    let httpServer: HttpServer;
    let port: number;
    let config: HttpServerConfig;

    beforeAll(async () => {
      // ogmiosServer = createHealthyMockOgmiosServer();
      ogmiosConnection = Ogmios.createConnectionObject();
      await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
      // await ogmiosServerReady(ogmiosConnection);
      lastBlockNoInDb = (await dbPools.main!.query<LedgerTipModel>(findLedgerTip)).rows[0];
    });

    afterAll(async () => {
      await serverClosePromise(ogmiosServer);
    });

    describe('Established connection', () => {
      describe('TxSubmitHttpService', () => {
        beforeAll(async () => {
          port = await getPort();
          apiUrlBase = `http://localhost:${port}${services.txSubmit.versionPath}/${services.txSubmit.name}`;
          config = { listen: { port } };
          // txSubmitProvider = await getOgmiosTxSubmitProvider(dnsResolver, logger, {
          //   ogmiosUrl: new URL(ogmiosConnection.address.webSocket)
          // });
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

        it.skip('verifies that the submitted transaction addresses can all correctly be resolved', async () => {
          // const provider = await getOgmiosTxSubmitProvider(
          //   dnsResolver,
          //   logger,
          //   {
          //     ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
          //   },
          //   handleProvider
          // );
          // await provider.initialize();
          // await provider.start();
          // const res = await provider.submitTx({
          //   context: { handleResolutions: [handleProviderMocks.getAliceHandleProviderResponse] },
          //   signedTransaction: bufferToHexString(Buffer.from(new Uint8Array([])))
          // });
          // expect(res).toBeUndefined();
          // await provider.shutdown();
        });

        it.skip('throws a provider error if the submitted transaction does not contain addresses that can be resolved from the included context', async () => {
          // const provider = await getOgmiosTxSubmitProvider(
          //  dnsResolver,
          //  logger,
          //  {
          //    ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
          //  },
          //  {
          //    getPolicyIds: async () => [],
          //    healthCheck: async () => ({ ok: true }),
          //    resolveHandles: async ({ handles }) => handles.map(() => null)
          //  }
          // );
          // await provider.initialize();
          // await provider.start();
          // await expect(
          //  provider.submitTx({
          //    context: { handleResolutions: [handleProviderMocks.getWrongHandleProviderResponse] },
          //    signedTransaction: bufferToHexString(Buffer.from(new Uint8Array([])))
          //  })
          // ).rejects.toBeInstanceOf(ProviderError);
          // await provider.shutdown();
        });
      });

      describe('NetworkInfoHttpService', () => {
        beforeAll(async () => {
          port = await getPort();
          apiUrlBase = `http://localhost:${port}${services.networkInfo.versionPath}/${services.networkInfo.name}`;
          config = { listen: { port } };

          ogmiosCardanoNode = await getOgmiosCardanoNode(dnsResolver, logger, {
            ogmiosUrl: new URL(ogmiosConnection.address.webSocket)
          });
          const genesisData = await loadGenesisData(cardanoNodeConfigPath);
          const epochMonitor = new DbSyncEpochPollService(dbPools.main!, 10_000);
          const deps = {
            cache,
            cardanoNode: ogmiosCardanoNode,
            dbPools,
            epochMonitor,
            genesisData,
            logger
          };
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
    let provider: TxSubmitProvider;

    beforeEach(async () => {
      connection = Ogmios.createConnectionObject({ port: ogmiosPortDefault });
      // Setup working a default Ogmios with submitTx operation throwing a non-connection error
      // mockServer = createMockOgmiosServer({
      //   healthCheck: { response: { networkSynchronization: 0.999, success: true } },
      //   submitTx: { response: { failWith: { type: 'eraMismatch' }, success: false } }
      // });
      await listenPromise(mockServer, connection);
      // await ogmiosServerReady(connection);
    });

    afterEach(async () => {
      if (mockServer !== undefined) {
        await serverClosePromise(mockServer);
      }
    });

    it.skip('should resolve DNS twice during initialization without reconnection logic with long ws connection type', async () => {
      // Resolves with a failing ogmios port twice, then swap to the default one
      const dnsResolverMock = await mockDnsResolver(2);

      // provider = await getOgmiosTxSubmitProvider(dnsResolverMock, logger, {
      //   ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
      // });

      // await expect(provider.initialize()).resolves.toBeUndefined();
      expect(dnsResolverMock).toBeCalledTimes(3);
      // await provider.start();
      // await provider.shutdown();
    });

    it.skip('should initially fail with a connection error, then re-resolve the port and propagate the correct non-connection error to the caller', async () => {
      // Resolves with a failing ogmios port twice, then swap to the default one
      const dnsResolverMock = await mockDnsResolver(2);

      // provider = await getOgmiosTxSubmitProvider(dnsResolverMock, logger, {
      //   ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
      // });

      // await provider.initialize();
      // await provider.start();
      await expect(
        provider.submitTx({ signedTransaction: bufferToHexString(Buffer.from(new Uint8Array([]))) })
      ).rejects.toBeInstanceOf(TxSubmissionError);
      expect(dnsResolverMock).toBeCalledTimes(3);
      // await provider.shutdown();
    });

    it.skip('should execute a provider operation without to intercept it', async () => {
      // provider = await getOgmiosTxSubmitProvider(dnsResolver, logger, {
      //   ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
      // });

      await expect(provider.healthCheck()).resolves.toEqual(healthCheckResponseMock({ withTip: false }));
    });
  });

  describe('OgmiosCardanoNode with service discovery and Ogmios server failover', () => {
    let mockServer: http.Server;
    let connection: Connection;
    let node: OgmiosCardanoNode;

    beforeEach(async () => {
      connection = Ogmios.createConnectionObject({ port: ogmiosPortDefault });
      // Setup working a default Ogmios with stateQuery eraSummaries operation throwing a non-connection error
      // mockServer = createMockOgmiosServer({
      //   healthCheck: { response: { networkSynchronization: 0.999, success: true } },
      //   stateQuery: {
      //     eraSummaries: { response: { failWith: { type: 'unknownResultError' }, success: false } },
      //     systemStart: { response: { success: true } }
      //   }
      // });
      await listenPromise(mockServer, connection);
      // await ogmiosServerReady(connection);
    });

    afterEach(async () => {
      if (mockServer !== undefined) {
        await serverClosePromise(mockServer);
      }
    });

    it('should initially fail with a connection error, then re-resolve the port and initialize', async () => {
      // Resolves with a failing ogmios port twice, then swap to the default one
      const dnsResolverMock = await mockDnsResolver(2);

      node = await getOgmiosCardanoNode(dnsResolverMock, logger, {
        ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
      });

      await expect(node.initialize()).resolves.toBeUndefined();
      expect(dnsResolverMock).toBeCalledTimes(3);
      await node.start();
      await node.shutdown();
    });

    it('should initially fail with a connection error, then re-resolve the port and propagate the correct non-connection error to the caller', async () => {
      const failingOgmiosMockPort = await getRandomPort();
      // const failConnection = Ogmios.createConnectionObject({ port: failingOgmiosMockPort });
      // const failMockServer = createMockOgmiosServer({
      //   healthCheck: { response: { networkSynchronization: 0.999, success: true } },
      //   stateQuery: {
      //     systemStart: { response: { success: true } }
      //   }
      // });
      // await listenPromise(failMockServer, failConnection);
      // await ogmiosServerReady(failConnection);

      // Resolves with a failing ogmios port twice, then swap to the default one
      const dnsResolverMock = await mockDnsResolver(2, failingOgmiosMockPort);

      node = await getOgmiosCardanoNode(dnsResolverMock, logger, {
        ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME
      });

      await node.initialize();
      await node.start();
      // for (const socket of failMockServer.wss.clients) {
      //   socket.close();
      // }
      // await serverClosePromise(failMockServer);
      // await expect(node.eraSummaries()).rejects.toBeInstanceOf(
      //   CardanoNodeErrors.CardanoClientErrors.UnknownResultError
      // );
      expect(dnsResolverMock).toBeCalledTimes(3);
      await node.shutdown();
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
