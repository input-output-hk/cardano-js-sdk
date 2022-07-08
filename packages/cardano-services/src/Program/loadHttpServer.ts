/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import { ChainHistoryHttpService, DbSyncChainHistoryProvider } from '../ChainHistory';
import { CommonProgramOptions, SrvProgramOptions } from '../ProgramsCommon';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../NetworkInfo';
import { DbSyncRewardsProvider, RewardsHttpService } from '../Rewards';
import { DbSyncStakePoolProvider, StakePoolHttpService } from '../StakePool';
import { DbSyncUtxoProvider, UtxoHttpService } from '../Utxo';
import {
  DnsSrvResolve,
  getDnsSrvResolveWithExponentialBackoff,
  getOgmiosTxSubmitProvider,
  getPool,
  getRabbitMqTxSubmitProvider
} from './utils';
import { HttpServer, HttpServerConfig, HttpService } from '../Http';
import { InMemoryCache } from '../InMemoryCache';
import { MissingProgramOption, UnknownServiceName } from './errors';
import { OgmiosCardanoNode, urlToConnectionConfig } from '@cardano-sdk/ogmios';
import { ProgramOptionDescriptions } from './ProgramOptionDescriptions';
import { ServiceNames } from './ServiceNames';
import { TxSubmitHttpService } from '../TxSubmit';
import { createDbSyncMetadataService } from '../Metadata';
import Logger, { createLogger } from 'bunyan';
import pg from 'pg';

export interface HttpServerOptions extends CommonProgramOptions, SrvProgramOptions {
  dbConnectionString?: string;
  serviceDiscoveryBackoffFactor: number;
  serviceDiscoveryBackoffTimeout: number;
  cacheTtl: number;
  epochPollInterval: number;
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
  /*
    TODO: optimize passed options -> 'options' is always passed by default and shouldn't be optional field,
    no need to check it with '.?' everywhere.Will be fixed within ADP-1990
  */
  options?: HttpServerOptions;
}

const serviceMapFactory = (
  args: ProgramArgs,
  logger: Logger,
  cache: InMemoryCache,
  dnsSrvResolve: DnsSrvResolve,
  db?: pg.Pool
) => ({
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
    if (args.options?.ogmiosUrl === undefined)
      throw new MissingProgramOption(ServiceNames.NetworkInfo, ProgramOptionDescriptions.OgmiosUrl);

    const networkInfoProvider = new DbSyncNetworkInfoProvider(
      {
        cardanoNodeConfigPath: args.options.cardanoNodeConfigPath,
        epochPollInterval: args.options?.epochPollInterval
      },
      { cache, cardanoNode: new OgmiosCardanoNode(urlToConnectionConfig(args.options.ogmiosUrl), logger), db, logger }
    );

    return new NetworkInfoHttpService({ logger, networkInfoProvider });
  },
  [ServiceNames.TxSubmit]: async () => {
    const txSubmitProvider = args.options?.useQueue
      ? await getRabbitMqTxSubmitProvider(dnsSrvResolve, args.options)
      : await getOgmiosTxSubmitProvider(dnsSrvResolve, args.options);

    return new TxSubmitHttpService({ logger, txSubmitProvider });
  }
});

export const loadHttpServer = async (args: ProgramArgs): Promise<HttpServer> => {
  const services: HttpService[] = [];
  const logger = createLogger({
    level: args.options?.loggerMinSeverity,
    name: 'http-server'
  });

  const cache = new InMemoryCache(args.options?.cacheTtl);
  const dnsSrvResolve = getDnsSrvResolveWithExponentialBackoff(
    {
      factor: args.options?.serviceDiscoveryBackoffFactor,
      maxRetryTime: args.options?.serviceDiscoveryBackoffTimeout
    },
    cache,
    logger
  );
  const db = await getPool(dnsSrvResolve, args.options);
  const serviceMap = serviceMapFactory(args, logger, cache, dnsSrvResolve, db);

  for (const serviceName of args.serviceNames) {
    if (serviceMap[serviceName]) {
      services.push(await serviceMap[serviceName]());
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
