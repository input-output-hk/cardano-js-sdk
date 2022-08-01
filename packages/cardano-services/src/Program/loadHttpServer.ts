/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import { AssetHttpService, CardanoTokenRegistry, DbSyncAssetProvider, DbSyncNftMetadataService } from '../Asset';
import { ChainHistoryHttpService, DbSyncChainHistoryProvider } from '../ChainHistory';
import { CommonProgramOptions } from '../ProgramsCommon';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../NetworkInfo';
import { DbSyncRewardsProvider, RewardsHttpService } from '../Rewards';
import { DbSyncStakePoolProvider, StakePoolHttpService } from '../StakePool';
import { DbSyncUtxoProvider, UtxoHttpService } from '../Utxo';
import { DnsResolver, createDnsResolver } from './utils';
import { HttpServer, HttpServerConfig, HttpService } from '../Http';
import { InMemoryCache } from '../InMemoryCache';
import { MissingProgramOption, UnknownServiceName } from './errors';
import { ProgramOptionDescriptions } from './ProgramOptionDescriptions';
import { ServiceNames } from './ServiceNames';
import { TxSubmitHttpService } from '../TxSubmit';
import { createDbSyncMetadataService } from '../Metadata';
import { getOgmiosCardanoNode, getOgmiosTxSubmitProvider, getPool, getRabbitMqTxSubmitProvider } from './services';
import Logger, { createLogger } from 'bunyan';
import pg from 'pg';

export interface HttpServerOptions extends CommonProgramOptions {
  postgresConnectionString?: string;
  epochPollInterval: number;
  cardanoNodeConfigPath?: string;
  tokenMetadataCacheTTL?: number;
  tokenMetadataServerUrl?: string;
  enableMetrics?: boolean;
  useQueue?: boolean;
  postgresSrvServiceName?: string;
  postgresDb?: string;
  postgresUser?: string;
  postgresPassword?: string;
  postgresSslCaFile?: string;
  dbCacheTtl: number;
}

export interface ProgramArgs {
  apiUrl: URL;
  serviceNames: (
    | ServiceNames.Asset
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
  dbConnection?: pg.Pool
) => {
  const withDb =
    <T>(factory: (db: pg.Pool) => T) =>
    () => {
      if (!dbConnection)
        throw new MissingProgramOption(ServiceNames.StakePool, [
          ProgramOptionDescriptions.PostgresConnectionString,
          ProgramOptionDescriptions.PostgresServiceDiscoveryArgs
        ]);

      return factory(dbConnection);
    };

  return {
    [ServiceNames.Asset]: withDb((db) => {
      const ntfMetadataService = new DbSyncNftMetadataService({
        db,
        logger,
        metadataService: createDbSyncMetadataService(db, logger)
      });
      const tokenMetadataService = new CardanoTokenRegistry({ logger }, args.options);
      const assetProvider = new DbSyncAssetProvider({ db, logger, ntfMetadataService, tokenMetadataService });

      return new AssetHttpService({ assetProvider, logger });
    }),
    [ServiceNames.StakePool]: withDb(
      (db) => new StakePoolHttpService({ logger, stakePoolProvider: new DbSyncStakePoolProvider(db, logger) })
    ),
    [ServiceNames.Utxo]: withDb(
      (db) => new UtxoHttpService({ logger, utxoProvider: new DbSyncUtxoProvider(db, logger) })
    ),
    [ServiceNames.ChainHistory]: withDb(
      (db) =>
        new ChainHistoryHttpService({
          chainHistoryProvider: new DbSyncChainHistoryProvider(db, createDbSyncMetadataService(db, logger), logger),
          logger
        })
    ),
    [ServiceNames.Rewards]: withDb(
      (db) => new RewardsHttpService({ logger, rewardsProvider: new DbSyncRewardsProvider(db, logger) })
    ),
    [ServiceNames.NetworkInfo]: withDb(async (db) => {
      if (args.options?.cardanoNodeConfigPath === undefined)
        throw new MissingProgramOption(ServiceNames.NetworkInfo, ProgramOptionDescriptions.CardanoNodeConfigPath);
      if (args.options?.ogmiosUrl === undefined)
        throw new MissingProgramOption(ServiceNames.NetworkInfo, ProgramOptionDescriptions.OgmiosUrl);

      const cardanoNode = await getOgmiosCardanoNode(dnsResolver, logger, args.options);
      const networkInfoProvider = new DbSyncNetworkInfoProvider(
        {
          cardanoNodeConfigPath: args.options.cardanoNodeConfigPath,
          epochPollInterval: args.options?.epochPollInterval
        },
        { cache, cardanoNode, db, logger }
      );

      return new NetworkInfoHttpService({ logger, networkInfoProvider });
    }),
    [ServiceNames.TxSubmit]: async () => {
      const txSubmitProvider = args.options?.useQueue
        ? await getRabbitMqTxSubmitProvider(dnsResolver, logger, args.options)
        : await getOgmiosTxSubmitProvider(dnsResolver, logger, args.options);

      return new TxSubmitHttpService({ logger, txSubmitProvider });
    }
  };
};

export const loadHttpServer = async (args: ProgramArgs): Promise<HttpServer> => {
  const services: HttpService[] = [];
  const logger = createLogger({
    level: args.options?.loggerMinSeverity,
    name: 'http-server'
  });

  const cache = new InMemoryCache(args.options!.dbCacheTtl!);
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
  if (args.options?.enableMetrics) {
    config.metrics = { enabled: args.options?.enableMetrics };
  }
  return new HttpServer(config, { logger, services });
};
