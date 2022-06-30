/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import { ChainHistoryHttpService, DbSyncChainHistoryProvider } from '../ChainHistory';
import { CommonProgramOptions, SrvProgramOptions } from '../ProgramsCommon';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../NetworkInfo';
import { DbSyncRewardsProvider, RewardsHttpService } from '../Rewards';
import { DbSyncStakePoolProvider, StakePoolHttpService } from '../StakePool';
import { DbSyncUtxoProvider, UtxoHttpService } from '../Utxo';
import { HttpServer, HttpServerConfig, HttpService } from '../Http';
import { InMemoryCache } from '../InMemoryCache';
import { MissingProgramOption, UnknownServiceName } from './errors';
import { ProgramOptionDescriptions } from './ProgramOptionDescriptions';
import { RabbitMqTxSubmitProvider } from '@cardano-sdk/rabbitmq';
import { ServiceNames } from './ServiceNames';
import { TxSubmitHttpService } from '../TxSubmit';
import { createDbSyncMetadataService } from '../Metadata';
import { getPool } from './utils';
import { ogmiosTxSubmitProvider, urlToConnectionConfig } from '@cardano-sdk/ogmios';
import Logger, { createLogger } from 'bunyan';
import pg from 'pg';

export interface HttpServerOptions extends CommonProgramOptions, SrvProgramOptions {
  dbConnectionString?: string;
  dbQueriesCacheTtl: number;
  dbPollInterval: number;
  serviceDiscoveryBackoffFactor: number;
  serviceDiscoveryTimeout: number;
  cardanoNodeConfigPath?: string;
  metricsEnabled?: boolean;
  useQueue?: boolean;
}

export interface ProgramArgs {
  apiUrl: URL;
  serviceNames: (
    | ServiceNames.StakePool
    | ServiceNames.TxSubmit
    | ServiceNames.ChainHistory
    | ServiceNames.Utxo
    | ServiceNames.NetworkInfo
    | ServiceNames.Rewards
  )[];
  options?: HttpServerOptions;
}

const serviceMapFactory = (args: ProgramArgs, logger: Logger, cache: InMemoryCache, db?: pg.Pool) => ({
  [ServiceNames.StakePool]: () => {
    if (!db) throw new MissingProgramOption(ServiceNames.StakePool, ProgramOptionDescriptions.DbConnection);

    return new StakePoolHttpService({ logger, stakePoolProvider: new DbSyncStakePoolProvider(db, logger) });
  },
  [ServiceNames.Utxo]: () => {
    if (!db) throw new MissingProgramOption(ServiceNames.Utxo, ProgramOptionDescriptions.DbConnection);

    return new UtxoHttpService({ logger, utxoProvider: new DbSyncUtxoProvider(db, logger) });
  },
  [ServiceNames.ChainHistory]: () => {
    if (!db) throw new MissingProgramOption(ServiceNames.ChainHistory, ProgramOptionDescriptions.DbConnection);

    const metadataService = createDbSyncMetadataService(db, logger);
    return new ChainHistoryHttpService({
      chainHistoryProvider: new DbSyncChainHistoryProvider(db, metadataService, logger),
      logger
    });
  },
  [ServiceNames.Rewards]: () => {
    if (!db) throw new MissingProgramOption(ServiceNames.Rewards, ProgramOptionDescriptions.DbConnection);

    return new RewardsHttpService({ logger, rewardsProvider: new DbSyncRewardsProvider(db, logger) });
  },
  [ServiceNames.NetworkInfo]: () => {
    if (!db) throw new MissingProgramOption(ServiceNames.NetworkInfo, ProgramOptionDescriptions.DbConnection);
    if (args.options?.cardanoNodeConfigPath === undefined)
      throw new MissingProgramOption(ServiceNames.NetworkInfo, ProgramOptionDescriptions.CardanoNodeConfigPath);

    const networkInfoProvider = new DbSyncNetworkInfoProvider(
      {
        cardanoNodeConfigPath: args.options?.cardanoNodeConfigPath,
        dbPollInterval: args.options?.dbPollInterval
      },
      { cache, db, logger }
    );

    return new NetworkInfoHttpService({ logger, networkInfoProvider });
  },
  [ServiceNames.TxSubmit]: () => {
    const txSubmitProvider =
      args.options?.useQueue && args.options?.rabbitmqUrl
        ? new RabbitMqTxSubmitProvider({ rabbitmqUrl: args.options.rabbitmqUrl })
        : ogmiosTxSubmitProvider(urlToConnectionConfig(args.options?.ogmiosUrl));

    return new TxSubmitHttpService({ logger, txSubmitProvider });
  }
});

export const loadHttpServer = async (args: ProgramArgs): Promise<HttpServer> => {
  const services: HttpService[] = [];
  const logger = createLogger({
    level: args.options?.loggerMinSeverity,
    name: 'http-server'
  });

  const db = await getPool(logger, args.options);

  const cache = new InMemoryCache(args.options?.dbQueriesCacheTtl);

  const serviceMap = serviceMapFactory(args, logger, cache, db);

  for (const serviceName of args.serviceNames) {
    if (serviceMap[serviceName]) {
      services.push(serviceMap[serviceName]());
    } else {
      throw new UnknownServiceName(serviceName);
    }
  }

  const config: HttpServerConfig = {
    listen: {
      host: args.apiUrl.hostname,
      port: Number.parseInt(args.apiUrl.port)
    }
  };
  if (args.options?.metricsEnabled) {
    config.metrics = { enabled: args.options?.metricsEnabled };
  }
  return new HttpServer(config, { logger, services });
};
