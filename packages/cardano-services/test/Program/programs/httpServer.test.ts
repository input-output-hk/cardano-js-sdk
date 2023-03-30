/* eslint-disable sonarjs/no-duplicate-string */
import { DB_CACHE_TTL_DEFAULT } from '../../../src/InMemoryCache';
import {
  DEFAULT_HEALTH_CHECK_CACHE_TTL,
  OgmiosOptionDescriptions,
  PostgresOptionDescriptions,
  RabbitMqOptionDescriptions
} from '../../../src/Program/options';
import { EPOCH_POLL_INTERVAL_DEFAULT, listenPromise, serverClosePromise } from '../../../src/util';
import {
  HttpServer,
  MissingCardanoNodeOption,
  MissingProgramOption,
  ProviderServerOptionDescriptions,
  SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT,
  SERVICE_DISCOVERY_TIMEOUT_DEFAULT,
  ServiceNames,
  loadProviderServer
} from '../../../src';
import { Ogmios } from '@cardano-sdk/ogmios';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { SrvRecord } from 'dns';
import { URL } from 'url';
import {
  createConnectionObjectWithRandomPort,
  createHealthyMockOgmiosServer,
  createUnhealthyMockOgmiosServer,
  ogmiosServerReady
} from '../../util';
import { getRandomPort } from 'get-port-please';
import http from 'http';

jest.mock('dns', () => ({
  promises: {
    resolveSrv: async (): Promise<SrvRecord[]> => [{ name: 'localhost', port: 5433, priority: 6, weight: 5 }]
  }
}));

