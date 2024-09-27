import { CardanoWsClient, WsProvider } from '@cardano-sdk/cardano-services-client';
import {
  CardanoWsServer,
  GenesisData,
  createDnsResolver,
  getOgmiosCardanoNode,
  util
} from '@cardano-sdk/cardano-services';
import { HealthCheckResponse } from '@cardano-sdk/core';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { filter, firstValueFrom } from 'rxjs';
import { getEnv, walletVariables } from '../../src';
import { getPort } from 'get-port-please';
import { logger } from '@cardano-sdk/util-dev';

const env = getEnv([...walletVariables, 'DB_SYNC_CONNECTION_STRING', 'OGMIOS_URL']);

const wsProviderReady = (provider: WsProvider) =>
  new Promise<void>((resolve, reject) => {
    // eslint-disable-next-line prefer-const
    let timeout: NodeJS.Timeout | undefined;

    const subscription = provider.health$.subscribe(({ ok }) => {
      if (ok) {
        if (timeout) clearTimeout(timeout);
        subscription.unsubscribe();
        resolve();
      }
    });

    timeout = setTimeout(() => {
      subscription.unsubscribe();
      reject(new Error('WsProvider timeout'));
    }, 10_000);

    timeout.unref();
  });

const wsProviderReadyAgain = (provider: WsProvider, close: () => Promise<unknown>) =>
  new Promise<void>(async (resolve, reject) => {
    const oks: boolean[] = [];
    let closed = false;
    // eslint-disable-next-line prefer-const
    let timeout: NodeJS.Timeout | undefined;

    const subscription = provider.health$.subscribe(({ ok }) => {
      oks.push(ok);

      if (closed && ok) {
        if (timeout) clearTimeout(timeout);
        subscription.unsubscribe();

        try {
          const [, ...last] = oks;

          // The first emitted event is the ok buffered one
          // next we expect at least one not ok event i.e. the close function had the desired effect
          // last we expect one more ok event when provider is operational once again
          expect(oks.length).toBeGreaterThanOrEqual(3);
          expect(oks[0]).toBeTruthy();
          expect(oks[1]).toBeFalsy();
          expect(last.some((result) => result));

          resolve();
        } catch (error) {
          reject(error);
        }
      }
    });

    try {
      await close();
    } catch (error) {
      reject(error);
    }

    closed = true;

    timeout = setTimeout(() => {
      subscription.unsubscribe();
      reject(new Error('WsProvider timeout'));
    }, 10_000);

    timeout.unref();
  });

describe('Web Socket', () => {
  let db: Pool;
  let cardanoNode: OgmiosCardanoNode;
  let genesisData: GenesisData;
  let port: number;

  let client: CardanoWsClient;
  let server: CardanoWsServer;

  const openClient = (heartbeatInterval = 55) =>
    (client = new CardanoWsClient({ logger }, { heartbeatInterval, url: new URL(`ws://localhost:${port}/ws`) }));

  const openServer = (heartbeatTimeout = 60) =>
    (server = new CardanoWsServer(
      { cardanoNode, db, genesisData, logger },
      { dbCacheTtl: 120, heartbeatTimeout, port }
    ));

  const closeClient = () => (client ? client.close() : Promise.resolve());
  const closeServer = () => (server ? new Promise<void>((resolve) => server.close(resolve)) : Promise.resolve());

  const listenToClientHealthFor15Seconds = async () => {
    const health: HealthCheckResponse[] = [];
    const subscription = client.health$.subscribe((value) => health.push(value));

    // Listen on client.health$ for 15"
    await new Promise((resolve) => setTimeout(resolve, 15_000));

    subscription.unsubscribe();

    return health;
  };

  beforeAll(async () => {
    const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);

    cardanoNode = await getOgmiosCardanoNode(dnsResolver, logger, { ogmiosUrl: new URL(env.OGMIOS_URL) });
    db = new Pool({ connectionString: env.DB_SYNC_CONNECTION_STRING });
    genesisData = await util.loadGenesisData('local-network/config/network/cardano-node/config.json');
    port = await getPort();

    await cardanoNode.initialize();
    await cardanoNode.start();
  });

  afterAll(() => Promise.all([cardanoNode.shutdown(), db.end()]));

  afterEach(() => Promise.all([closeClient(), closeServer()]));

  it('Server can re-connect to DB if NOTIFY connection drops', async () => {
    // Close server db connection from DB server side
    const query =
      "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND query = 'LISTEN sdk_tip'";

    openServer();
    await wsProviderReady(server);

    await wsProviderReadyAgain(server, () => db.query(query));
  });

  it('Client can re-connect to server if web socket connection drops', async () => {
    openServer();
    await wsProviderReady(server);

    openClient();
    await wsProviderReady(client);

    await wsProviderReadyAgain(client, async () => {
      // Close the server and open a new one
      await closeServer();
      openServer();
    });
  });

  it('Server disconnects clients on heartbeat timeout', async () => {
    // Open a server with 3" heartbeat timeout
    openServer(3);
    await wsProviderReady(server);

    openClient();
    await wsProviderReady(client);

    const health = await listenToClientHealthFor15Seconds();

    // Considering the server performs timeouts check every 10"
    // We expect the heath state of the client goes up and down more time
    expect(health.length).toBeGreaterThanOrEqual(3);
    // We expect the heath state of the client goes up at least twice
    expect(health.filter(({ ok }) => ok).length).toBeGreaterThanOrEqual(2);
    // We expect the heath state of the client goes down at least once
    expect(health.some(({ ok }) => !ok)).toBeTruthy();
  });

  it("Server doesn't disconnects clients without heartbeat timeouts", async () => {
    // Open a server with 3" heartbeat timeout
    openServer(3);
    await wsProviderReady(server);

    // Open a client with 2" heartbeat interval
    openClient(2);
    await wsProviderReady(client);

    const health = await listenToClientHealthFor15Seconds();

    // We expect only the buffered ok heath state
    expect(health.length).toBe(1);
    expect(health[0].ok).toBeTruthy();
  });

  describe('CardanoWsClient.networkInfoProvider', () => {
    it('It throws when disconnected but when starting', async () => {
      openServer();
      await wsProviderReady(server);

      openClient();

      // This test doesn't calls wsProviderReady(client)
      // to check the provider doesn't throw if called before its init sequence completed
      await expect(client.networkInfoProvider.ledgerTip()).resolves.toHaveProperty('blockNo');

      await closeServer();
      await firstValueFrom(client.health$.pipe(filter(({ ok }) => !ok)));

      await expect(client.networkInfoProvider.ledgerTip()).rejects.toThrowError('CONNECTION_FAILURE');
    });

    it('If called when still starting, it throws on connect error', async () => {
      openClient();

      await expect(client.networkInfoProvider.ledgerTip()).rejects.toThrowError('CONNECTION_FAILURE');
    });
  });
});
