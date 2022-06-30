import { CACHE_TTL_DEFAULT } from '../../src/InMemoryCache';
import { Connection } from '@cardano-ogmios/client';
import { DB_POLL_INTERVAL_DEFAULT } from '../../src/NetworkInfo';
import { HttpServer } from '../../src';
import {
  MissingProgramOption,
  RETRY_BACKOFF_FACTOR_DEFAULT,
  RETRY_BACKOFF_MAX_TIMEOUT_DEFAULT,
  ServiceNames,
  loadHttpServer
} from '../../src/Program';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
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

describe('loadHttpServer', () => {
  let apiUrl: URL;
  let cardanoNodeConfigPath: string;
  let dbConnectionString: string;
  let dbQueriesCacheTtl: number;
  let dbPollInterval: number;
  let httpServer: HttpServer;
  let ogmiosConnection: Connection;
  let ogmiosServer: http.Server;
  let serviceDiscoveryBackoffFactor: number;
  let serviceDiscoveryTimeout: number;

  beforeEach(async () => {
    apiUrl = new URL(`http://localhost:${await getRandomPort()}`);
    dbConnectionString = process.env.DB_CONNECTION_STRING!;
    cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
    ogmiosConnection = await createConnectionObjectWithRandomPort();
    dbQueriesCacheTtl = CACHE_TTL_DEFAULT;
    dbPollInterval = DB_POLL_INTERVAL_DEFAULT;
    serviceDiscoveryBackoffFactor = RETRY_BACKOFF_FACTOR_DEFAULT;
    serviceDiscoveryTimeout = RETRY_BACKOFF_MAX_TIMEOUT_DEFAULT;
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

    it('throws if postgres-dependent service is nominated without providing the connection string', async () => {
      await expect(
        async () =>
          await loadHttpServer({
            apiUrl,
            serviceNames: [
              ServiceNames.StakePool,
              ServiceNames.Utxo,
              ServiceNames.ChainHistory,
              ServiceNames.Rewards,
              ServiceNames.NetworkInfo
            ]
          })
      ).rejects.toThrow(MissingProgramOption);
    });

    it('throws if genesis-config dependent service is nominated without providing the node config path', async () => {
      await expect(
        async () =>
          await loadHttpServer({
            apiUrl,
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