describe('HTTP Server', () => {
  let apiUrl: URL;
  let cardanoNodeConfigPath: string;
  let postgresConnectionString: string;
  let postgresSrvServiceName: string;
  let postgresDb: string;
  let postgresUser: string;
  let postgresPassword: string;
  let dbCacheTtl: number;
  let healthCheckCacheTtl: number;
  let epochPollInterval: number;
  let httpServer: HttpServer;
  let ogmiosConnection: Ogmios.Connection;
  let ogmiosSrvServiceName: string;
  let ogmiosServer: http.Server;
  let serviceDiscoveryBackoffFactor: number;
  let serviceDiscoveryTimeout: number;
  let rabbitmqSrvServiceName: string;
  let rabbitmqUrl: URL;

  beforeEach(async () => {
    apiUrl = new URL(`http://localhost:${await getRandomPort()}`);
    postgresConnectionString = process.env.POSTGRES_CONNECTION_STRING!;
    postgresSrvServiceName = process.env.POSTGRES_SRV_SERVICE_NAME!;
    postgresDb = process.env.POSTGRES_DB!;
    postgresUser = process.env.POSTGRES_USER!;
    postgresPassword = process.env.POSTGRES_PASSWORD!;
    cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
    ogmiosConnection = await createConnectionObjectWithRandomPort();
    ogmiosSrvServiceName = process.env.OGMIOS_SRV_SERVICE_NAME!;
    serviceDiscoveryBackoffFactor = SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT;
    serviceDiscoveryTimeout = SERVICE_DISCOVERY_TIMEOUT_DEFAULT;
    rabbitmqUrl = new URL(process.env.RABBITMQ_URL!);
    rabbitmqSrvServiceName = process.env.RABBITMQ_SRV_SERVICE_NAME!;
    dbCacheTtl = DB_CACHE_TTL_DEFAULT;
    healthCheckCacheTtl = DEFAULT_HEALTH_CHECK_CACHE_TTL;
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
      httpServer = await loadProviderServer({
        apiUrl,
        cardanoNodeConfigPath,
        dbCacheTtl,
        epochPollInterval,
        healthCheckCacheTtl,
        ogmiosUrl: new URL(ogmiosConnection.address.webSocket),
        postgresConnectionString,
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
        httpServer = await loadProviderServer({
          apiUrl,
          cardanoNodeConfigPath,
          dbCacheTtl,
          epochPollInterval,
          healthCheckCacheTtl,
          ogmiosUrl: new URL(ogmiosConnection.address.webSocket),
          postgresDb,
          postgresPassword,
          postgresSrvServiceName,
          postgresUser,
          serviceDiscoveryBackoffFactor,
          serviceDiscoveryTimeout,
          serviceNames: [ServiceNames.StakePool]
        });

        expect(httpServer).toBeInstanceOf(HttpServer);
      });

      it('throws if service discovery is used but one of the postgres args is missing', async () => {
        const missingPostgresDb = undefined;

        await expect(
          async () =>
            await loadProviderServer({
              apiUrl,
              cardanoNodeConfigPath,
              dbCacheTtl,
              epochPollInterval,
              healthCheckCacheTtl,
              ogmiosUrl: new URL(ogmiosConnection.address.webSocket),
              postgresDb: missingPostgresDb,
              postgresSrvServiceName,
              postgresUser,
              serviceDiscoveryBackoffFactor,
              serviceDiscoveryTimeout,
              serviceNames: [ServiceNames.StakePool]
            })
        ).rejects.toThrow(
          new MissingProgramOption(ServiceNames.StakePool, [
            PostgresOptionDescriptions.ConnectionString,
            PostgresOptionDescriptions.ServiceDiscoveryArgs
          ])
        );
      });

      it('throws if a service is nominated without providing db connection string nor service discovery args', async () => {
        await expect(
          async () =>
            await loadProviderServer({
              apiUrl,
              cardanoNodeConfigPath,
              dbCacheTtl,
              epochPollInterval,
              healthCheckCacheTtl,
              ogmiosUrl: new URL(ogmiosConnection.address.webSocket),
              serviceNames: [ServiceNames.StakePool]
            })
        ).rejects.toThrow(
          new MissingProgramOption(ServiceNames.StakePool, [
            PostgresOptionDescriptions.ConnectionString,
            PostgresOptionDescriptions.ServiceDiscoveryArgs
          ])
        );
      });
    });

    describe('ogmios-dependent services', () => {
      it('loads the nominated HTTP service and server with service discovery', async () => {
        httpServer = await loadProviderServer({
          apiUrl,
          cardanoNodeConfigPath,
          dbCacheTtl,
          epochPollInterval,
          healthCheckCacheTtl,
          ogmiosSrvServiceName,
          serviceDiscoveryBackoffFactor,
          serviceDiscoveryTimeout,
          serviceNames: [ServiceNames.TxSubmit]
        });

        expect(httpServer).toBeInstanceOf(HttpServer);
      });

      it('loads the nominated Provider server and service discovery takes preference over url if both are provided', async () => {
        httpServer = await loadProviderServer({
          apiUrl,
          cardanoNodeConfigPath,
          dbCacheTtl,
          epochPollInterval,
          healthCheckCacheTtl,
          ogmiosSrvServiceName,
          ogmiosUrl: new URL(ogmiosConnection.address.webSocket),
          serviceDiscoveryBackoffFactor,
          serviceDiscoveryTimeout,
          serviceNames: [ServiceNames.TxSubmit]
        });

        expect(httpServer).toBeInstanceOf(HttpServer);
      });

      it('throws if a service is nominated without providing ogmios url nor service discovery name', async () => {
        await expect(
          async () =>
            await loadProviderServer({
              apiUrl,
              cardanoNodeConfigPath,
              dbCacheTtl,
              epochPollInterval,
              healthCheckCacheTtl,
              serviceDiscoveryBackoffFactor,
              serviceDiscoveryTimeout,
              serviceNames: [ServiceNames.TxSubmit]
            })
        ).rejects.toThrow(
          new MissingCardanoNodeOption([OgmiosOptionDescriptions.Url, OgmiosOptionDescriptions.SrvServiceName])
        );
      });
    });

    describe('rabbitmq-dependent services', () => {
      it('loads the nominated HTTP service and server with service discovery', async () => {
        httpServer = await loadProviderServer({
          apiUrl,
          cardanoNodeConfigPath,
          dbCacheTtl,
          epochPollInterval,
          healthCheckCacheTtl,
          rabbitmqSrvServiceName,
          serviceDiscoveryBackoffFactor,
          serviceDiscoveryTimeout,
          serviceNames: [ServiceNames.TxSubmit],
          useQueue: true
        });

        expect(httpServer).toBeInstanceOf(HttpServer);
      });

      it('loads the nominated Provider server and service discovery takes preference over url if both are provided', async () => {
        httpServer = await loadProviderServer({
          apiUrl,
          cardanoNodeConfigPath,
          dbCacheTtl,
          epochPollInterval,
          healthCheckCacheTtl,
          rabbitmqSrvServiceName,
          rabbitmqUrl,
          serviceDiscoveryBackoffFactor,
          serviceDiscoveryTimeout,
          serviceNames: [ServiceNames.TxSubmit],
          useQueue: true
        });

        expect(httpServer).toBeInstanceOf(HttpServer);
      });

      it('throws if a service is nominated without providing rabbitmq url nor service discovery name', async () => {
        await expect(
          async () =>
            await loadProviderServer({
              apiUrl,
              cardanoNodeConfigPath,
              dbCacheTtl,
              epochPollInterval,
              healthCheckCacheTtl,
              serviceDiscoveryBackoffFactor,
              serviceDiscoveryTimeout,
              serviceNames: [ServiceNames.TxSubmit],
              useQueue: true
            })
        ).rejects.toThrow(
          new MissingProgramOption(ServiceNames.TxSubmit, [
            RabbitMqOptionDescriptions.Url,
            RabbitMqOptionDescriptions.SrvServiceName
          ])
        );
      });
    });

    describe('throws if genesis-config dependent service is nominated without providing the node config path', () => {
      // eslint-disable-next-line unicorn/consistent-function-scoping
      const test = (serviceName: ServiceNames) =>
        expect(() =>
          loadProviderServer({
            apiUrl,
            dbCacheTtl: 0,
            epochPollInterval: 0,
            healthCheckCacheTtl,
            ogmiosUrl: new URL('http://localhost:1337'),
            postgresConnectionString: 'postgres',
            serviceNames: [serviceName]
          })
        ).rejects.toThrow(
          new MissingProgramOption(serviceName, ProviderServerOptionDescriptions.CardanoNodeConfigPath)
        );

      it('with network-info provider', () => test(ServiceNames.NetworkInfo));
      it('with stake-pool provider', () => test(ServiceNames.StakePool));
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

    it('should not throw if any internal providers are unhealthy during Provider server initialization', () => {
      expect(() =>
        loadProviderServer({
          apiUrl,
          cardanoNodeConfigPath,
          dbCacheTtl,
          epochPollInterval,
          healthCheckCacheTtl,
          ogmiosUrl: new URL(ogmiosConnection.address.webSocket),
          postgresConnectionString,
          serviceNames: [ServiceNames.StakePool, ServiceNames.TxSubmit]
        })
      ).not.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });
});
