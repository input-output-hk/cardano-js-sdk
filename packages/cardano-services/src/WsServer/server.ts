// cSpell:ignore njson

import { Cardano, CardanoNode, NetworkInfoResponses, WSMessage, createSlotEpochInfoCalc } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { NJSON } from 'next-json';
import { Notification, Pool } from 'pg';
import { Server, createServer } from 'http';
import { WebSocket, WebSocketServer } from 'ws';
import { getLovelaceSupply, getProtocolParameters, getStake } from './requests';
import { initDB } from './db';
import { v4 } from 'uuid';

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
  genesis: Cardano.CompactGenesis;

  /** The logger. */
  logger: Logger;
}

// eslint-disable-next-line @typescript-eslint/no-empty-function
const noop = () => {};

export class CardanoWsServer {
  private cardanoNode: CardanoNode;
  private closeNotify = noop;
  private closing = false;
  private db: Pool;
  private lastSlot: Cardano.Slot;
  private logger: Logger;
  private networkInfo: NetworkInfoResponses;
  private notifyConnected = false;
  private server: Server;
  private wss: WebSocketServer;

  constructor(dependencies: WsServerDependencies, cfg: WsServerConfiguration) {
    this.cardanoNode = dependencies.cardanoNode;
    this.db = dependencies.db;
    this.logger = dependencies.logger;
    this.networkInfo = { genesisParameters: dependencies.genesis } as NetworkInfoResponses;

    // Create the HTTP and the WebSocket servers
    this.server = this.createHttpServer();
    this.wss = new WebSocketServer({ server: this.server });

    // Attach the handlers to the servers events

    this.wss.on('connection', this.createOnConnection((cfg.heartbeatTimeout || 60) * 1000));

    this.server.on('error', (error) => {
      this.logger.error(error, 'Async error from HTTP server');
      this.close();
    });

    this.wss.on('error', (error) => {
      this.logger.error(error, 'Async error from WebSocket server');
      this.close();
    });

    // Init the server
    this.init(cfg.port, (cfg.dbCacheTtl || 120) * 1000).catch((error) => {
      this.logger.error(error, 'Error in init sequence');
      this.close();
    });
  }

  /** Closes the server. */
  close(callback?: () => void) {
    this.closing = true;
    this.closeNotify();

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
    return createServer((req, res) => {
      if (req.url === '/health') {
        const { closing, notifyConnected } = this;

        return res.end(JSON.stringify({ details: { closing, notifyConnected }, ok: !closing && notifyConnected }));
      }

      this.logger.info(req.method, req.url);

      res.statusCode = 404;
      res.end('Not found');
    });
  }

  private createOnNotification() {
    // This is the entry point for a new NOTIFY event from the DB; i.e. each time a new record is inserted in the block table
    return (msg: Notification) => {
      (async () => {
        const { payload } = msg;

        if (!payload) throw new Error('Missing payload in NOTIFY');

        // The payload of the NOTIFY event contain the tip in the correct format
        this.networkInfo.ledgerTip = JSON.parse(payload);

        const message: WSMessage = { networkInfo: { ledgerTip: this.networkInfo.ledgerTip } };

        if (this.networkInfo.ledgerTip.slot > this.lastSlot) {
          await this.onEpochRollover();

          message.networkInfo!.eraSummaries = this.networkInfo.eraSummaries;
          message.networkInfo!.lovelaceSupply = this.networkInfo.lovelaceSupply;
          message.networkInfo!.protocolParameters = this.networkInfo.protocolParameters;
        }

        // Create only once a stringified version of a message with the new tip
        const stringMessage = NJSON.stringify(message);
        // Propagate the new tip to all the connected clients
        for (const ws of this.wss.clients.values()) ws.send(stringMessage);
      })().catch((error) => {
        this.logger.error(error, 'Error while handling tip notification');
        this.closeNotify();
      });
    };
  }

