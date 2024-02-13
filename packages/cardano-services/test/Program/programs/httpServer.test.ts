/* eslint-disable sonarjs/no-duplicate-string */
import { DB_CACHE_TTL_DEFAULT } from '../../../src/InMemoryCache';
import {
  DEFAULT_HEALTH_CHECK_CACHE_TTL,
  OgmiosOptionDescriptions,
  PostgresOptionDescriptions,
  StakePoolMetadataFetchMode
} from '../../../src/Program/options';
import { EPOCH_POLL_INTERVAL_DEFAULT } from '../../../src/util';
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
import { ProviderError, ProviderFailure, Seconds } from '@cardano-sdk/core';
import { SrvRecord } from 'dns';
import { getRandomPort } from 'get-port-please';

jest.mock('dns', () => ({
  promises: {
    resolveSrv: async (): Promise<SrvRecord[]> => [{ name: 'localhost', port: 5433, priority: 6, weight: 5 }]
  }
}));

const ogmiosUrl = new URL('http://localhost:1337');

describe('HTTP Server', () => {
  let apiUrl: URL;
  let cardanoNodeConfigPath: string;
  let postgresConnectionStringDbSync: string;
  let postgresConnectionStringHandle: string;
  let postgresConnectionStringAsset: string;
  let postgresSrvServiceNameDbSync: string;
  let postgresDbDbSync: string;
  let postgresUserDbSync: string;
  let postgresPasswordDbSync: string;
  let dbCacheTtl: Seconds;
  let healthCheckCacheTtl: Seconds;
  let epochPollInterval: number;
  let httpServer: HttpServer;
  let ogmiosSrvServiceName: string;
  let serviceDiscoveryBackoffFactor: number;
  let serviceDiscoveryTimeout: number;

  beforeEach(async () => {
    apiUrl = new URL(`http://localhost:${await getRandomPort()}`);
    postgresConnectionStringDbSync = process.env.POSTGRES_CONNECTION_STRING_DB_SYNC!;
    postgresConnectionStringHandle = process.env.POSTGRES_CONNECTION_STRING_HANDLE!;
    postgresConnectionStringAsset = process.env.POSTGRES_CONNECTION_STRING_ASSET!;
    postgresSrvServiceNameDbSync = process.env.POSTGRES_SRV_SERVICE_NAME_DB_SYNC!;
    postgresDbDbSync = process.env.POSTGRES_DB_DB_SYNC!;
    postgresUserDbSync = process.env.POSTGRES_USER_DB_SYNC!;
    postgresPasswordDbSync = process.env.POSTGRES_PASSWORD_DB_SYNC!;
    cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
    ogmiosSrvServiceName = process.env.OGMIOS_SRV_SERVICE_NAME!;
    serviceDiscoveryBackoffFactor = SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT;
    serviceDiscoveryTimeout = SERVICE_DISCOVERY_TIMEOUT_DEFAULT;
    dbCacheTtl = DB_CACHE_TTL_DEFAULT;
    healthCheckCacheTtl = DEFAULT_HEALTH_CHECK_CACHE_TTL;
    epochPollInterval = EPOCH_POLL_INTERVAL_DEFAULT;
  });

  describe('healthy internal providers', () => {
    it('loads the nominated HTTP services and server if required program arguments are set', async () => {
      httpServer = await loadProviderServer({
        apiUrl,
        cardanoNodeConfigPath,
        dbCacheTtl,
        epochPollInterval,
        handlePolicyIds: [],
        healthCheckCacheTtl,
        metadataFetchMode: StakePoolMetadataFetchMode.DIRECT,
        ogmiosUrl,
        postgresConnectionStringAsset,
        postgresConnectionStringDbSync,
        postgresConnectionStringHandle,
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
          handlePolicyIds: [],
          healthCheckCacheTtl,
          metadataFetchMode: StakePoolMetadataFetchMode.DIRECT,
          ogmiosUrl,
          postgresDbDbSync,
          postgresPasswordDbSync,
          postgresSrvServiceNameDbSync,
          postgresUserDbSync,
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
              handlePolicyIds: [],
              healthCheckCacheTtl,
              metadataFetchMode: StakePoolMetadataFetchMode.DIRECT,
              ogmiosUrl,
              postgresDbDbSync: missingPostgresDb,
              postgresSrvServiceNameDbSync,
              postgresUserDbSync,
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
              handlePolicyIds: [],
              healthCheckCacheTtl,
              metadataFetchMode: StakePoolMetadataFetchMode.DIRECT,
              ogmiosUrl,
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
          handlePolicyIds: [],
          healthCheckCacheTtl,
          metadataFetchMode: StakePoolMetadataFetchMode.DIRECT,
          ogmiosSrvServiceName,
          ogmiosUrl,
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
          handlePolicyIds: [],
          healthCheckCacheTtl,
          metadataFetchMode: StakePoolMetadataFetchMode.DIRECT,
          ogmiosSrvServiceName,
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
              handlePolicyIds: [],
              healthCheckCacheTtl,
              metadataFetchMode: StakePoolMetadataFetchMode.DIRECT,
              postgresConnectionStringDbSync,
              serviceDiscoveryBackoffFactor,
              serviceDiscoveryTimeout,
              serviceNames: [ServiceNames.TxSubmit]
            })
        ).rejects.toThrow(
          new MissingCardanoNodeOption([OgmiosOptionDescriptions.Url, OgmiosOptionDescriptions.SrvServiceName])
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
            handlePolicyIds: [],
            healthCheckCacheTtl,
            metadataFetchMode: StakePoolMetadataFetchMode.DIRECT,
            ogmiosUrl,
            postgresConnectionStringDbSync: 'postgres',
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
    it('should not throw if any internal providers are unhealthy during Provider server initialization', () => {
      expect(() =>
        loadProviderServer({
          apiUrl,
          cardanoNodeConfigPath,
          dbCacheTtl,
          epochPollInterval,
          handlePolicyIds: [],
          healthCheckCacheTtl,
          metadataFetchMode: StakePoolMetadataFetchMode.DIRECT,
          ogmiosUrl,
          postgresConnectionStringDbSync,
          serviceNames: [ServiceNames.StakePool, ServiceNames.TxSubmit]
        })
      ).not.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });
});
