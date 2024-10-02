// cSpell:ignore cardano utxos

import { Cardano, HealthCheckResponse } from '@cardano-sdk/core';
import {
  CardanoWsClient,
  WsProvider,
  chainHistoryHttpProvider,
  utxoHttpProvider
} from '@cardano-sdk/cardano-services-client';
import {
  CardanoWsServer,
  GenesisData,
  createDnsResolver,
  getOgmiosCardanoNode,
  util
} from '@cardano-sdk/cardano-services';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { filter, firstValueFrom } from 'rxjs';
import { getEnv, walletVariables } from '../../src';
import { getPort } from 'get-port-please';
import { logger } from '@cardano-sdk/util-dev';
import { toSerializableObject } from '@cardano-sdk/util';

const env = getEnv([...walletVariables, 'DB_SYNC_CONNECTION_STRING', 'OGMIOS_URL']);

const pagination = { limit: 25, startAt: 0 };

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
      timeout = undefined;
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
          // The first emitted event is the ok buffered one
          expect(oks[0]).toBeTruthy();
          // Next we expect at least one not ok event i.e. the close function had the desired effect
          const firstFalsy = oks.findIndex((element) => !element);
          expect(firstFalsy).toBeGreaterThan(0);
          // Last we expect one more ok event when provider is operational once again
          expect(oks.findIndex((element, index) => element && index > firstFalsy)).toBeGreaterThan(firstFalsy);

          resolve();
        } catch (error) {
          reject(error);
        }
      }
    });

    try {
      await close();
    } catch (error) {
      return reject(error);
    }

    closed = true;

    // eslint-disable-next-line sonarjs/no-identical-functions
    timeout = setTimeout(() => {
      timeout = undefined;
      subscription.unsubscribe();
      reject(new Error('WsProvider timeout'));
    }, 10_000);

    timeout.unref();
  });

