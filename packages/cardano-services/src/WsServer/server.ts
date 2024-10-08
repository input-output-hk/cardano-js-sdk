// cSpell:ignore cardano utxos

import { Cardano, CardanoNode, Seconds, createSlotEpochInfoCalc } from '@cardano-sdk/core';
import { GenesisData } from '..';
import { Logger } from 'ts-log';
import { NetworkInfoResponses, WSMessage, WsProvider, isTxRelevant } from '@cardano-sdk/cardano-services-client';
import { Notification, Pool } from 'pg';
import { Server, createServer } from 'http';
import { WebSocket, WebSocketServer } from 'ws';
import { getLovelaceSupply, getProtocolParameters, getStake, transactionsByAddresses } from './requests';
import { initDB } from './db';
import { toGenesisParams } from '../NetworkInfo/DbSyncNetworkInfoProvider/mappers';
import { toSerializableObject } from '@cardano-sdk/util';
import { v4 } from 'uuid';

export { WebSocket } from 'ws';

declare module 'ws' {
  interface WebSocket {
    addresses: Cardano.PaymentAddress[];
    clientId: string;
    heartbeat: number;

    logError: (error: Error, msg: string) => void;
    logInfo: (msg: object | string) => void;
    logDebug: (msg: object | string) => void;

    sendMessage: (message: WSMessage) => void;
  }

  interface WebSocketServer {
    clients: Set<WebSocket>;
  }
}

export interface WsServerConfiguration {
  /** The cache time to live in seconds. */
  dbCacheTtl: number;

  /** The heartbeat check interval in seconds. */
  heartbeatInterval?: number;

  /** The heartbeat timeout in seconds. */
  heartbeatTimeout?: number;

  /** The port to listen. */
  port: number;
}

export interface WsServerDependencies {
  /** The `CardanoNode` object. */
  cardanoNode: CardanoNode;

  /** The PostgreSQL Pool. */
  db: Pool;

  /** The `GenesisData` object */
  genesisData: GenesisData;

  /** The logger. */
  logger: Logger;
}

// eslint-disable-next-line @typescript-eslint/no-empty-function
const noop = () => {};

interface NotificationBody {
  message: WSMessage;
  transactions: Cardano.HydratedTx[];
}

interface NotificationEvent {
  notification: number;
  transactions: Cardano.HydratedTx[];
}

/**
 * Since some debug log information may require heavy computation to stringify data,
 * better checking if we are interested in logging some data before actually logging it.
 */
const debugLog = process.env.LOGGER_MIN_SEVERITY === 'debug';

const toError = (error: unknown) =>
  error instanceof Error ? error : new Error(`Unknown error: ${JSON.stringify(error)}`);

export class CardanoWsServer extends WsProvider {
  private cardanoNode: CardanoNode;
  private closeNotify = noop;
  private closing = false;
  private db: Pool;
  private heartbeatInterval: NodeJS.Timer | undefined;
  private lastReceivedNotification = 0;
  private lastSentNotification = 0;
  private lastSlot = Number.POSITIVE_INFINITY as Cardano.Slot;
  private logger: Logger;
  private networkInfo: NetworkInfoResponses;
  private notifications = new Map<number, NotificationBody>();
  private server: Server;
  private stakeInterval: NodeJS.Timer | undefined;
  private syncing = true;
  private wss: WebSocketServer;

  constructor(dependencies: WsServerDependencies, cfg: WsServerConfiguration) {
    super();

    this.cardanoNode = dependencies.cardanoNode;
    this.db = dependencies.db;
    this.logger = dependencies.logger;
    this.networkInfo = { genesisParameters: toGenesisParams(dependencies.genesisData) } as NetworkInfoResponses;

    // Create the HTTP and the WebSocket servers
    this.server = this.createHttpServer();
    this.wss = new WebSocketServer({ path: '/ws', server: this.server }) as WebSocketServer;

    // Attach the handlers to the servers events

    this.wss.on('connection', this.createOnConnection());

    this.server.on('error', (error) => {
      this.logger.error(error, 'Async error from HTTP server');
      this.close();
    });

    this.wss.on('error', (error) => {
      this.logger.error(error, 'Async error from WebSocket server');
      this.close();
    });

    // Init the server
    this.init(
      cfg.port,
      Seconds.toMilliseconds(Seconds(cfg.dbCacheTtl || 120)),
      Seconds.toMilliseconds(Seconds(cfg.heartbeatInterval || 10)),
      Seconds.toMilliseconds(Seconds(cfg.heartbeatTimeout || 60))
    ).catch((error) => {
      this.logger.error(error, 'Error in init sequence');
      this.close();
    });
  }

