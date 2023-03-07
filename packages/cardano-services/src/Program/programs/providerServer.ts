/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import {
  AssetHttpService,
  CardanoTokenRegistry,
  DbSyncAssetProvider,
  DbSyncNftMetadataService,
  StubTokenMetadataService
} from '../../Asset';
import { CardanoNode } from '@cardano-sdk/core';
import { ChainHistoryHttpService, DbSyncChainHistoryProvider } from '../../ChainHistory';
import {
  CommonProgramOptions,
  OgmiosProgramOptions,
  PosgresProgramOptions,
  PostgresOptionDescriptions,
  RabbitMqProgramOptions
} from '../options';
import { DbSyncEpochPollService, loadGenesisData } from '../../util';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../NetworkInfo';
import { DbSyncRewardsProvider, RewardsHttpService } from '../../Rewards';
import { DbSyncStakePoolProvider, StakePoolHttpService, createHttpStakePoolExtMetadataService } from '../../StakePool';
import { DbSyncUtxoProvider, UtxoHttpService } from '../../Utxo';
import { DnsResolver, createDnsResolver, serviceSetHas } from '../utils';
import { GenesisData } from '../../types';
import { HttpServer, HttpServerConfig, HttpService, getListen } from '../../Http';
import { InMemoryCache } from '../../InMemoryCache';
import { Logger } from 'ts-log';
import { MissingProgramOption, MissingServiceDependency, RunnableDependencies, UnknownServiceName } from '../errors';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { SrvRecord } from 'dns';
import { TxSubmitHttpService } from '../../TxSubmit';
import { URL } from 'url';
import { createDbSyncMetadataService } from '../../Metadata';
import { createLogger } from 'bunyan';
import { getOgmiosCardanoNode, getOgmiosTxSubmitProvider, getPool, getRabbitMqTxSubmitProvider } from '../services';
import { isNotNil } from '@cardano-sdk/util';
import memoize from 'lodash/memoize';
import pg from 'pg';

export const HTTP_SERVER_API_URL_DEFAULT = new URL('http://localhost:3000');
export const PAGINATION_PAGE_SIZE_LIMIT_DEFAULT = 25;
export const USE_QUEUE_DEFAULT = false;

/**
 * Used as mount segments, so must be URL-friendly
 *
 */
export enum ServiceNames {
  Asset = 'asset',
  StakePool = 'stake-pool',
  NetworkInfo = 'network-info',
  TxSubmit = 'tx-submit',
  Utxo = 'utxo',
  ChainHistory = 'chain-history',
  Rewards = 'rewards'
}

export const cardanoNodeDependantServices = new Set([
  ServiceNames.NetworkInfo,
  ServiceNames.StakePool,
  ServiceNames.Utxo,
  ServiceNames.Rewards,
  ServiceNames.Asset,
  ServiceNames.ChainHistory
]);

export enum ProviderServerOptionDescriptions {
  CardanoNodeConfigPath = 'Cardano node config path',
  DbCacheTtl = 'Cache TTL in seconds between 60 and 172800 (two days), an option for database related operations',
  EpochPollInterval = 'Epoch poll interval',
  TokenMetadataCacheTtl = 'Token Metadata API cache TTL in minutes',
  TokenMetadataServerUrl = 'Token Metadata API server URL',
  UseQueue = 'Enables RabbitMQ',
  PaginationPageSizeLimit = 'Pagination page size limit shared across all providers'
}

export type ProviderServerArgs = CommonProgramOptions &
  PosgresProgramOptions &
  OgmiosProgramOptions &
  RabbitMqProgramOptions & {
    cardanoNodeConfigPath?: string;
    tokenMetadataCacheTTL?: number;
    tokenMetadataServerUrl?: string;
    epochPollInterval: number;
    dbCacheTtl: number;
    useQueue?: boolean;
    paginationPageSizeLimit?: number;
    serviceNames: ServiceNames[];
  };
export interface LoadProviderServerDependencies {
  dnsResolver?: (serviceName: string) => Promise<SrvRecord>;
  logger?: Logger;
}