describe('Web Socket', () => {
  const chainHistoryProvider = chainHistoryHttpProvider({ logger, ...env.TEST_CLIENT_CHAIN_HISTORY_PROVIDER_PARAMS });
  const utxoProvider = utxoHttpProvider({ logger, ...env.TEST_CLIENT_CHAIN_HISTORY_PROVIDER_PARAMS });

  let db: Pool;
  let cardanoNode: OgmiosCardanoNode;
  let genesisData: GenesisData;
  let port: number;

  let client: CardanoWsClient;
  let server: CardanoWsServer;

  const openClient = (options: { heartbeatInterval?: number; url?: string } = {}) => {
    const { heartbeatInterval, url } = { heartbeatInterval: 55, url: `ws://localhost:${port}/ws`, ...options };

    return (client = new CardanoWsClient({ chainHistoryProvider, logger }, { heartbeatInterval, url: new URL(url) }));
  };

  const openServer = (heartbeatTimeout = 60) =>
    (server = new CardanoWsServer(
      { cardanoNode, db, genesisData, logger },
      { dbCacheTtl: 120, heartbeatInterval: 1, heartbeatTimeout, port }
    ));

  const closeClient = () => (client ? client.close() : Promise.resolve());
  const closeServer = () => (server ? new Promise<void>((resolve) => server.close(resolve)) : Promise.resolve());

  const listenToClientHealthFor5Seconds = async () => {
    const health: HealthCheckResponse[] = [];
    const subscription = client.health$.subscribe((value) => health.push(value));

    // Listen on client.health$ for 5"
    await new Promise((resolve) => setTimeout(resolve, 5000));

    subscription.unsubscribe();

    return health;
  };

  const transactionsByAddresses = () =>
    client.chainHistoryProvider.transactionsByAddresses({
      addresses: ['fake_address' as Cardano.PaymentAddress],
      pagination
    });

  beforeAll(async () => {
    const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);

    cardanoNode = await getOgmiosCardanoNode(dnsResolver, logger, { ogmiosUrl: new URL(env.OGMIOS_URL) });
    genesisData = await util.loadGenesisData('local-network/config/network/cardano-node/config.json');
    port = await getPort();

    await cardanoNode.initialize();
    await cardanoNode.start();
  });

  beforeEach(() => (db = new Pool({ connectionString: env.DB_SYNC_CONNECTION_STRING })));

  afterAll(() => cardanoNode.shutdown());

  afterEach(() => Promise.all([db.end(), closeClient(), closeServer()]));

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
    // Open a server with 2" heartbeat timeout
    openServer(2);
    await wsProviderReady(server);

    openClient();
    await wsProviderReady(client);

    const health = await listenToClientHealthFor5Seconds();

    // Considering the server performs timeouts check every second
    // We expect the heath state of the client goes up and down more times
    expect(health.length).toBeGreaterThanOrEqual(3);
    // We expect the heath state of the client goes up at least twice
    expect(health.filter(({ ok }) => ok).length).toBeGreaterThanOrEqual(2);
    // We expect the heath state of the client goes down at least once
    expect(health.some(({ ok }) => !ok)).toBeTruthy();
  });

  it("Server doesn't disconnects clients without heartbeat timeouts", async () => {
    // Open a server with 2" heartbeat timeout
    openServer(2);
    await wsProviderReady(server);

    // Open a client with 2" heartbeat interval
    openClient({ heartbeatInterval: 1 });
    await wsProviderReady(client);

    const health = await listenToClientHealthFor5Seconds();

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

  describe('CardanoWsClient.chainHistoryProvider.transactionsByAddresses', () => {
    // The first two tests are identical to CardanoWsClient.networkInfoProvider ones,
    // they are anyway required because the code behind the two providers is completely different
    it('It throws when disconnected but when starting', async () => {
      openServer();
      await wsProviderReady(server);

      openClient();

      await expect(transactionsByAddresses()).resolves.toHaveProperty('pageResults');

      await closeServer();
      await firstValueFrom(client.health$.pipe(filter(({ ok }) => !ok)));

      await expect(transactionsByAddresses()).rejects.toThrowError('CONNECTION_FAILURE');
    });

    it('If called when still starting, it throws on connect error', async () => {
      openClient();

      await expect(transactionsByAddresses()).rejects.toThrowError('CONNECTION_FAILURE');
    });

    it('More calls while syncing address throw', async () => {
      openServer();
      await wsProviderReady(server);

      openClient();
      await wsProviderReady(client);

      const deferred = async () => {
        await new Promise((resolve) => setTimeout(resolve, 1));
        await expect(transactionsByAddresses()).rejects.toThrowError('CONFLICT');
      };

      await Promise.all([
        expect(transactionsByAddresses()).resolves.toHaveProperty('pageResults'),
        deferred(),
        deferred()
      ]);
    });

    it('More calls after address is synced, never throw', async () => {
      openServer();
      await wsProviderReady(server);

      openClient();
      await wsProviderReady(client);

      await expect(transactionsByAddresses()).resolves.toHaveProperty('pageResults');

      await Promise.all([
        expect(transactionsByAddresses()).resolves.toHaveProperty('pageResults'),
        expect(transactionsByAddresses()).resolves.toHaveProperty('pageResults')
      ]);
    });
  });

  describe('transactions & utxos', () => {
    const tests: string[][] = [
      ['collaterals', 'SELECT tx_in_id AS tx_id FROM collateral_tx_in'],
      ['collateralReturn', 'SELECT tx_id FROM collateral_tx_out'],
      [
        'datum',
        'SELECT tx_id FROM tx_out LEFT JOIN tx_in ON tx_out_id = tx_id AND tx_out_index = index WHERE inline_datum_id IS NOT NULL AND tx_out_id IS NULL AND stake_address_id IS NOT NULL'
      ],
      ['failed phase 2 validation', 'SELECT id AS tx_id FROM tx WHERE valid_contract = false'],
      ['mint', 'SELECT tx_id FROM ma_tx_mint'],
      ['metadata', 'SELECT tx_id FROM tx_metadata'],
      ['withdrawals', 'SELECT tx_id FROM withdrawal'],
      ['redeemers', 'SELECT tx_id FROM redeemer'],
      ['governance action proposals', 'SELECT tx_id FROM gov_action_proposal'],
      ['voting procedures', 'SELECT tx_id FROM voting_procedure'],
      ['certificate: stake pool registration', 'SELECT registered_tx_id AS tx_id FROM pool_update ORDER BY id DESC'],
      ['certificate: stake pool retire', 'SELECT announced_tx_id AS tx_id FROM pool_retire'],
      ['certificate: stake credential registration', 'SELECT tx_id FROM stake_registration ORDER BY id DESC'],
      ['certificate: stake credential deregistration', 'SELECT tx_id FROM stake_deregistration'],
      ['certificate: stake delegation', 'SELECT tx_id FROM delegation ORDER BY id DESC'],
      ['certificate: vote delegation', 'SELECT tx_id FROM delegation_vote'],
      ['certificate: delegation representative registration', 'SELECT tx_id FROM drep_registration WHERE deposit > 0'],
      ['certificate: delegation representative update', 'SELECT tx_id FROM drep_registration WHERE deposit IS NULL'],
      [
        'certificate: delegation representative deregistration',
        'SELECT tx_id FROM drep_registration WHERE deposit < 0'
      ],
      ['certificate: committee registration', 'SELECT tx_id FROM committee_registration'],
      ['certificate: committee deregistration', 'SELECT tx_id FROM committee_de_registration']
    ];

    test.each(tests)('transactions with %s', async (name, subQuery) => {
      // cSpell:disable
      const query = `\
SELECT address, block_no::INTEGER AS "lowerBound" FROM (${subQuery} LIMIT 1) t, tx, tx_out o, block
WHERE tx.id = o.tx_id AND t.tx_id = o.tx_id AND block_id = block.id AND address NOT IN (
  'addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0', 'addr_test1wqmpwrh2mlqa04e2mf3vr8w9rjt9du0dpnync8dzc85spgsya8emz')`;
      // cSpell:enable
      const result = await db.query<{ address: Cardano.PaymentAddress; lowerBound: Cardano.BlockNo }>(query);
      let step = '';

      if (!result.rowCount) return logger.fatal(`Test 'transactions with ${name}': not valid transactions found`);

      const { address, lowerBound } = result.rows[0];
      const request = { addresses: [address], blockRange: { lowerBound }, pagination };

      openClient({ url: env.WS_PROVIDER_URL });

      try {
        step = 'txs ws';
        const wsTxs = await client.chainHistoryProvider.transactionsByAddresses(request);
        step = 'txs http';
        const httpTxs = await chainHistoryProvider.transactionsByAddresses(request);
        step = 'txs test';
        expect(toSerializableObject(wsTxs)).toEqual(toSerializableObject(httpTxs));

        step = 'utxos ws';
        const wsUtxos = await client.utxoProvider.utxoByAddresses(request);
        step = 'utxos http';
        const httpUtxos = await utxoProvider.utxoByAddresses(request);
        step = 'utxos test';
        expect(toSerializableObject(wsUtxos)).toEqual(toSerializableObject(httpUtxos));
      } catch (error) {
        logger.fatal(name, step, JSON.stringify(request));
        throw error;
      }
    });

    test('utxos from more addresses', async () => {
      openClient({ url: env.WS_PROVIDER_URL });

      const { rows } = await db.query<{ address: Cardano.PaymentAddress }>(`\
SELECT COUNT(DISTINCT tx_id), address FROM tx_out LEFT JOIN tx_in ON tx_out_id = tx_id AND tx_out_index = index
WHERE tx_out_id IS NULL GROUP BY address HAVING COUNT(DISTINCT tx_id) < 1000 ORDER BY COUNT(DISTINCT tx_id) DESC LIMIT 5`);

      const ledgerTip = await firstValueFrom(client.networkInfo.ledgerTip$);
      const lowerBound = Math.floor(ledgerTip.blockNo * 0.8) as Cardano.BlockNo;
      const request = { addresses: rows.flatMap(({ address }) => address), blockRange: { lowerBound }, pagination };

      await client.chainHistoryProvider.transactionsByAddresses(request);

      const wsUtxos = await client.utxoProvider.utxoByAddresses(request);
      const httpUtxos = await utxoProvider.utxoByAddresses(request);
      expect(toSerializableObject(wsUtxos)).toEqual(toSerializableObject(httpUtxos));
    });
  });
});