  private listenNotify() {
    const { db, logger } = this;

    // This is the function which listens for events throw the NOTIFY command.
    // It recursively calls itself to handle reconnection.
    const addListener = () => {
      logger.info('Connecting to DB to listen on sdk_tip NOTIFY...');

      // Ask for a DB client to the connections pool.
      db.connect((err, client, done) => {
        if (err) {
          logger.error(err, 'Error while connecting to DB to listen on sdk_tip NOTIFY');

          // In case of error opening the DB client, just retry after 1".
          return setTimeout(addListener, 1000).unref();
        }

        logger.info('Connected to DB to listen on sdk_tip NOTIFY');

        // Set the function to close the client; used here for error handling and later by server close
        this.closeNotify = () => {
          logger.info('Closing DB connection listening on sdk_tip NOTIFY');
          // Resets itself, in case it is called more than once...
          this.closeNotify = noop;
          done();
        };

        // Attach the handlers to the DB client events

        client.on('end', () => {
          const { closing } = this;

          // Being this the client closed event handler, there is no longer need for the function to close it
          this.closeNotify = noop;
          // Set the flag for the health check
          this.notifyConnected = false;

          // If the connection was closed because the server is being closed as well, that's all
          // For any other reason the connection was closed, just retry a new connection
          if (!closing) addListener();
        });

        client.on('error', (e) => {
          logger.error(e, 'Async error from sdk_tip NOTIFY');
          this.closeNotify();
        });

        // eslint-disable-next-line unicorn/consistent-destructuring
        client.on('notification', this.createOnNotification());

        // Issue the LISTEN command to get the notification event
        client.query('LISTEN sdk_tip', (e) => {
          // If there was no errors in the statement, set the flag for the health check
          if (!e) return (this.notifyConnected = true);

          logger.error(e, 'Error while listening on sdk_tip NOTIFY');
          this.closeNotify();
        });
      });
    };

    addListener();
  }

  private async init(port: number, dbCacheTtl: number) {
    const { cardanoNode, db, logger, networkInfo, server, wss } = this;

    const refreshStake = async () => {
      const stake = await getStake(cardanoNode, db);

      networkInfo.stake = stake;

      const stringMessage = NJSON.stringify({ networkInfo: { stake } });
      for (const ws of wss.clients.values()) ws.send(stringMessage);
    };

    networkInfo.ledgerTip = await initDB(db, logger);
    await Promise.all([this.onEpochRollover(), refreshStake()]);

    setInterval(
      () =>
        refreshStake().catch((error) => {
          logger.error(error, 'Error while refreshing stake');
          this.close();
        }),
      dbCacheTtl
    ).unref();

    server.listen(port, () => logger.info('WebSocket server ready and listening'));
    this.listenNotify();
  }

  private createOnConnection(heartbeatTimeout: number) {
    const { logger, networkInfo } = this;

    // This is the entry point for each new WebSocket connection
    return (ws: WebSocket) => {
      const clientId = v4();
      const stringMessage = NJSON.stringify({ clientId, networkInfo });
      let timeout: NodeJS.Timeout;

      // Create some wrappers for the logger
      const logInfo = (msg: string) => logger.info({ clientId }, msg);
      const logError = (error: Error, msg: string) => {
        logger.error({ clientId }, msg);
        logger.error(error, msg);
      };

      logInfo('Connected');

      // Heartbeat timeout handling
      const refreshTimeout = () => {
        // If a timeout was previously set, reset it
        if (timeout) clearTimeout(timeout);

        // Set the new timeout
        timeout = setTimeout(() => {
          logInfo('Heartbeat timeout: closing connection');
          // If the timeout expires, close the WS connection
          ws.close();
        }, heartbeatTimeout);
        timeout.unref();
      };

      // Attach the handlers to the WS connection events

      ws.on('close', () => {
        // The connection was closed, there's no longer need to check if it timed out
        if (timeout) clearTimeout(timeout);
        logInfo('Connection closed');
      });
      ws.on('error', (error) => logError(error, 'Async error from WebSocket connection'));
      // This is the entry point for each new WebSocket message from this connection
      ws.on('message', (data) => {
        // First of all, refresh the heartbeat timeout
        refreshTimeout();

        // This is never expected... just in case
        if (!(data instanceof Buffer))
          return logError(
            new Error('Not a Buffer'),
            `Unexpected data from WebSocket connection ${NJSON.stringify(data)}`
          );
      });

      // Actually set the timeout for the first time
      refreshTimeout();
      ws.send(stringMessage);
    };
  }

  private async onEpochRollover() {
    const { cardanoNode, db, networkInfo } = this;

    [networkInfo.eraSummaries, networkInfo.lovelaceSupply, networkInfo.protocolParameters] = await Promise.all([
      cardanoNode.eraSummaries(),
      getLovelaceSupply(db, networkInfo.genesisParameters.maxLovelaceSupply),
      getProtocolParameters(db)
    ]);

    this.lastSlot = createSlotEpochInfoCalc(networkInfo.eraSummaries)(networkInfo.ledgerTip.slot).lastSlot.slot;
  }
}