  /** Closes the server. */
  close(callback?: () => void) {
    this.closing = true;
    this.closeNotify();

    if (this.heartbeatInterval) clearInterval(this.heartbeatInterval);
    if (this.stakeInterval) clearInterval(this.stakeInterval);

    this.wss.close((wsError) => {
      if (wsError && (!(wsError instanceof Error) || wsError.message !== 'The server is not running'))
        this.logger.error(wsError, 'Error while closing the WebSocket server');

      this.server.close((httpError) => {
        // TODO required TypeScript v5.5.4 to remove casting as any
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        if (httpError && (!('code' in httpError) || (httpError as any).code !== 'ERR_SERVER_NOT_RUNNING'))
          this.logger.error(httpError, 'Error while closing the HTTP server');

        if (callback) callback();
      });
    });

    for (const client of this.wss.clients) client.close();
  }

  /** Creates a simple HTTP server which just handles the `/health` URL. Mainly used to listen the WS server. */
  private createHttpServer() {
    return createServer(async (req, res) => {
      const { method, url } = req;

      if (['/health', '/ready'].includes(url!)) {
        const healthCheck = await this.healthCheck();

        if (url === '/health' && healthCheck.notRecoverable) res.statusCode = 500;
        if (url === '/ready' && !healthCheck.ok) res.statusCode = 500;

        return res.end(JSON.stringify(healthCheck));
      }

      this.logger.info(method, url);

      res.statusCode = 404;
      res.end('Not found');
    });
  }

