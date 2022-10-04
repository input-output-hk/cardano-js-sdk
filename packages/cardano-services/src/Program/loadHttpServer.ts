/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import { AssetHttpService, CardanoTokenRegistry, DbSyncAssetProvider, DbSyncNftMetadataService } from '../Asset';
import { ChainHistoryHttpService, DbSyncChainHistoryProvider } from '../ChainHistory';
import { CommonProgramOptions, ProgramOptionDescriptions } from './Options';
import { DbSyncEpochPollService } from '../util';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../NetworkInfo';
import { DbSyncRewardsProvider, RewardsHttpService } from '../Rewards';
import { DbSyncStakePoolProvider, StakePoolHttpService } from '../StakePool';
import { DbSyncUtxoProvider, UtxoHttpService } from '../Utxo';
import { DnsResolver, createDnsResolver } from './utils';
import { HttpServer, HttpServerConfig, HttpService } from '../Http';
import { InMemoryCache } from '../InMemoryCache';
import { MissingProgramOption, UnknownServiceName } from './errors';
import { ServiceNames } from './ServiceNames';
import { TxSubmitHttpService } from '../TxSubmit';
import { createDbSyncMetadataService } from '../Metadata';
import { getOgmiosCardanoNode, getOgmiosTxSubmitProvider, getPool, getRabbitMqTxSubmitProvider } from './services';
import Logger, { createLogger } from 'bunyan';
import memoize from 'lodash/memoize';
import pg from 'pg';

export interface HttpServerOptions extends CommonProgramOptions {
  serviceNames?: ServiceNames[];
  enableMetrics?: boolean;
  cardanoNodeConfigPath?: string;
  tokenMetadataCacheTTL?: number;
  tokenMetadataServerUrl?: string;
  postgresConnectionString?: string;
  postgresSrvServiceName?: string;
  postgresDb?: string;
  postgresDbFile?: string;
  postgresUser?: string;
  postgresUserFile?: string;
  postgresPassword?: string;
  postgresPasswordFile?: string;
  postgresHost?: string;
  postgresPort?: string;
  postgresSslCaFile?: string;
  epochPollInterval: number;
  dbCacheTtl: number;
  useQueue?: boolean;
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

const serviceMapFactory = (args: ProgramArgs, logger: Logger, dnsResolver: DnsResolver, dbConnection?: pg.Pool) => {
  const withDb =
    <T>(factory: (db: pg.Pool) => T, serviceName: ServiceNames) =>
    () => {
      if (!dbConnection)
        throw new MissingProgramOption(serviceName, [
          ProgramOptionDescriptions.PostgresConnectionString,
          ProgramOptionDescriptions.PostgresServiceDiscoveryArgs
        ]);

      return factory(dbConnection);
    };

  const getEpochMonitor = memoize((dbPool) => new DbSyncEpochPollService(dbPool, args.options!.epochPollInterval!));

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
    }, ServiceNames.Asset),
    [ServiceNames.StakePool]: withDb(async (db) => {
      const cardanoNode = await getOgmiosCardanoNode(dnsResolver, logger, args.options);
      const stakePoolProvider = new DbSyncStakePoolProvider({
        cache: new InMemoryCache(args.options!.dbCacheTtl!),
        cardanoNode,
        db,
        epochMonitor: getEpochMonitor(db),
        logger
      });
      return new StakePoolHttpService({ logger, stakePoolProvider });
    }, ServiceNames.StakePool),
    [ServiceNames.Utxo]: withDb(
      (db) => new UtxoHttpService({ logger, utxoProvider: new DbSyncUtxoProvider(db, logger) }),
      ServiceNames.Utxo
    ),
    [ServiceNames.ChainHistory]: withDb(
      (db) =>
        new ChainHistoryHttpService({
          chainHistoryProvider: new DbSyncChainHistoryProvider(db, createDbSyncMetadataService(db, logger), logger),
          logger
        }),
      ServiceNames.ChainHistory
    ),
    [ServiceNames.Rewards]: withDb(
      (db) => new RewardsHttpService({ logger, rewardsProvider: new DbSyncRewardsProvider(db, logger) }),
      ServiceNames.Rewards
    ),
    [ServiceNames.NetworkInfo]: withDb(async (db) => {
      if (args.options?.cardanoNodeConfigPath === undefined)
        throw new MissingProgramOption(ServiceNames.NetworkInfo, ProgramOptionDescriptions.CardanoNodeConfigPath);
      const cardanoNode = await getOgmiosCardanoNode(dnsResolver, logger, args.options);
      const networkInfoProvider = new DbSyncNetworkInfoProvider(
        { cardanoNodeConfigPath: args.options.cardanoNodeConfigPath },
        {
          cache: new InMemoryCache(args.options!.dbCacheTtl!),
          cardanoNode,
          db,
          epochMonitor: getEpochMonitor(db),
          logger
        }
      );

      return new NetworkInfoHttpService({ logger, networkInfoProvider });
    }, ServiceNames.NetworkInfo),
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

  const dnsResolver = createDnsResolver(
    {
      factor: args.options?.serviceDiscoveryBackoffFactor,
      maxRetryTime: args.options?.serviceDiscoveryTimeout
    },
    logger
  );
  const db = await getPool(dnsResolver, logger, args.options);
  const serviceMap = serviceMapFactory(args, logger, dnsResolver, db);

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
