import { CardanoWsServer } from '../../WsServer';
import {
  CommonOptionsDescriptions,
  CommonProgramOptions,
  OgmiosProgramOptions,
  PosgresProgramOptions
} from '../options';
import { InMemoryCache, NoCache } from '../../InMemoryCache';
import { MissingProgramOption } from '../errors';
import { OgmiosCardanoNode, urlToConnectionConfig } from '@cardano-sdk/ogmios';
import { createDnsResolver } from '../utils';
import { createLogger } from 'bunyan';
import { getPool } from '../services/postgres';
import { loadGenesisData } from '../../util';
import { toGenesisParams } from '../../NetworkInfo/DbSyncNetworkInfoProvider/mappers';

export type WsServerArgs = CommonProgramOptions & PosgresProgramOptions<'DbSync'> & OgmiosProgramOptions;

export const loadWsServer = (args: WsServerArgs) => {
  const { apiUrl, dbCacheTtl, disableDbCache, heartbeatTimeout, loggerMinSeverity, ogmiosUrl } = args;
  const { cardanoNodeConfigPath, serviceDiscoveryBackoffFactor: factor, serviceDiscoveryTimeout: maxRetryTime } = args;

  const logger = createLogger({ level: loggerMinSeverity, name: 'ws-server' });

  logger.info('Loading WebSocket server...');

  if (!cardanoNodeConfigPath)
    throw new MissingProgramOption('WebSocketServer', CommonOptionsDescriptions.CardanoNodeConfigPath);

  (async () => {
    const cache = disableDbCache ? new NoCache() : new InMemoryCache(dbCacheTtl);
    const cardanoNode = new OgmiosCardanoNode(urlToConnectionConfig(ogmiosUrl), logger);
    const dnsResolver = createDnsResolver({ factor, maxRetryTime }, logger);
    const db = await getPool(dnsResolver, logger, args);
    const genesisData = await loadGenesisData(cardanoNodeConfigPath);
    const genesis = toGenesisParams(genesisData);
    const port = Number.parseInt(apiUrl.port, 10);

    if (!db) throw new Error('Unable to get DB Pool');

    await cardanoNode.initialize();
    await cardanoNode.start();

    const server = new CardanoWsServer({ cache, cardanoNode, db, genesis, logger }, { heartbeatTimeout, port });

    let shuttingDown = false;
    const shutDown = (signal: string) => {
      if (shuttingDown) return;
      shuttingDown = true;

      logger.info(`Shutting down Cardano SDK WebSocket Server due to ${signal} ...`);

      server.close(() => {
        Promise.all([db.end(), cardanoNode.shutdown()])
          .then(() => logger.info('Cardano SDK WebSocket Server shutdown'))
          .catch((error) => logger.error(error, 'Error while shutting down WebSocket Server'));
      });
    };

    for (const signal of ['SIGABRT', 'SIGINT', 'SIGQUIT', 'SIGTERM'] as const) process.on(signal, shutDown);
  })().catch((error) => logger.error(error, 'While loading the WebSocket server'));
};