  private createOnNotification() {
    // This is the entry point for a new NOTIFY event from the DB; i.e. each time a new record is inserted in the block table
    // eslint-disable-next-line sonarjs/cognitive-complexity
    return (msg: Notification) =>
      (async () => {
        const notification = ++this.lastReceivedNotification;
        const { payload } = msg;

        if (!payload) throw new Error('Missing payload in NOTIFY');

        // The payload of the NOTIFY event contain the tip in the correct format
        const { blockId, ...ledgerTip } = JSON.parse(payload) as Cardano.Tip & { blockId: string };
        this.networkInfo.ledgerTip = ledgerTip;

        this.logger.debug(`Notification ${notification}: ${JSON.stringify(ledgerTip)}`);

        const epochRollover = async () => {
          if (ledgerTip.slot <= this.lastSlot) return { ledgerTip };

          this.logger.debug(`Epoch rollover for notification ${notification}...`);

          await this.onEpochRollover();

          const { eraSummaries, lovelaceSupply, protocolParameters } = this.networkInfo;

          if (debugLog)
            this.logger.debug(
              `Epoch rollover for notification ${notification}: ${JSON.stringify(
                toSerializableObject({ eraSummaries, lovelaceSupply, protocolParameters })
              )}`
            );

          return { eraSummaries, ledgerTip, lovelaceSupply, protocolParameters };
        };

        const loadTransactions = async () => {
          const addressesObj: Record<Cardano.PaymentAddress, true> = {};

          // Benchmarks
          // https://jsbenchmark.com/#eyJjYXNlcyI6W3siaWQiOiI5aTVXR2E3bXp0MEE2LU1FZFJDaVQiLCJjb2RlIjoiY29uc3QgeyB3c3MgfSA9IERBVEE7XG5cbmNvbnN0IGFkZHJlc3Nlc01hcCA9IG5ldyBNYXAoKTtcbmZvciAoY29uc3Qgd3Mgb2Ygd3NzLmNsaWVudHMpXG4gIGZvciAoY29uc3QgYWRkcmVzcyBvZiB3cy5hZGRyZXNzZXMpXG4gICAgYWRkcmVzc2VzTWFwLnNldChhZGRyZXNzLCB0cnVlKTtcbmNvbnN0IGFkZHJlc3NlcyA9IFsuLi5hZGRyZXNzZXNNYXAua2V5cygpXTsiLCJkZXBlbmRlbmNpZXMiOltdLCJuYW1lIjoiT3JpZ2luYWwifSx7ImlkIjoibVFoLUFZM3JwX1dPWC1keDN6RTJVIiwiY29kZSI6ImNvbnN0IHsgd3NzIH0gPSBEQVRBO1xuICAgICAgICAgIFxuY29uc3QgYWRkcmVzc2VzTWFwID0gWy4uLndzcy5jbGllbnRzXVxuICAuZmxhdE1hcChpdCA9PiBpdC5hZGRyZXNzZXMpXG4gIC5yZWR1Y2UoKHJlc3VsdCwgaXQpID0-ICh7Li4ucmVzdWx0LCBbaXRdOiB0cnVlfSksIHt9KTtcbmNvbnN0IGFkZHJlc3NlcyA9IFtPYmplY3Qua2V5cyhhZGRyZXNzZXNNYXApXTsiLCJuYW1lIjoiRmlyc3QgcHJvcG9zYWwiLCJkZXBlbmRlbmNpZXMiOltdfSx7ImlkIjoibE5fM29CdS1rQlVUMlJ5U24wcU1tIiwiY29kZSI6ImNvbnN0IHsgd3NzIH0gPSBEQVRBO1xuXG5jb25zdCBhZGRyZXNzZXNNYXAgPSBbLi4ud3NzLmNsaWVudHNdXG4gIC5mbGF0TWFwKGl0ID0-IGl0LmFkZHJlc3NlcylcbiAgLnJlZHVjZSgocmVzdWx0LCBpdCkgPT4ge1xuICBcdHJlc3VsdFtpdF0gPSB0cnVlXG5cdHJldHVybiByZXN1bHRcbiAgfSwge30pO1xuY29uc3QgYWRkcmVzc2VzID0gW09iamVjdC5rZXlzKGFkZHJlc3Nlc01hcCldOyIsIm5hbWUiOiJTZWNvbmQgcHJvcG9zYWwiLCJkZXBlbmRlbmNpZXMiOltdfSx7ImlkIjoiSW5zLXdFX2p2amVLYzlUOUlTaWFfIiwiY29kZSI6ImNvbnN0IHsgd3NzIH0gPSBEQVRBO1xuXG5jb25zdCBhZGRyZXNzZXNTZXQgPSBuZXcgU2V0KCk7XG5mb3IgKGNvbnN0IHdzIG9mIHdzcy5jbGllbnRzKVxuICBmb3IgKGNvbnN0IGFkZHJlc3Mgb2Ygd3MuYWRkcmVzc2VzKVxuICAgIGFkZHJlc3Nlc1NldC5hZGQoYWRkcmVzcyk7XG5jb25zdCBhZGRyZXNzZXMgPSBbLi4uYWRkcmVzc2VzU2V0XTsiLCJkZXBlbmRlbmNpZXMiOltdLCJuYW1lIjoiVGhpcmQgcHJvcG9zYWwifSx7ImlkIjoiNE9hWEF0REJFb184eXRrVDFyWGhKIiwiY29kZSI6ImNvbnN0IHsgd3NzIH0gPSBEQVRBO1xuXG5jb25zdCBhZGRyZXNzZXNTZXQgPSBuZXcgU2V0KFsuLi53c3MuY2xpZW50c10uZmxhdE1hcCh3cyA9PiB3cy5hZGRyZXNzZXMpKTtcbmNvbnN0IGFkZHJlc3NlcyA9IFsuLi5hZGRyZXNzZXNTZXRdOyIsImRlcGVuZGVuY2llcyI6W10sIm5hbWUiOiJmbGF0TWFwIn0seyJpZCI6Im15SlJyRmpHUzROZC1YYXdZYmo5QyIsImNvZGUiOiJjb25zdCB7IHdzcyB9ID0gREFUQTtcblxuY29uc3QgYWRkcmVzc2VzU2V0ID0gbmV3IFNldCgpO1xuZm9yIChjb25zdCB3cyBvZiB3c3MuY2xpZW50cykge1xuICBjb25zdCBhZGRyZXNzZXMgPSB3cy5hZGRyZXNzZXM7XG4gIGZvciAobGV0IGkgPSAwOyBpIDwgYWRkcmVzc2VzLmxlbmd0aDsgKytpKVxuICAgIGFkZHJlc3Nlc1NldC5hZGQoYWRkcmVzc2VzW2ldKTtcbn1cbmNvbnN0IGFkZHJlc3NlcyA9IFsuLi5hZGRyZXNzZXNTZXRdOyIsImRlcGVuZGVuY2llcyI6W10sIm5hbWUiOiJBbm90aGVyIGF0dGVtcHQifSx7ImlkIjoibUFLa0hMSF9IWUxhd2dzaE9ldElaIiwiY29kZSI6ImNvbnN0IHsgd3NzIH0gPSBEQVRBO1xuXG5jb25zdCBhZGRyZXNzZXNTZXQgPSBuZXcgU2V0KCk7XG5mb3IgKGNvbnN0IHdzIG9mIHdzcy5jbGllbnRzKSB7XG4gIGNvbnN0IHsgYWRkcmVzc2VzIH0gPSB3cy5hZGRyZXNzZXM7XG4gIGNvbnN0IHsgbGVuZ3RoIH0gPSBhZGRyZXNzZXNcblxuICBmb3IgKGxldCBpID0gMDsgaSA8IGxlbmd0aDsgKytpKSBhZGRyZXNzZXNTZXQuYWRkKGFkZHJlc3Nlc1tpXSk7XG59XG5jb25zdCBhZGRyZXNzZXMgPSBbLi4uYWRkcmVzc2VzU2V0XTsiLCJkZXBlbmRlbmNpZXMiOltdLCJuYW1lIjoiRXZlbiBiZXR0ZXIifSx7ImlkIjoiTFcyTGJEaVBBT3AtMlNFZVVoSFJFIiwiY29kZSI6ImNvbnN0IHsgd3NzIH0gPSBEQVRBO1xuXG5jb25zdCBhZGRyZXNzZXNNYXAgPSB7fTtcbmZvciAoY29uc3Qgd3Mgb2Ygd3NzLmNsaWVudHMpXG4gIGZvciAoY29uc3QgYWRkcmVzcyBvZiB3cy5hZGRyZXNzZXMpXG4gICAgYWRkcmVzc2VzTWFwW2FkZHJlc3NdID0gdHJ1ZTtcbmNvbnN0IGFkZHJlc3NlcyA9IE9iamVjdC5rZXlzKGFkZHJlc3Nlc01hcCk7IiwiZGVwZW5kZW5jaWVzIjpbXSwibmFtZSI6Ik9iamVjdCAxIn0seyJpZCI6Im9LMm5IQ3JJTzg2bFl2TmwyMGprbyIsImNvZGUiOiJjb25zdCB7IHdzcyB9ID0gREFUQTtcblxuY29uc3QgYWRkcmVzc2VzTWFwID0ge307XG5cbmZvciAoY29uc3Qgd3Mgb2Ygd3NzLmNsaWVudHMpIHtcbiAgY29uc3QgYWRkcmVzc2VzID0gd3MuYWRkcmVzc2VzO1xuICBmb3IgKGxldCBhTGVuID0gYWRkcmVzc2VzLmxlbmd0aDsgYUxlbi0tOylcbiAgICBhZGRyZXNzZXNNYXBbYWRkcmVzc2VzW2FMZW5dXSA9IHRydWU7XG59XG4gIFxuY29uc3QgYWRkcmVzc2VzID0gT2JqZWN0LmtleXMoYWRkcmVzc2VzTWFwKTsiLCJkZXBlbmRlbmNpZXMiOltdLCJuYW1lIjoiT2JqZWN0IDIifSx7ImlkIjoiT0p0TklnRVBvb3BoaDNoVHdhQktHIiwiY29kZSI6ImNvbnN0IHsgd3NzIH0gPSBEQVRBO1xuXG5jb25zdCBhZGRyZXNzZXNNYXAgPSB7fTtcblxuZm9yIChjb25zdCB3cyBvZiB3c3MuY2xpZW50cylcbiAgZm9yIChjb25zdCBhZGRyZXNzIG9mIHdzLmFkZHJlc3NlcylcbiAgICBhZGRyZXNzZXNNYXBbYWRkcmVzc10gPSB0cnVlO1xuICBcbmNvbnN0IGFkZHJlc3NlcyA9IE9iamVjdC5rZXlzKGFkZHJlc3Nlc01hcCk7IiwiZGVwZW5kZW5jaWVzIjpbXSwibmFtZSI6Ik9iamVjdCAzIn1dLCJjb25maWciOnsibmFtZSI6IkJhc2ljIGV4YW1wbGUiLCJwYXJhbGxlbCI6dHJ1ZSwiZ2xvYmFsVGVzdENvbmZpZyI6eyJkZXBlbmRlbmNpZXMiOlt7InVybCI6Imh0dHBzOi8vY2RuLmpzZGVsaXZyLm5ldC9ucG0vQGZha2VyLWpzL2Zha2VyQDguMC4yLytlc20iLCJuYW1lIjoiRkFLRVIiLCJlc20iOnRydWV9XX0sImRhdGFDb2RlIjoiY29uc3QgeyB1dWlkIH0gPSBGQUtFUi5mYWtlci5zdHJpbmc7XG5jb25zdCBhZGRyZXNzZXMgPSBbXTtcbmNvbnN0IGNsaWVudHMgPSBbXTtcblxubGV0IGFJZHggPSAwO1xuXG4vLyBTaW11bGF0ZSAxMDAwIGNvbm5lY3RlZCBjbGllbnRzIHdpdGggMTAwIHN1YnNjcmliZWQgYWRkcmVzc2VzXG5mb3IobGV0IGNJZHg7IGNJZHggPCAxMDAwMDsgY0lkeCsrKSB7XG4gIGNvbnN0IHdzID0geyBhZGRyZXNzZXM6IFtdIH07XG5cbiAgLy8gU2ltdWxhdGUgMSUgb2YgdXNlcnMgaGF2ZSB0aGUgc2FtZSB3YWxsZXQgY29ubmVjdGVkIGZyb21cbiAgLy8gdHdvIGRpc3RpbmN0IExhY2UgaW5zdGFuY2VzXG4gIGlmKGNJZHggJiYgTWF0aC5yYW5kb20oKSA8IDAuMDEpXG4gICAgY2xpZW50cy5wdXNoKGNsaWVudHNbW01hdGguZmxvb3IoTWF0aC5yYW5kb20oKSAqIGNsaWVudHMubGVndGgpXV0pO1xuICBlbHNlXG4gICAgZm9yKGxldCBpID0gMDsgaSA8IDEwMDsgKytpKSB7XG4gICAgICAvLyBTaW11bGF0ZSAwLjElIG9mIGFkZHJlc3NlcyBpcyBzdWJzY3JpYmVkIGJ5IGRpc3RpbmN0IHVzZXJzXG4gICAgICAvLyBpLmUuIHNoYXJlZCB3YWxsZXRzXG4gICAgICBpZihjSWR4ICYmIE1hdGgucmFuZG9tKCkgPCAwLjAwMSlcbiAgICAgICAgd3MuYWRkcmVzc2VzLnB1c2goYWRkcmVzc2VzW01hdGguZmxvb3IoTWF0aC5yYW5kb20oKSAqIGFkZHJlc3Nlcy5sZWd0aCldKTtcbiAgICAgIGVsc2Uge1xuICAgICAgICAvLyBBcGFydCBmcm9tIHRoZSBmaXhlZCBwcmVmaXhcbiAgICAgICAgLy8gYWRkcmVzc2VzIGFuZCB1dWlkcyBhcmUgbG9uZyBzZXF1ZW5jZXMgb2YgcmFuZG9tIGNoYXJhY3RlcnNcbiAgICAgICAgY29uc3QgYWRkcmVzcyA9IFwiYWRkcl9cIiArIHV1aWQoKTtcblxuICAgICAgICBhZGRyZXNzZXNbYUlkeCsrXSA9IGFkZHJlc3M7XG4gICAgICAgIHdzLmFkZHJlc3Nlcy5wdXNoKGFkZHJlc3MpO1xuICAgICAgfVxuXG4gICAgICBjbGllbnRzLnB1c2god3MpO1xuICAgIH1cbn1cblxucmV0dXJuIHsgd3NzOiB7IGNsaWVudHM6IG5ldyBTZXQoY2xpZW50cykgfSB9OyJ9fQ
          for (const ws of this.wss.clients) {
            const addresses = ws.addresses;
            // eslint-disable-next-line space-in-parens
            for (let aLen = addresses.length; aLen--; ) addressesObj[addresses[aLen]] = true;
          }

          const addresses = Object.keys(addressesObj) as Cardano.PaymentAddress[];

          if (debugLog) this.logger.debug(`Transactions for notification ${notification} ${JSON.stringify(addresses)}`);

          const txs = addresses.length === 0 ? [] : await transactionsByAddresses(addresses, this.db, { blockId });

          if (debugLog) this.logger.debug(`Transactions for notification ${notification} ${JSON.stringify(txs)}`);

          return txs;
        };

        const [networkInfo, transactions] = await Promise.all([epochRollover(), loadTransactions()]);

        this.send({ networkInfo }, { notification, transactions });
      })().catch((error) => {
        this.logger.error(error, 'Error while handling tip notification');
        // Since an error while handling tip notification may be source of data inconsistencies, better to shutdown
        this.emitHealth(
          error instanceof Error ? error.message || 'Unknown error' : `Unknown error ${JSON.stringify(error)}`,
          { notRecoverable: true, overwrite: true }
        );
        this.close();
      });
  }

