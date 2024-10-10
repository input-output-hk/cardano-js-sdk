// cSpell:ignore cardano utxos

import { Cardano, CardanoNode, Seconds, createSlotEpochInfoCalc } from '@cardano-sdk/core';
import { GenesisData } from '..';
import { Logger } from 'ts-log';
import { Metrics } from './metrics';
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

  /** The maximum connections for DB connection pool. Used only for metrics. */
  dbPoolMax?: number;

  /** The heartbeat check interval in seconds. */
  heartbeatInterval?: number;

  /** The heartbeat timeout in seconds. */
  heartbeatTimeout?: number;

  /** The metrics interval in seconds. */
  metricsInterval?: number;

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
  private dbPoolMax?: number;
  private heartbeatInterval: NodeJS.Timer | undefined;
  private lastReceivedNotification = 0;
  private lastSentNotification = 0;
  private lastSlot = Number.POSITIVE_INFINITY as Cardano.Slot;
  private logger: Logger;
  private metrics: Metrics;
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
    this.dbPoolMax = cfg.dbPoolMax;
    this.logger = dependencies.logger;
    this.metrics = new Metrics(cfg.metricsInterval);
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
    this.metrics.close();

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
    /** Not used, just for coherency with `provider-server`. */
    const urlVersion = '/v1.0.0';
    const healthUrl = `${urlVersion}/health`;
    const metricsUrl = `${urlVersion}/metrics`;
    const readyUrl = `${urlVersion}/ready`;

    return createServer(async (req, res) => {
      const { method, url } = req;

      if ([healthUrl, readyUrl].includes(url!)) {
        const healthCheck = await this.healthCheck();

        if (url === healthUrl && healthCheck.notRecoverable) res.statusCode = 500;
        if (url === readyUrl && !healthCheck.ok) res.statusCode = 500;

        return res.end(JSON.stringify(healthCheck));
      }

      if (url === metricsUrl) {
        const { idleCount, totalCount, waitingCount } = this.db;
        const metrics = {
          connectedClients: this.wss.clients.size,
          dbConnCount: totalCount,
          dbConnIdle: idleCount,
          dbConnMax: this.dbPoolMax,
          dbConnWaiting: waitingCount,
          ...this.metrics.get()
        };

        return res.end(
          Object.entries(metrics)
            .map(([key, value]) => `${key} ${value}\n`)
            .join('')
        );
      }

      this.logger.error('HTTP request 404', method, url);

      res.statusCode = 404;
      res.end('Not found');
    });
  }

  private createOnNotification() {
    // This is the entry point for a new NOTIFY event from the DB; i.e. each time a new record is inserted in the block table
    // eslint-disable-next-line sonarjs/cognitive-complexity
    return (msg: Notification) =>
      (async () => {
        this.metrics.add('notify');

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
          const addressesSet = new Set<Cardano.PaymentAddress>();
          for (const ws of this.wss.clients) for (const address of ws.addresses) addressesSet.add(address);
          const addresses = [...addressesSet];

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
      const { logger, metrics, networkInfo, syncing } = this;
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

        metrics.add('sentMessages');
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
      ws.on('error', (error) => {
        metrics.add('connectionErrors');
        ws.logError(error, 'Async error from WebSocket connection');
      });
      // This is the entry point for each new WebSocket message from this connection
      ws.on('message', (data) => {
        metrics.add('receivedMessages');

        // First of all, refresh the heartbeat timeout
        ws.heartbeat = Date.now();

        // This is never expected... just in case
        if (!(data instanceof Buffer))
          return ws.logError(new Error('Not a Buffer'), `Unexpected data from WebSocket ${JSON.stringify(data)}`);

        // DoS protection
        if (data.length > 1024 * 100) {
          metrics.add('badMessagesLong');
          ws.logError(new Error('Buffer too long'), 'Unexpected data length from WebSocket: closing');
          return ws.close();
        }

        let request: WSMessage;

        try {
          request = JSON.parse(data.toString('utf8'));
        } catch (error) {
          metrics.add('badMessagesParse');
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

      this.metrics.add('serverErrors');
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
    let simpleMessagesCount = 0;

    for (const ws of this.wss.clients) {
      const txs = transactions.filter((tx) => isTxRelevant(tx, ws.addresses));

      if (debugLog)
        ws.logDebug(
          `Sending notification: ${
            txs.length === 0 ? stringMessage : JSON.stringify(toSerializableObject({ ...message, transactions: txs }))
          }`
        );

      if (txs.length === 0) {
        ws.send(stringMessage);
        simpleMessagesCount++;
      } else ws.sendMessage({ ...message, transactions: txs });
    }

    if (simpleMessagesCount) this.metrics.add('sentMessages', simpleMessagesCount);
  }

  private sendString(message: string) {
    const { clients } = this.wss;

    for (const ws of clients.values()) ws.send(message);
    this.metrics.add('sentMessages', clients.size);
  }
}
