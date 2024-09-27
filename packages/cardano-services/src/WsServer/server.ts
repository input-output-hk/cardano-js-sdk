import { Cardano, CardanoNode, Seconds, createSlotEpochInfoCalc } from '@cardano-sdk/core';
import { GenesisData } from '..';
import { Logger } from 'ts-log';
import { NetworkInfoResponses, WSMessage, WsProvider } from '@cardano-sdk/cardano-services-client';
import { Notification, Pool } from 'pg';
import { Server, createServer } from 'http';
import { WebSocket, WebSocketServer } from 'ws';
import { getLovelaceSupply, getProtocolParameters, getStake } from './requests';
import { initDB } from './db';
import { toGenesisParams } from '../NetworkInfo/DbSyncNetworkInfoProvider/mappers';
import { toSerializableObject } from '@cardano-sdk/util';
import { v4 } from 'uuid';

export { WebSocket } from 'ws';

declare module 'ws' {
  interface WebSocket {
    clientId: string;
    heartbeat: number;

    logError: (error: Error, msg: string) => void;
    logInfo: (msg: string) => void;
  }

  interface WebSocketServer {
    clients: Set<WebSocket>;
  }
}

export interface WsServerConfiguration {
  /** The cache time to live in seconds. */
  dbCacheTtl: number;

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
  private notifications = new Map<number, WSMessage>();
  private server: Server;
  private stakeInterval: NodeJS.Timer | undefined;
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
      if (wsError) this.logger.error(wsError, 'Error while closing the WebSocket server');

      this.server.close((httpError) => {
        if (httpError) this.logger.error(httpError, 'Error while closing the HTTP server');

        if (callback) callback();
      });
    });

    for (const client of this.wss.clients) client.close();
  }

  /** Creates a simple HTTP server which just handles the `/health` URL. Mainly used to listen the WS server. */
  private createHttpServer() {
    return createServer(async (req, res) => {
      if (req.url === '/health') return res.end(JSON.stringify(await this.healthCheck()));

      this.logger.info(req.method, req.url);

      res.statusCode = 404;
      res.end('Not found');
    });
  }

  private createOnNotification() {
    // This is the entry point for a new NOTIFY event from the DB; i.e. each time a new record is inserted in the block table
    return (msg: Notification) => {
      (async () => {
        const notification = ++this.lastReceivedNotification;
        const { payload } = msg;

        if (!payload) throw new Error('Missing payload in NOTIFY');

        // The payload of the NOTIFY event contain the tip in the correct format
        const ledgerTip = JSON.parse(payload) as Cardano.Tip;
        this.networkInfo.ledgerTip = ledgerTip;

        let networkInfo: WSMessage['networkInfo'];

        if (ledgerTip.slot <= this.lastSlot) networkInfo = { ledgerTip };
        else {
          await this.onEpochRollover();

          const { eraSummaries, lovelaceSupply, protocolParameters } = this.networkInfo;

          networkInfo = { eraSummaries, ledgerTip, lovelaceSupply, protocolParameters };
        }

        this.send({ networkInfo }, notification);
      })().catch((error) => {
        this.logger.error(error, 'Error while handling tip notification');
        // Since an error while handling tip notification may be source of data inconsistencies, better to shutdown
        this.close();
      });
    };
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
          this.emitHealth(err.message, true);

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
          this.emitHealth(e.message, true);
          this.closeNotify();
        });

        // eslint-disable-next-line unicorn/consistent-destructuring
        client.on('notification', this.createOnNotification());

        // Issue the LISTEN command to get the notification event
        client.query('LISTEN sdk_tip', (e) => {
          // If there was no errors in the statement, set the flag for the health check
          if (!e) return this.emitHealth();

          logger.error(e, 'Error while listening on sdk_tip NOTIFY');
          this.emitHealth(e.message, true);
          this.closeNotify();
        });
      });
    };

    addListener();
  }

  private async init(port: number, dbCacheTtl: number, heartbeatTimeout: number) {
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
    }, 10_000);
    // eslint-disable-next-line unicorn/consistent-destructuring
    this.heartbeatInterval.unref();

    server.listen(port, () => logger.info('WebSocket server ready and listening'));
    this.listenNotify();
  }

  private createOnConnection() {
    const { logger, networkInfo } = this;

    // This is the entry point for each new WebSocket connection
    return (ws: WebSocket) => {
      const clientId = (ws.clientId = v4());
      const stringMessage = JSON.stringify(toSerializableObject({ clientId, networkInfo }));

      // Create some wrappers for the logger
      ws.logInfo = (msg: string) => logger.info({ clientId }, msg);
      ws.logError = (error: Error, msg: string) => {
        logger.error({ clientId }, msg);
        logger.error(error, msg);
      };

      ws.logInfo('Connected');

      // Attach the handlers to the WS connection events

      ws.on('close', () => ws.logInfo('Connection closed'));
      ws.on('error', (error) => ws.logError(error, 'Async error from WebSocket connection'));
      // This is the entry point for each new WebSocket message from this connection
      ws.on('message', (data) => {
        // First of all, refresh the heartbeat timeout
        ws.heartbeat = Date.now();

        // This is never expected... just in case
        if (!(data instanceof Buffer))
          return ws.logError(
            new Error('Not a Buffer'),
            `Unexpected data from WebSocket connection ${JSON.stringify(data)}`
          );
      });

      // Actually set the timeout for the first time
      ws.heartbeat = Date.now();
      ws.send(stringMessage);
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

  private send(message: WSMessage, notification?: number) {
    // If the message is not bound to a tip notification, just send it
    if (!notification) return this.sendString(JSON.stringify(toSerializableObject(message)));

    // Ensure messages from notifications are propagated in the same order as the notification was received
    this.notifications.set(notification, message);

    while (this.notifications.has(this.lastSentNotification + 1)) {
      const msg = this.notifications.get(++this.lastSentNotification);
      this.notifications.delete(this.lastSentNotification);

      this.sendString(JSON.stringify(toSerializableObject(msg)));
    }
  }

  private sendString(message: string) {
    for (const ws of this.wss.clients.values()) ws.send(message);
  }
}