  private listenNotify() {
    const { db, logger } = this;

    // This is the function which listens for events throw the NOTIFY command.
    // It recursively calls itself to handle reconnection.
    const addListener = () => {
      logger.info('Connecting to DB to listen on sdk_tip NOTIFY...');

      // eslint-disable-next-line unicorn/consistent-function-scoping
      const reAddListener = () => {
        // eslint-disable-next-line unicorn/consistent-destructuring
        if (!this.closing) setTimeout(addListener, 1000).unref();
      };

      // Ask for a DB client to the connections pool.
      db.connect((err, client, done) => {
        if (err) {
          logger.error(err, 'Error while connecting to DB to listen on sdk_tip NOTIFY');
          this.emitHealth(err.message, { overwrite: true });

          // In case of error opening the DB client, just retry after 1".
          return reAddListener();
        }

        logger.info('Connected to DB to listen on sdk_tip NOTIFY');

        // Set the function to close the client; used here for error handling and later by server close
        this.closeNotify = () => {
          logger.info('Closing DB connection listening on sdk_tip NOTIFY');
          this.emitHealth('closing');
          // Resets itself, in case it is called more than once...
          this.closeNotify = noop;
          done();
        };

        // Attach the handlers to the DB client events

        client.on('end', () => {
          this.emitHealth('closed');

          // Being this the client closed event handler, there is no longer need for the function to close it
          this.closeNotify = noop;

          // If the connection was closed because the server is being closed as well, that's all
          // For any other reason the connection was closed, just retry a new connection
          reAddListener();
        });

        client.on('error', (e) => {
          logger.error(e, 'Async error from sdk_tip NOTIFY');
          this.emitHealth(e.message, { overwrite: true });
          this.closeNotify();
        });

        // eslint-disable-next-line unicorn/consistent-destructuring
        client.on('notification', this.createOnNotification());

        // Issue the LISTEN command to get the notification event
        client.query('LISTEN sdk_tip', (e) => {
          if (!e) return;

          logger.error(e, 'Error while listening on sdk_tip NOTIFY');
          this.emitHealth(e.message, { overwrite: true });
          this.closeNotify();
        });
      });
    };

    addListener();
  }

