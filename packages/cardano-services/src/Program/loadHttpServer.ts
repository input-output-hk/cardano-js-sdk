/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import {
  AssetHttpService,
  CardanoTokenRegistry,
  DbSyncAssetProvider,
  DbSyncNftMetadataService,
  StubTokenMetadataService
} from '../Asset';
import { BuildInfo, HttpServer, HttpServerConfig, HttpService } from '../Http';
import { CardanoNode } from '@cardano-sdk/core';
import { ChainHistoryHttpService, DbSyncChainHistoryProvider } from '../ChainHistory';
import { CommonProgramOptions, ProgramOptionDescriptions } from './Options';
import { DbSyncEpochPollService, loadGenesisData } from '../util';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../NetworkInfo';
import { DbSyncRewardsProvider, RewardsHttpService } from '../Rewards';
import { DbSyncStakePoolProvider, StakePoolHttpService, createHttpStakePoolExtMetadataService } from '../StakePool';
import { DbSyncUtxoProvider, UtxoHttpService } from '../Utxo';
import { DnsResolver, createDnsResolver, shouldInitCardanoNode } from './utils';
import { GenesisData } from '../types';
import { InMemoryCache } from '../InMemoryCache';
import { Logger } from 'ts-log';
import { MissingProgramOption, MissingServiceDependency, RunnableDependencies, UnknownServiceName } from './errors';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { ServiceNames } from './ServiceNames';
import { SrvRecord } from 'dns';
import { TxSubmitHttpService } from '../TxSubmit';
import { createDbSyncMetadataService } from '../Metadata';
import { createLogger } from 'bunyan';
import { getOgmiosCardanoNode, getOgmiosTxSubmitProvider, getPool, getRabbitMqTxSubmitProvider } from './services';
import { isNotNil } from '@cardano-sdk/util';
import memoize from 'lodash/memoize';
import pg from 'pg';

