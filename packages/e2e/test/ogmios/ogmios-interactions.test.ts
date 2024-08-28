import {
  DB_CACHE_TTL_DEFAULT,
  HttpServer,
  ProviderServerArgs,
  ServiceNames,
  loadProviderServer,
  util
} from '@cardano-sdk/cardano-services';
import { SrvRecord } from 'dns';
import { createServer } from 'http';
import { getPort } from 'get-port-please';
import { logger } from '@cardano-sdk/util-dev';
import WebSocket from 'ws';
import axios from 'axios';
import path from 'path';

import { getEnv, networkInfoProviderFactory } from '../../src';

const env = getEnv(['DB_SYNC_CONNECTION_STRING', 'OGMIOS_URL']);

const cardanoNodeConfigPath = path.join(
  __dirname,
  '..',
  '..',
  'local-network',
  'config',
  'network',
  'cardano-node',
  'config.json'
);

/**
 * This works as a man in the middle. It simply listen both for HTTP and WebSocket
 * and proxies all requests to a real ogmios server. Being this class based on async/await
 * paradigm while HttpServer and WebSocket are based on events paradigm; this collects the
 * asynchronous errors from event emitters and reports the first one as a rejection of
 * close function call.
 * It do not implements all ogmios features, but just the ones required by this test.
 */
class OgmiosProxy {
  private firstError: Error | undefined = undefined;
  private setError: (error: Error) => void;

  public constructor(private port: number) {
    this.setError = (error: Error) => (this.firstError ? null : (this.firstError = error));
  }

  /**
   * Starts the proxy
   *
   * @returns the async function to call to close the proxy
   */
  start(): Promise<() => Promise<void>> {
    // eslint-disable-next-line sonarjs/cognitive-complexity
    return new Promise((resolve) => {
      let closeClients: (() => void) | undefined;
      const server = createServer(async (_req, res) => {
        try {
          const actual = await axios.get(`${env.OGMIOS_URL.replace('ws://', 'http://')}health`, {
            headers: { 'Content-Type': 'application/json' }
          });
          res.setHeader('Content-Type', 'application/json');
          res.end(JSON.stringify(actual.data));
        } catch (error) {
          this.setError(error as Error);
          res.statusCode = 500;
          res.end();
        }
      });
      const wsc = new WebSocket(env.OGMIOS_URL);
      const wss = new WebSocket.Server({ server });

      closeClients = () => wsc.close();

      // eslint-disable-next-line @typescript-eslint/no-shadow
      const wscClose = new Promise<void>((resolve, reject) => {
        wsc.on('error', reject);
        wsc.on('close', () => resolve());
      });

      wss.on('connection', (ws) => {
        ws.on('message', (data) => wsc.send(data));
        wsc.on('message', (data) => ws.send(data));
        closeClients = () => {
          ws.close();
          wsc.close();
        };
      });

      wsc.on('error', this.setError);
      wss.on('error', this.setError);
      server.on('error', this.setError);

      server.listen(this.port, 'localhost', () =>
        resolve(
          () =>
            // eslint-disable-next-line @typescript-eslint/no-shadow
            new Promise<void>((resolve, reject) => {
              if (closeClients) closeClients();

              wss.close((wssError) =>
                server.close(async (serverError) => {
                  if (this.firstError) return reject(this.firstError);
                  if (wssError) return reject(wssError);
                  if (serverError) return reject(serverError);

                  try {
                    await wscClose;
                    resolve();
                  } catch (error) {
                    reject(error);
                  }
                })
              );
            })
        )
      );
    });
  }
}

describe('interactions with ogmios server', () => {
  let closeOgmiosProxy: (() => Promise<void>) | undefined;
  let providerServer: HttpServer;
  let httpPort: number;
  let ogmiosPort: number;

  const openOgmiosProxy = async () => {
    const close = await new OgmiosProxy(ogmiosPort).start();

    closeOgmiosProxy = async () => {
      await close();
      closeOgmiosProxy = undefined;
    };
  };

  beforeAll(async () => {
    ogmiosPort = await getPort();

    await openOgmiosProxy();

    httpPort = await getPort();

    const dependencies = {
      dnsResolver: () => Promise.resolve<SrvRecord>({ name: 'localhost', port: ogmiosPort, priority: 1, weight: 1 }),
      logger
    } as const;
    const args = {
      apiUrl: new URL(`http://localhost:${httpPort}`),
      cardanoNodeConfigPath,
      dbCacheTtl: DB_CACHE_TTL_DEFAULT,
      epochPollInterval: util.EPOCH_POLL_INTERVAL_DEFAULT,
      ogmiosSrvServiceName: 'localhost',
      postgresConnectionStringDbSync: env.DB_SYNC_CONNECTION_STRING,
      serviceNames: [ServiceNames.NetworkInfo]
    } as ProviderServerArgs;

    providerServer = await loadProviderServer(args, dependencies);

    await providerServer.initialize();
    await providerServer.start();
  });

  afterAll(async () => {
    await providerServer.shutdown();
    await closeOgmiosProxy?.();
  });

  it('connection close is correctly handled', async () => {
    const providerEnv = getEnv(['TEST_CLIENT_NETWORK_INFO_PROVIDER', 'TEST_CLIENT_NETWORK_INFO_PROVIDER_PARAMS'], {
      override: {
        TEST_CLIENT_NETWORK_INFO_PROVIDER_PARAMS: JSON.stringify({
          baseUrl: `http://localhost:${httpPort}/network-info`
        })
      }
    });

    // This performs an health check behind the scenes, so this is enough
    // to establish and use the WebSocket connection to the ogmios server
    const networkInfoProvider = await networkInfoProviderFactory.create(
      providerEnv.TEST_CLIENT_NETWORK_INFO_PROVIDER,
      providerEnv.TEST_CLIENT_NETWORK_INFO_PROVIDER_PARAMS,
      logger
    );

    // Simulate an ogmios server restart closing a proxy and opening a new one.
    await closeOgmiosProxy?.();
    await openOgmiosProxy();

    // In case of any result rather than a connection error we are sure the
    // reconnection worked successfully
    expect(await networkInfoProvider.stake()).toBeDefined();
  });
});