  private async init(port: number, dbCacheTtl: number, heartbeatInterval: number, heartbeatTimeout: number) {
    const { cardanoNode, db, logger, networkInfo, server, wss } = this;

    const refreshStake = async () => {
      const stake = await getStake(cardanoNode, db);

      networkInfo.stake = stake;

      this.send({ networkInfo: { stake } });
    };

    networkInfo.ledgerTip = await initDB(db, logger);
    await Promise.all([this.onEpochRollover(), refreshStake()]);

    this.stakeInterval = setInterval(
      () =>
        refreshStake().catch((error) => {
          logger.error(error, 'Error while refreshing stake');
          this.close();
        }),
      dbCacheTtl
    );
    // eslint-disable-next-line unicorn/consistent-destructuring
    this.stakeInterval.unref();

    this.heartbeatInterval = setInterval(() => {
      const threshold = Date.now() - heartbeatTimeout;

      for (const ws of wss.clients.values())
        if (ws.heartbeat < threshold) {
          ws.logInfo('Timed out, closing');
          ws.close();
        }
    }, heartbeatInterval);
    // eslint-disable-next-line unicorn/consistent-destructuring
    this.heartbeatInterval.unref();

    const check = async () => {
      const { localNode } = await cardanoNode.healthCheck();

      if (!localNode) throw new Error('Missing node health check response');
      if (!localNode.ledgerTip) throw new Error('Missing "ledgerTip" in node health check response');
      if (!localNode.networkSync) throw new Error('Missing "networkSync" in node health check response');

      const projectedTip = networkInfo.ledgerTip;
      const tipDiff = localNode.ledgerTip.blockNo - projectedTip.blockNo;

      // Two blocks difference tolerance
      if (tipDiff >= 2) return this.emitHealth({ localNode, ok: false, projectedTip });

      // Leave untouched the status set by healthCheck in init method
      if (localNode.ledgerTip.blockNo === 0) return;

      const ok = localNode.networkSync >= 0.999;

      // eslint-disable-next-line unicorn/consistent-destructuring
      if (ok && this.syncing) this.syncing = false;

      this.emitHealth({ localNode, ok, projectedTip });
    };

    const healthCheck = () => {
      check()
        .finally(() => setTimeout(healthCheck, 1000).unref())
        .catch((error_) => {
          const error = toError(error_);

          this.emitHealth(error.message);
          logger.error(error, 'While checking node health check');
        });
    };

    // Check synchronously to be sure init is complete
    await check();
    // Next schedule asynchronous checks
    healthCheck();

    server.listen(port, () => logger.info('WebSocket server ready and listening'));
    this.listenNotify();
  }