interface ServiceMapFactoryOptions {
  args: ProviderServerArgs;
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
          PostgresOptionDescriptions.ConnectionString,
          PostgresOptionDescriptions.ServiceDiscoveryArgs
        ]);

      if (!node) throw new MissingServiceDependency(serviceName, RunnableDependencies.CardanoNode);

      return factory(dbConnection, node);
    };

  const getEpochMonitor = memoize((dbPool) => new DbSyncEpochPollService(dbPool, args.epochPollInterval!));

  return {
    [ServiceNames.Asset]: withDbSyncProvider(async (db, cardanoNode) => {
      const ntfMetadataService = new DbSyncNftMetadataService({
        db,
        logger,
        metadataService: createDbSyncMetadataService(db, logger)
      });
      const tokenMetadataService = args.tokenMetadataServerUrl?.startsWith('stub:')
        ? new StubTokenMetadataService()
        : new CardanoTokenRegistry({ logger }, args);
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
        throw new MissingProgramOption(ServiceNames.StakePool, ProviderServerOptionDescriptions.CardanoNodeConfigPath);
      const stakePoolProvider = new DbSyncStakePoolProvider(
        { paginationPageSizeLimit: args.paginationPageSizeLimit! },
        {
          cache: new InMemoryCache(args.dbCacheTtl!),
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
        { paginationPageSizeLimit: args.paginationPageSizeLimit! },
        { cardanoNode, db, logger, metadataService }
      );
      return new ChainHistoryHttpService({ chainHistoryProvider, logger });
    }, ServiceNames.ChainHistory),
    [ServiceNames.Rewards]: withDbSyncProvider(async (db, cardanoNode) => {
      const rewardsProvider = new DbSyncRewardsProvider(
        { paginationPageSizeLimit: args.paginationPageSizeLimit! },
        { cardanoNode, db, logger }
      );
      return new RewardsHttpService({ logger, rewardsProvider });
    }, ServiceNames.Rewards),
    [ServiceNames.NetworkInfo]: withDbSyncProvider(async (db, cardanoNode) => {
      if (!genesisData)
        throw new MissingProgramOption(
          ServiceNames.NetworkInfo,
          ProviderServerOptionDescriptions.CardanoNodeConfigPath
        );
      const networkInfoProvider = new DbSyncNetworkInfoProvider({
        cache: new InMemoryCache(args.dbCacheTtl!),
        cardanoNode,
        db,
        epochMonitor: getEpochMonitor(db),
        genesisData,
        logger
      });
      return new NetworkInfoHttpService({ logger, networkInfoProvider });
    }, ServiceNames.NetworkInfo),
    [ServiceNames.TxSubmit]: async () => {
      const txSubmitProvider = args.useQueue
        ? await getRabbitMqTxSubmitProvider(dnsResolver, logger, args)
        : await getOgmiosTxSubmitProvider(dnsResolver, logger, args);
      return new TxSubmitHttpService({ logger, txSubmitProvider });
    }
  };
};

export const loadProviderServer = async (
  args: ProviderServerArgs,
  deps: LoadProviderServerDependencies = {}
): Promise<HttpServer> => {
  const services: HttpService[] = [];
  const logger =
    deps?.logger ||
    createLogger({
      level: args.loggerMinSeverity,
      name: 'provider-server'
    });
  const dnsResolver =
    deps?.dnsResolver ||
    createDnsResolver(
      {
        factor: args.serviceDiscoveryBackoffFactor,
        maxRetryTime: args.serviceDiscoveryTimeout
      },
      logger
    );
  const db = await getPool(dnsResolver, logger, args);
  const cardanoNode = serviceSetHas(args.serviceNames, cardanoNodeDependantServices)
    ? await getOgmiosCardanoNode(dnsResolver, logger, args)
    : undefined;
  const genesisData = args.cardanoNodeConfigPath ? await loadGenesisData(args.cardanoNodeConfigPath) : undefined;
  const serviceMap = serviceMapFactory({ args, dbConnection: db, dnsResolver, genesisData, logger, node: cardanoNode });

  for (const serviceName of args.serviceNames) {
    if (serviceMap[serviceName]) {
      services.push(await serviceMap[serviceName]());
    } else {
      throw new UnknownServiceName(serviceName, Object.values(ServiceNames));
    }
  }
  const config: HttpServerConfig = {
    listen: getListen(args.apiUrl),
    meta: { ...args.buildInfo, startupTime: Date.now() }
  };
  if (args.enableMetrics) {
    config.metrics = { enabled: args.enableMetrics };
  }
  return new HttpServer(config, { logger, runnableDependencies: [cardanoNode].filter(isNotNil), services });
};
