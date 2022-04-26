import { Connection } from '@cardano-ogmios/client';
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
  let dbConnectionString: string;
  let httpServer: HttpServer;
  let ogmiosConnection: Connection;
  let ogmiosServer: http.Server;

  beforeEach(async () => {
    apiUrl = new URL(`http://localhost:${await getRandomPort()}`);
    dbConnectionString = 'postgresql://dbuser:secretpassword@database.server.com:3211/mydb';
    ogmiosConnection = await createConnectionObjectWithRandomPort();
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
          dbConnectionString,
          ogmiosUrl: new URL(ogmiosConnection.address.webSocket)
        },
        serviceNames: [ServiceNames.StakePoolSearch, ServiceNames.TxSubmit]
      });
      expect(httpServer).toBeInstanceOf(HttpServer);
    });
    it('throws if postgres-dependent service is nominated without providing the connection string', async () => {
      await expect(
        async () =>
          await loadHttpServer({
            apiUrl,
            serviceNames: [ServiceNames.StakePoolSearch]
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
    it('throws if any internal providers are unhealthy', async () => {
      await expect(
        async () =>
          await loadHttpServer({
            apiUrl,
            options: {
              dbConnectionString,
              ogmiosUrl: new URL(ogmiosConnection.address.webSocket)
            },
            serviceNames: [ServiceNames.StakePoolSearch, ServiceNames.TxSubmit]
          })
      ).rejects.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });
});