  private createOnConnection() {
    // This is the entry point for each new WebSocket connection
    return (ws: WebSocket) => {
      const { logger, networkInfo, syncing } = this;
      const clientId = (ws.clientId = v4());

      ws.addresses = [];

      // Create some wrappers for the logger
      ws.logError = (error: Error, msg: string) => {
        logger.error({ clientId }, msg);
        logger.error(error, msg);
      };
      ws.logInfo = (msg: object | string) =>
        logger.info(...(typeof msg === 'string' ? [{ clientId }, msg] : [{ clientId, ...msg }]));
      ws.logDebug = (msg: object | string) =>
        logger.debug(...(typeof msg === 'string' ? [{ clientId }, msg] : [{ clientId, ...msg }]));

      ws.sendMessage = (message: WSMessage) => {
        const stringMessage = JSON.stringify(toSerializableObject(message));

        ws.logDebug(stringMessage);
        ws.send(stringMessage);
      };

      const onClose = (close?: boolean) => {
        if (close) ws.close();
        ws.logInfo('Connection closed');
        // eslint-disable-next-line @typescript-eslint/no-empty-function
        ws.sendMessage = () => {};
      };

      ws.logInfo('Connected');

      // If still syncing, actually do not accept connections
      if (syncing) {
        ws.sendMessage({ clientId, syncing: true });
        setTimeout(() => onClose(true), 1000);

        return;
      }

      // Attach the handlers to the WS connection events

      ws.on('close', onClose);
      ws.on('error', (error) => ws.logError(error, 'Async error from WebSocket connection'));
      // This is the entry point for each new WebSocket message from this connection
      ws.on('message', (data) => {
        // First of all, refresh the heartbeat timeout
        ws.heartbeat = Date.now();

        // This is never expected... just in case
        if (!(data instanceof Buffer))
          return ws.logError(new Error('Not a Buffer'), `Unexpected data from WebSocket ${JSON.stringify(data)}`);

        // DoS protection
        if (data.length > 1024 * 100) {
          ws.logError(new Error('Buffer too long'), 'Unexpected data length from WebSocket: closing');
          return ws.close();
        }

        let request: WSMessage;

        try {
          request = JSON.parse(data.toString('utf8'));
        } catch (error) {
          ws.logError(error as Error, 'Error parsing message: closing');
          return ws.close();
        }

        // Heartbeat messages do not expect a response
        if (Object.keys(request).length === 0) return;

        this.request(ws, request).catch((error) => ws.logError(error, 'Error while processing request'));
      });

      // Actually set the timeout for the first time
      ws.heartbeat = Date.now();
      ws.sendMessage({ clientId, networkInfo });
    };
  }

