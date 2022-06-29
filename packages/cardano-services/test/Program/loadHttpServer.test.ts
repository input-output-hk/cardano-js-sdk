import { CACHE_TTL_DEFAULT } from '../../src/InMemoryCache';
import { Connection } from '@cardano-ogmios/client';
import { DB_POLL_INTERVAL_DEFAULT } from '../../src/NetworkInfo';
import { HttpServer } from '../../src';
import { MissingProgramOption, ServiceNames, loadHttpServer } from '../../src/Program';
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

  beforeEach(async () => {
    apiUrl = new URL(`http://localhost:${await getRandomPort()}`);
    dbConnectionString = process.env.DB_CONNECTION_STRING!;
    cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
    ogmiosConnection = await createConnectionObjectWithRandomPort();
    dbQueriesCacheTtl = CACHE_TTL_DEFAULT;
    dbPollInterval = DB_POLL_INTERVAL_DEFAULT;
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

    it('loads the nominated HTTP services and server if required program arguments are set', () => {
      httpServer = loadHttpServer({
        apiUrl,
        options: {
          cardanoNodeConfigPath,
          dbConnectionString,
          dbPollInterval,
          dbQueriesCacheTtl,
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

    it('throws if postgres-dependent service is nominated without providing the connection string', () => {
      expect(() =>
        loadHttpServer({
          apiUrl,
          serviceNames: [
            ServiceNames.StakePool,
            ServiceNames.Utxo,
            ServiceNames.ChainHistory,
            ServiceNames.Rewards,
            ServiceNames.NetworkInfo
          ]
        })
      ).toThrow(MissingProgramOption);
    });

    it('throws if genesis-config dependent service is nominated without providing the node config path', () => {
      expect(() =>
        loadHttpServer({
          apiUrl,
          serviceNames: [ServiceNames.NetworkInfo]
        })
      ).toThrow(MissingProgramOption);
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
            dbConnectionString,
            dbPollInterval,
            dbQueriesCacheTtl,
            ogmiosUrl: new URL(ogmiosConnection.address.webSocket)
          },
          serviceNames: [ServiceNames.StakePool, ServiceNames.TxSubmit]
        })
      ).not.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });
});
