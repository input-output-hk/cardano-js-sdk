/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import { ChainHistoryHttpService, DbSyncChainHistoryProvider } from '../ChainHistory';
import { CommonProgramOptions } from '../ProgramsCommon';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../NetworkInfo';
import { DbSyncRewardsProvider, RewardsHttpService } from '../Rewards';
import { DbSyncStakePoolProvider, StakePoolHttpService } from '../StakePool';
import { DbSyncUtxoProvider, UtxoHttpService } from '../Utxo';
import {
  DnsResolver,
  createDnsResolver,
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

export interface HttpServerOptions extends CommonProgramOptions {
  dbConnectionString?: string;
  epochPollInterval: number;
  cardanoNodeConfigPath?: string;
  metricsEnabled?: boolean;
  useQueue?: boolean;
  postgresSrvServiceName?: string;
  postgresDb?: string;
  postgresUser?: string;
  postgresPassword?: string;
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
  dnsResolver: DnsResolver,
  db?: pg.Pool
) => ({
  [ServiceNames.StakePool]: () => {
    if (!db)
      throw new MissingProgramOption(ServiceNames.StakePool, [
        ProgramOptionDescriptions.DbConnection,
        ProgramOptionDescriptions.PostgresSrvArgs
      ]);

    return new StakePoolHttpService({ logger, stakePoolProvider: new DbSyncStakePoolProvider(db, logger) });
  },
  [ServiceNames.Utxo]: () => {
    if (!db)
      throw new MissingProgramOption(ServiceNames.Utxo, [
        ProgramOptionDescriptions.DbConnection,
        ProgramOptionDescriptions.PostgresSrvArgs
      ]);

    return new UtxoHttpService({ logger, utxoProvider: new DbSyncUtxoProvider(db, logger) });
  },
  [ServiceNames.ChainHistory]: () => {
    if (!db)
      throw new MissingProgramOption(ServiceNames.ChainHistory, [
        ProgramOptionDescriptions.DbConnection,
        ProgramOptionDescriptions.PostgresSrvArgs
      ]);

    const metadataService = createDbSyncMetadataService(db, logger);
    return new ChainHistoryHttpService({
      chainHistoryProvider: new DbSyncChainHistoryProvider(db, metadataService, logger),
      logger
    });
  },
  [ServiceNames.Rewards]: () => {
    if (!db)
      throw new MissingProgramOption(ServiceNames.Rewards, [
        ProgramOptionDescriptions.DbConnection,
        ProgramOptionDescriptions.PostgresSrvArgs
      ]);

    return new RewardsHttpService({ logger, rewardsProvider: new DbSyncRewardsProvider(db, logger) });
  },
  [ServiceNames.NetworkInfo]: () => {
    if (!db)
      throw new MissingProgramOption(ServiceNames.NetworkInfo, [
        ProgramOptionDescriptions.DbConnection,
        ProgramOptionDescriptions.PostgresSrvArgs
      ]);
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
      ? await getRabbitMqTxSubmitProvider(dnsResolver, logger, args.options)
      : await getOgmiosTxSubmitProvider(dnsResolver, logger, args.options);

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
  const dnsResolver = createDnsResolver(
    {
      factor: args.options?.serviceDiscoveryBackoffFactor,
      maxRetryTime: args.options?.serviceDiscoveryTimeout
    },
    logger
  );
  const db = await getPool(dnsResolver, logger, args.options);
  const serviceMap = serviceMapFactory(args, logger, cache, dnsResolver, db);

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