export interface HttpServerOptions extends CommonProgramOptions {
  serviceNames?: ServiceNames[];
  enableMetrics?: boolean;
  buildInfo?: BuildInfo;
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
  paginationPageSizeLimit?: number;
}
export interface LoadHttpServerDependencies {
  dnsResolver?: (serviceName: string) => Promise<SrvRecord>;
  logger?: Logger;
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

interface ServiceMapFactoryOptions {
  args: ProgramArgs;
  dbConnection?: pg.Pool;
  dnsResolver: DnsResolver;
  genesisData?: GenesisData;
  logger: Logger;
  node?: OgmiosCardanoNode;
}

const serviceMapFactory = (options: ServiceMapFactoryOptions) => {
  const { args, dbConnection, dnsResolver, genesisData, logger, node } = options;
  const withDbSyncProvider =
    <T>(factory: (db: pg.Pool, cardanoNode: CardanoNode) => T, serviceName: ServiceNames) =>
    () => {
      if (!dbConnection)
        throw new MissingProgramOption(serviceName, [
          ProgramOptionDescriptions.PostgresConnectionString,
          ProgramOptionDescriptions.PostgresServiceDiscoveryArgs
        ]);

      if (!node) throw new MissingServiceDependency(serviceName, RunnableDependencies.CardanoNode);

      return factory(dbConnection, node);
    };

  const getEpochMonitor = memoize((dbPool) => new DbSyncEpochPollService(dbPool, args.options!.epochPollInterval!));

  return {
    [ServiceNames.Asset]: withDbSyncProvider(async (db, cardanoNode) => {
      const ntfMetadataService = new DbSyncNftMetadataService({
        db,
        logger,
        metadataService: createDbSyncMetadataService(db, logger)
      });
      const tokenMetadataService = args.options?.tokenMetadataServerUrl?.startsWith('stub:')
        ? new StubTokenMetadataService()
        : new CardanoTokenRegistry({ logger }, args.options);
      const assetProvider = new DbSyncAssetProvider({
        cardanoNode,
        db,
        logger,
        ntfMetadataService,
        tokenMetadataService
      });

      return new AssetHttpService({ assetProvider, logger });
    }, ServiceNames.Asset),
    [ServiceNames.StakePool]: withDbSyncProvider(async (db, cardanoNode) => {
      if (!genesisData)
        throw new MissingProgramOption(ServiceNames.StakePool, ProgramOptionDescriptions.CardanoNodeConfigPath);
      const stakePoolProvider = new DbSyncStakePoolProvider(
        { paginationPageSizeLimit: args.options!.paginationPageSizeLimit! },
        {
          cache: new InMemoryCache(args.options!.dbCacheTtl!),
          cardanoNode,
          db,
          epochMonitor: getEpochMonitor(db),
          genesisData,
          logger,
          metadataService: createHttpStakePoolExtMetadataService(logger)
        }
      );
      return new StakePoolHttpService({ logger, stakePoolProvider });
    }, ServiceNames.StakePool),
    [ServiceNames.Utxo]: withDbSyncProvider(
      async (db, cardanoNode) =>
        new UtxoHttpService({ logger, utxoProvider: new DbSyncUtxoProvider({ cardanoNode, db, logger }) }),
      ServiceNames.Utxo
    ),
    [ServiceNames.ChainHistory]: withDbSyncProvider(async (db, cardanoNode) => {
      const metadataService = createDbSyncMetadataService(db, logger);
      const chainHistoryProvider = new DbSyncChainHistoryProvider(
        { paginationPageSizeLimit: args.options!.paginationPageSizeLimit! },
        { cardanoNode, db, logger, metadataService }
      );
      return new ChainHistoryHttpService({ chainHistoryProvider, logger });
    }, ServiceNames.ChainHistory),
    [ServiceNames.Rewards]: withDbSyncProvider(async (db, cardanoNode) => {
      const rewardsProvider = new DbSyncRewardsProvider(
        { paginationPageSizeLimit: args.options!.paginationPageSizeLimit! },
        { cardanoNode, db, logger }
      );
      return new RewardsHttpService({ logger, rewardsProvider });
    }, ServiceNames.Rewards),
    [ServiceNames.NetworkInfo]: withDbSyncProvider(async (db, cardanoNode) => {
      if (!genesisData)
        throw new MissingProgramOption(ServiceNames.NetworkInfo, ProgramOptionDescriptions.CardanoNodeConfigPath);
      const networkInfoProvider = new DbSyncNetworkInfoProvider({
        cache: new InMemoryCache(args.options!.dbCacheTtl!),
        cardanoNode,
        db,
        epochMonitor: getEpochMonitor(db),
        genesisData,
        logger
      });
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

export const loadHttpServer = async (args: ProgramArgs, deps: LoadHttpServerDependencies = {}): Promise<HttpServer> => {
  const { apiUrl, options, serviceNames } = args;
  const services: HttpService[] = [];
  const logger =
    deps?.logger ||
    createLogger({
      level: options?.loggerMinSeverity,
      name: 'http-server'
    });
  const dnsResolver =
    deps?.dnsResolver ||
    createDnsResolver(
      {
        factor: options?.serviceDiscoveryBackoffFactor,
        maxRetryTime: options?.serviceDiscoveryTimeout
      },
      logger
    );
  const db = await getPool(dnsResolver, logger, options);
  const cardanoNode = shouldInitCardanoNode(serviceNames)
    ? await getOgmiosCardanoNode(dnsResolver, logger, options)
    : undefined;
  const genesisData = options?.cardanoNodeConfigPath
    ? await loadGenesisData(options?.cardanoNodeConfigPath)
    : undefined;
  const serviceMap = serviceMapFactory({ args, dbConnection: db, dnsResolver, genesisData, logger, node: cardanoNode });

  for (const serviceName of serviceNames) {
    if (serviceMap[serviceName]) {
      services.push(await serviceMap[serviceName]());
    } else {
      throw new UnknownServiceName(serviceName);
    }
  }
  const config: HttpServerConfig = {
    listen: {
      host: apiUrl.hostname,
      port: Number.parseInt(apiUrl.port)
    },
    meta: { ...options?.buildInfo, startupTime: Date.now() }
  };
  if (options?.enableMetrics) {
    config.metrics = { enabled: options?.enableMetrics };
  }
  return new HttpServer(config, { logger, runnableDependencies: [cardanoNode].filter(isNotNil), services });
};