  private async onEpochRollover() {
    const { cardanoNode, db, networkInfo } = this;

    // Immediately calculate last slot for this epoch (even if with old era summaries) to avoid the event being called twice
    if (networkInfo.eraSummaries)
      this.lastSlot = createSlotEpochInfoCalc(networkInfo.eraSummaries)(networkInfo.ledgerTip.slot).lastSlot.slot;

    [networkInfo.eraSummaries, networkInfo.lovelaceSupply, networkInfo.protocolParameters] = await Promise.all([
      cardanoNode.eraSummaries(),
      getLovelaceSupply(db, networkInfo.genesisParameters.maxLovelaceSupply),
      getProtocolParameters(db)
    ]);

    // Calculate last slot for this epoch with new era summaries
    this.lastSlot = createSlotEpochInfoCalc(networkInfo.eraSummaries)(networkInfo.ledgerTip.slot).lastSlot.slot;
  }

  private async request(ws: WebSocket, request: WSMessage) {
    const { txsByAddresses, requestId } = request;

    try {
      ws.logInfo(request);

      if (txsByAddresses) {
        const action = (transactions?: Cardano.HydratedTx[], utxos?: Cardano.HydratedTx[]) => {
          if (transactions) ws.logInfo(`Sending ${transactions.length} transactions for request ${requestId}`);
          if (utxos) ws.logInfo(`Sending ${utxos.length} partial transactions for request ${requestId}`);

          ws.sendMessage({ transactions, utxos });
        };

        const { addresses, lower } = txsByAddresses;

        ws.addresses.push(...addresses);
        await transactionsByAddresses(addresses, this.db, { action, lower });
      }

      if (requestId) {
        ws.logInfo(`Responding to request ${requestId}`);
        ws.sendMessage({ responseTo: requestId });
      }
    } catch (error_) {
      const error = toError(error_);

      ws.logError(error, 'While performing request');
      if (requestId) ws.sendMessage({ error, responseTo: requestId });
    }
  }

