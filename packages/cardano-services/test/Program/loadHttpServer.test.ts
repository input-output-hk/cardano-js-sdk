/* eslint-disable max-len */
import { CACHE_TTL_DEFAULT } from '../../src/InMemoryCache';
import { Connection } from '@cardano-ogmios/client';
import { DB_POLL_INTERVAL_DEFAULT } from '../../src/NetworkInfo';
import { HttpServer } from '../../src';
import {
  InvalidArgsCombination,
  MissingProgramOption,
  SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT,
  SERVICE_DISCOVERY_BACKOFF_TIMEOUT_DEFAULT,
  ServiceNames,
  loadHttpServer
} from '../../src/Program';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { SrvRecord } from 'dns';
import { URL } from 'url';
import {
  createConnectionObjectWithRandomPort,
  createHealthyMockOgmiosServer,
  createUnhealthyMockOgmiosServer,
  ogmiosServerReady
} from '../util';
import { getRandomPort } from 'get-port-please';
import { listenPromise, serverClosePromise } from '../../src/util';
import http from 'http';

jest.mock('dns', () => ({
  promises: {
    resolveSrv: async (): Promise<SrvRecord[]> => [{ name: 'localhost', port: 5433, priority: 6, weight: 5 }]
  }
}));

describe('loadHttpServer', () => {
  let apiUrl: URL;
  let cardanoNodeConfigPath: string;
  let dbConnectionString: string;
  let postgresSrvServiceName: string;
  let postgresName: string;
  let postgresUser: string;
  let postgresPassword: string;
  let dbQueriesCacheTtl: number;
  let dbPollInterval: number;
  let httpServer: HttpServer;
  let ogmiosConnection: Connection;
  let ogmiosSrvServiceName: string;
  let ogmiosServer: http.Server;
  let serviceDiscoveryBackoffFactor: number;
  let serviceDiscoveryTimeout: number;
  let rabbitmqSrvServiceName: string;
  let rabbitmqUrl: URL;

  beforeEach(async () => {
    apiUrl = new URL(`http://localhost:${await getRandomPort()}`);
    dbConnectionString = process.env.DB_CONNECTION_STRING!;
    postgresSrvServiceName = process.env.POSTGRES_SRV_SERVICE_NAME!;
    postgresName = process.env.POSTGRES_NAME!;
    postgresUser = process.env.POSTGRES_USER!;
    postgresPassword = process.env.POSTGRES_PASSWORD!;
    cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
    ogmiosConnection = await createConnectionObjectWithRandomPort();
    ogmiosSrvServiceName = process.env.OGMIOS_SRV_SERVICE_NAME!;
    dbQueriesCacheTtl = CACHE_TTL_DEFAULT;
    dbPollInterval = DB_POLL_INTERVAL_DEFAULT;
    serviceDiscoveryBackoffFactor = SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT;
    serviceDiscoveryTimeout = SERVICE_DISCOVERY_BACKOFF_TIMEOUT_DEFAULT;
    rabbitmqUrl = new URL(process.env.RABBITMQ_URL!);
    rabbitmqSrvServiceName = process.env.RABBITMQ_SRV_SERVICE_NAME!;
  });

  describe('healthy internal providers', () => {
    beforeEach(async () => {
      ogmiosServer = createHealthyMockOgmiosServer();
      await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
      await ogmiosServerReady(ogmiosConnection);
    });

    afterEach(async () => {
      await serverClosePromise(ogmiosServer);
    });

    it('loads the nominated HTTP services and server if required program arguments are set', async () => {
      httpServer = await loadHttpServer({
        apiUrl,
        options: {
          cardanoNodeConfigPath,
          dbConnectionString,
          dbPollInterval,
          dbQueriesCacheTtl,
          ogmiosUrl: new URL(ogmiosConnection.address.webSocket),
          serviceDiscoveryBackoffFactor,
          serviceDiscoveryTimeout
        },
        serviceNames: [
          ServiceNames.StakePool,
          ServiceNames.TxSubmit,
          ServiceNames.ChainHistory,
          ServiceNames.Utxo,
          ServiceNames.NetworkInfo,
          ServiceNames.Rewards
        ]
      });
      expect(httpServer).toBeInstanceOf(HttpServer);
    });

    describe('postgres-dependent services', () => {
      it('loads the nominated HTTP service and server if all required postgres srv args are set', async () => {
        httpServer = await loadHttpServer({
          apiUrl,
          options: {
            dbPollInterval,
            dbQueriesCacheTtl,
            postgresName,
            postgresPassword,
            postgresSrvServiceName,
            postgresUser,
            serviceDiscoveryBackoffFactor,
            serviceDiscoveryTimeout
          },
          serviceNames: [ServiceNames.StakePool]
        });

        expect(httpServer).toBeInstanceOf(HttpServer);
      });

      it('throws if dns port resolution is used but one of the postgres args is missing', async () => {
        const missingPostgresName = undefined;

        await expect(
          async () =>
            await loadHttpServer({
              apiUrl,
              options: {
                dbPollInterval,
                dbQueriesCacheTtl,
                postgresName: missingPostgresName,
                postgresSrvServiceName,
                postgresUser,
                serviceDiscoveryBackoffFactor,
                serviceDiscoveryTimeout
              },
              serviceNames: [ServiceNames.StakePool]
            })
        ).rejects.toThrow(MissingProgramOption);
      });

      it('throws if a service is nominated without providing db connection string nor postgres srv service name', async () => {
        await expect(
          async () =>
            await loadHttpServer({
              apiUrl,
              options: {
                dbPollInterval,
                dbQueriesCacheTtl,
                serviceDiscoveryBackoffFactor,
                serviceDiscoveryTimeout
              },
              serviceNames: [ServiceNames.StakePool]
            })
        ).rejects.toThrow(MissingProgramOption);
      });

      it('throws if a service is nominated with providing both db connection string and postgres srv service name at same time', async () => {
        await expect(
          async () =>
            await loadHttpServer({
              apiUrl,
              options: {
                dbConnectionString,
                dbPollInterval,
                dbQueriesCacheTtl,
                postgresSrvServiceName,
                serviceDiscoveryBackoffFactor,
                serviceDiscoveryTimeout
              },
              serviceNames: [ServiceNames.StakePool]
            })
        ).rejects.toThrow(InvalidArgsCombination);
      });
    });

    describe('ogmios-dependent services', () => {
      it('loads the nominated HTTP service and server if ogmios srv service name arg is set', async () => {
        httpServer = await loadHttpServer({
          apiUrl,
          options: {
            dbPollInterval,
            dbQueriesCacheTtl,
            ogmiosSrvServiceName,
            serviceDiscoveryBackoffFactor,
            serviceDiscoveryTimeout
          },
          serviceNames: [ServiceNames.TxSubmit]
        });

        expect(httpServer).toBeInstanceOf(HttpServer);
      });

      it('throws if a service is nominated without providing ogmios url nor srv service name', async () => {
        await expect(
          async () =>
            await loadHttpServer({
              apiUrl,
              options: {
                dbPollInterval,
                dbQueriesCacheTtl,
                serviceDiscoveryBackoffFactor,
                serviceDiscoveryTimeout
              },
              serviceNames: [ServiceNames.TxSubmit]
            })
        ).rejects.toThrow(MissingProgramOption);
      });

      it('throws if a service is nominated with providing both ogmios url and srv service name at same time', async () => {
        await expect(
          async () =>
            await loadHttpServer({
              apiUrl,
              options: {
                dbPollInterval,
                dbQueriesCacheTtl,
                ogmiosSrvServiceName,
                ogmiosUrl: new URL(ogmiosConnection.address.webSocket),
                serviceDiscoveryBackoffFactor,
                serviceDiscoveryTimeout
              },
              serviceNames: [ServiceNames.TxSubmit]
            })
        ).rejects.toThrow(InvalidArgsCombination);
      });
    });

    describe('rabbitmq-dependent services', () => {
      it('loads the nominated HTTP service and server if rabbitmq srv service name arg is set', async () => {
        httpServer = await loadHttpServer({
          apiUrl,
          options: {
            dbPollInterval,
            dbQueriesCacheTtl,
            rabbitmqSrvServiceName,
            serviceDiscoveryBackoffFactor,
            serviceDiscoveryTimeout,
            useQueue: true
          },
          serviceNames: [ServiceNames.TxSubmit]
        });

        expect(httpServer).toBeInstanceOf(HttpServer);
      });

      it('throws if a service is nominated without providing rabbitmq url nor srv service name', async () => {
        await expect(
          async () =>
            await loadHttpServer({
              apiUrl,
              options: {
                dbPollInterval,
                dbQueriesCacheTtl,
                serviceDiscoveryBackoffFactor,
                serviceDiscoveryTimeout,
                useQueue: true
              },
              serviceNames: [ServiceNames.TxSubmit]
            })
        ).rejects.toThrow(MissingProgramOption);
      });

      it('throws if a service is nominated with providing both rabbitmq url and srv service name at same time', async () => {
        await expect(
          async () =>
            await loadHttpServer({
              apiUrl,
              options: {
                dbPollInterval,
                dbQueriesCacheTtl,
                rabbitmqSrvServiceName,
                rabbitmqUrl,
                serviceDiscoveryBackoffFactor,
                serviceDiscoveryTimeout,
                useQueue: true
              },
              serviceNames: [ServiceNames.TxSubmit]
            })
        ).rejects.toThrow(InvalidArgsCombination);
      });
    });

    it('throws if genesis-config dependent service is nominated without providing the node config path', async () => {
      await expect(
        async () =>
          await loadHttpServer({
            apiUrl,
            options: {
              dbPollInterval,
              dbQueriesCacheTtl,
              serviceDiscoveryBackoffFactor,
              serviceDiscoveryTimeout
            },
            serviceNames: [ServiceNames.NetworkInfo]
          })
      ).rejects.toThrow(MissingProgramOption);
    });
  });

  describe('unhealthy internal providers', () => {
    beforeEach(async () => {
      ogmiosServer = createUnhealthyMockOgmiosServer();
      await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
      await ogmiosServerReady(ogmiosConnection);
    });

    afterEach(async () => {
      await serverClosePromise(ogmiosServer);
    });

    it('should not throw if any internal providers are unhealthy during HTTP server initialization', async () => {
      expect(
        async () =>
          await loadHttpServer({
            apiUrl,
            options: {
              dbConnectionString,
              dbPollInterval,
              dbQueriesCacheTtl,
              ogmiosUrl: new URL(ogmiosConnection.address.webSocket),
              serviceDiscoveryBackoffFactor,
              serviceDiscoveryTimeout
            },
            serviceNames: [ServiceNames.StakePool, ServiceNames.TxSubmit]
          })
      ).not.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });
});
