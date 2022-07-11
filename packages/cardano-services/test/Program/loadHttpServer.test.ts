/* eslint-disable max-len */
/* eslint-disable sonarjs/no-duplicate-string */
import { CACHE_TTL_DEFAULT } from '../../src/InMemoryCache';
import { Connection } from '@cardano-sdk/ogmios';
import { EPOCH_POLL_INTERVAL_DEFAULT } from '../../src/NetworkInfo';
import { HttpServer } from '../../src';
import {
  InvalidArgsCombination,
  MissingProgramOption,
  ProgramOptionDescriptions,
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
  let postgresDb: string;
  let postgresUser: string;
  let postgresPassword: string;
  let cacheTtl: number;
  let epochPollInterval: number;
  let httpServer: HttpServer;
  let ogmiosConnection: Connection;
  let ogmiosSrvServiceName: string;
  let ogmiosServer: http.Server;
  let serviceDiscoveryBackoffFactor: number;
  let serviceDiscoveryBackoffTimeout: number;
  let rabbitmqSrvServiceName: string;
  let rabbitmqUrl: URL;

  beforeEach(async () => {
    apiUrl = new URL(`http://localhost:${await getRandomPort()}`);
    dbConnectionString = process.env.DB_CONNECTION_STRING!;
    postgresSrvServiceName = process.env.POSTGRES_SRV_SERVICE_NAME!;
    postgresDb = process.env.POSTGRES_DB!;
    postgresUser = process.env.POSTGRES_USER!;
    postgresPassword = process.env.POSTGRES_PASSWORD!;
    cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
    ogmiosConnection = await createConnectionObjectWithRandomPort();
    ogmiosSrvServiceName = process.env.OGMIOS_SRV_SERVICE_NAME!;
    serviceDiscoveryBackoffFactor = SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT;
    serviceDiscoveryBackoffTimeout = SERVICE_DISCOVERY_BACKOFF_TIMEOUT_DEFAULT;
    rabbitmqUrl = new URL(process.env.RABBITMQ_URL!);
    rabbitmqSrvServiceName = process.env.RABBITMQ_SRV_SERVICE_NAME!;
    cacheTtl = CACHE_TTL_DEFAULT;
    epochPollInterval = EPOCH_POLL_INTERVAL_DEFAULT;
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
          cacheTtl,
          cardanoNodeConfigPath,
          dbConnectionString,
          epochPollInterval,
          ogmiosUrl: new URL(ogmiosConnection.address.webSocket)
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
      it('loads the nominated HTTP service and server with service discovery', async () => {
        httpServer = await loadHttpServer({
          apiUrl,
          options: {
            cacheTtl,
            epochPollInterval,
            postgresDb,
            postgresPassword,
            postgresSrvServiceName,
            postgresUser,
            serviceDiscoveryBackoffFactor,
            serviceDiscoveryBackoffTimeout
          },
          serviceNames: [ServiceNames.StakePool]
        });

        expect(httpServer).toBeInstanceOf(HttpServer);
      });

      it('throws if service discovery is used but one of the postgres args is missing', async () => {
        const missingPostgresDb = undefined;

        await expect(
          async () =>
            await loadHttpServer({
              apiUrl,
              options: {
                cacheTtl,
                epochPollInterval,
                postgresDb: missingPostgresDb,
                postgresSrvServiceName,
                postgresUser,
                serviceDiscoveryBackoffFactor,
                serviceDiscoveryBackoffTimeout
              },
              serviceNames: [ServiceNames.StakePool]
            })
        ).rejects.toThrow(
          new MissingProgramOption(ServiceNames.StakePool, [
            ProgramOptionDescriptions.DbConnection,
            ProgramOptionDescriptions.PostgresSrvArgs
          ])
        );
      });

      it('throws if a service is nominated without providing db connection string nor service discovery args', async () => {
        await expect(
          async () =>
            await loadHttpServer({
              apiUrl,
              options: {
                cacheTtl,
                epochPollInterval
              },
              serviceNames: [ServiceNames.StakePool]
            })
        ).rejects.toThrow(
          new MissingProgramOption(ServiceNames.StakePool, [
            ProgramOptionDescriptions.DbConnection,
            ProgramOptionDescriptions.PostgresSrvArgs
          ])
        );
      });

      it('throws if a service is nominated with providing both db connection string and service discovery args at same time', async () => {
        await expect(
          async () =>
            await loadHttpServer({
              apiUrl,
              options: {
                cacheTtl,
                dbConnectionString,
                epochPollInterval,
                postgresSrvServiceName,
                serviceDiscoveryBackoffFactor,
                serviceDiscoveryBackoffTimeout
              },
              serviceNames: [ServiceNames.StakePool]
            })
        ).rejects.toThrow(
          new InvalidArgsCombination(ProgramOptionDescriptions.DbConnection, ProgramOptionDescriptions.PostgresSrvArgs)
        );
      });
    });

    describe('ogmios-dependent services', () => {
      it('loads the nominated HTTP service and server with service discovery', async () => {
        httpServer = await loadHttpServer({
          apiUrl,
          options: {
            cacheTtl,
            epochPollInterval,
            ogmiosSrvServiceName,
            serviceDiscoveryBackoffFactor,
            serviceDiscoveryBackoffTimeout
          },
          serviceNames: [ServiceNames.TxSubmit]
        });

        expect(httpServer).toBeInstanceOf(HttpServer);
      });

      it('loads the nominated HTTP server and service discovery takes preference over url if both are provided', async () => {
        httpServer = await loadHttpServer({
          apiUrl,
          options: {
            cacheTtl,
            epochPollInterval,
            ogmiosSrvServiceName,
            ogmiosUrl: new URL(ogmiosConnection.address.webSocket),
            serviceDiscoveryBackoffFactor,
            serviceDiscoveryBackoffTimeout
          },
          serviceNames: [ServiceNames.TxSubmit]
        });

        expect(httpServer).toBeInstanceOf(HttpServer);
      });

      it('throws if a service is nominated without providing ogmios url nor service discovery name', async () => {
        await expect(
          async () =>
            await loadHttpServer({
              apiUrl,
              options: {
                cacheTtl,
                epochPollInterval,
                serviceDiscoveryBackoffFactor,
                serviceDiscoveryBackoffTimeout
              },
              serviceNames: [ServiceNames.TxSubmit]
            })
        ).rejects.toThrow(
          new MissingProgramOption(ServiceNames.TxSubmit, [
            ProgramOptionDescriptions.OgmiosUrl,
            ProgramOptionDescriptions.OgmiosSrvServiceName
          ])
        );
      });
    });

    describe('rabbitmq-dependent services', () => {
      it('loads the nominated HTTP service and server with service discovery', async () => {
        httpServer = await loadHttpServer({
          apiUrl,
          options: {
            cacheTtl,
            epochPollInterval,
            rabbitmqSrvServiceName,
            serviceDiscoveryBackoffFactor,
            serviceDiscoveryBackoffTimeout,
            useQueue: true
          },
          serviceNames: [ServiceNames.TxSubmit]
        });

        expect(httpServer).toBeInstanceOf(HttpServer);
      });

      it('loads the nominated HTTP server and service discovery takes preference over url if both are provided', async () => {
        httpServer = await loadHttpServer({
          apiUrl,
          options: {
            cacheTtl,
            epochPollInterval,
            rabbitmqSrvServiceName,
            rabbitmqUrl,
            serviceDiscoveryBackoffFactor,
            serviceDiscoveryBackoffTimeout,
            useQueue: true
          },
          serviceNames: [ServiceNames.TxSubmit]
        });

        expect(httpServer).toBeInstanceOf(HttpServer);
      });

      it('throws if a service is nominated without providing rabbitmq url nor service discovery name', async () => {
        await expect(
          async () =>
            await loadHttpServer({
              apiUrl,
              options: {
                cacheTtl,
                epochPollInterval,
                serviceDiscoveryBackoffFactor,
                serviceDiscoveryBackoffTimeout,
                useQueue: true
              },
              serviceNames: [ServiceNames.TxSubmit]
            })
        ).rejects.toThrow(
          new MissingProgramOption(ServiceNames.TxSubmit, [
            ProgramOptionDescriptions.RabbitMQUrl,
            ProgramOptionDescriptions.RabbitMQSrvServiceName
          ])
        );
      });
    });

    it('throws if genesis-config dependent service is nominated without providing the node config path', async () => {
      await expect(
        async () =>
          await loadHttpServer({
            apiUrl,
            options: {
              cacheTtl: 0,
              dbConnectionString: 'postgres',
              epochPollInterval: 0,
              ogmiosUrl: new URL('http://localhost:1337')
            },
            serviceNames: [ServiceNames.NetworkInfo]
          })
      ).rejects.toThrow(
        new MissingProgramOption(ServiceNames.NetworkInfo, ProgramOptionDescriptions.CardanoNodeConfigPath)
      );
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

    it('should not throw if any internal providers are unhealthy during HTTP server initialization', () => {
      expect(() =>
        loadHttpServer({
          apiUrl,
          options: {
            cacheTtl,
            dbConnectionString,
            epochPollInterval,
            ogmiosUrl: new URL(ogmiosConnection.address.webSocket)
          },
          serviceNames: [ServiceNames.StakePool, ServiceNames.TxSubmit]
        })
      ).not.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });
});