  private send(message: WSMessage, notificationEvent?: NotificationEvent) {
    // If the message is not bound to a tip notification, just send it
    if (!notificationEvent) return this.sendString(JSON.stringify(toSerializableObject(message)));

    const { notification, transactions } = notificationEvent;

    if (debugLog) this.logger.debug(`Scheduling notification: ${JSON.stringify(toSerializableObject(message))}`);

    // Ensure messages from notifications are propagated in the same order as the notification was received
    this.notifications.set(notification, { message, transactions });

    while (this.notifications.has(this.lastSentNotification + 1)) {
      this.sendNotification(this.notifications.get(++this.lastSentNotification)!);
      this.notifications.delete(this.lastSentNotification);
    }
  }

  private sendNotification(notification: NotificationBody) {
    const { message, transactions } = notification;
    const stringMessage = JSON.stringify(toSerializableObject(message));

    for (const ws of this.wss.clients) {
      const txs = transactions.filter((tx) => isTxRelevant(tx, ws.addresses));

      if (debugLog)
        ws.logDebug(
          `Sending notification: ${
            txs.length === 0 ? stringMessage : JSON.stringify(toSerializableObject({ ...message, transactions: txs }))
          }`
        );

      txs.length === 0 ? ws.send(stringMessage) : ws.sendMessage({ ...message, transactions: txs });
    }
  }

  private sendString(message: string) {
    for (const ws of this.wss.clients.values()) ws.send(message);
  }
}
