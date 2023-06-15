/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import { AssetHttpService } from '../../Asset/AssetHttpService';
import { CardanoNode, Seconds } from '@cardano-sdk/core';
import { CardanoTokenRegistry } from '../../Asset/CardanoTokenRegistry';
import { ChainHistoryHttpService, DbSyncChainHistoryProvider } from '../../ChainHistory';
import { DbPools, DbSyncEpochPollService } from '../../util';
import { DbSyncAssetProvider } from '../../Asset/DbSyncAssetProvider';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../NetworkInfo';
import { DbSyncNftMetadataService, StubTokenMetadataService } from '../../Asset';
import { DbSyncRewardsProvider, RewardsHttpService } from '../../Rewards';
import { DbSyncStakePoolProvider, StakePoolHttpService, createHttpStakePoolMetadataService } from '../../StakePool';
import { DbSyncUtxoProvider, UtxoHttpService } from '../../Utxo';
import { DnsResolver, createDnsResolver, getCardanoNode, getDbPools, getGenesisData } from '../utils';
import { GenesisData } from '../../types';
import { HttpServer, HttpServerConfig, HttpService, getListen } from '../../Http';
import { InMemoryCache, NoCache } from '../../InMemoryCache';
import { Logger } from 'ts-log';
import { MissingProgramOption, MissingServiceDependency, RunnableDependencies, UnknownServiceName } from '../errors';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { PostgresOptionDescriptions } from '../options/postgres';
import { ProviderServerArgs, ProviderServerOptionDescriptions, ServiceNames } from './types';
import { SrvRecord } from 'dns';
import { TxSubmitHttpService } from '../../TxSubmit';
import { TypeormStakePoolProvider } from '../../StakePool/TypeormStakePoolProvider/TypeormStakePoolProvider';
import { URL } from 'url';
import { createDbSyncMetadataService } from '../../Metadata';
import { createLogger } from 'bunyan';
import { getConnectionConfig, getOgmiosTxSubmitProvider, getRabbitMqTxSubmitProvider } from '../services';
import { getEntities } from '../../Projection/prepareTypeormProjection';
import { isNotNil } from '@cardano-sdk/util';
import memoize from 'lodash/memoize';

export const ALLOWED_ORIGINS_DEFAULT = false;
export const DISABLE_DB_CACHE_DEFAULT = false;
export const DISABLE_STAKE_POOL_METRIC_APY_DEFAULT = false;
export const PROVIDER_SERVER_API_URL_DEFAULT = new URL('http://localhost:3000');
export const PAGINATION_PAGE_SIZE_LIMIT_DEFAULT = 25;
export const PAGINATION_PAGE_SIZE_LIMIT_ASSETS = 300;
export const USE_BLOCKFROST_DEFAULT = false;
export const USE_TYPEORM_STAKE_POOL_PROVIDER_DEFAULT = false;
export const USE_QUEUE_DEFAULT = false;

export interface LoadProviderServerDependencies {
  dnsResolver?: (serviceName: string) => Promise<SrvRecord>;
  logger?: Logger;
}

interface ServiceMapFactoryOptions {
  args: ProviderServerArgs;
  pools: Partial<DbPools>;
  dnsResolver: DnsResolver;
  genesisData?: GenesisData;
  logger: Logger;
  node?: OgmiosCardanoNode;
}

const serverName = 'provider-server';

const serviceMapFactory = (options: ServiceMapFactoryOptions) => {
  const { args, pools, dnsResolver, genesisData, logger, node } = options;
  const withDbSyncProvider =
    <T>(factory: (dbPools: DbPools, cardanoNode: CardanoNode) => T, serviceName: ServiceNames) =>
    () => {
      if (!pools.main || !pools.healthCheck)
        throw new MissingProgramOption(serviceName, [
          PostgresOptionDescriptions.ConnectionString,
          PostgresOptionDescriptions.ServiceDiscoveryArgs
        ]);

      if (!node) throw new MissingServiceDependency(serviceName, RunnableDependencies.CardanoNode);

      return factory(pools as DbPools, node);
    };

  const getCache = (ttl: Seconds | 0) => (args.disableDbCache ? new NoCache() : new InMemoryCache(ttl));
  const getDbCache = () => getCache(args.dbCacheTtl);

  // Shared cache across all providers
  const healthCheckCache = getCache(args.healthCheckCacheTtl);

  const getEpochMonitor = memoize((dbPool: Pool) => new DbSyncEpochPollService(dbPool, args.epochPollInterval!));

  const getDbSyncStakePoolProvider = withDbSyncProvider((dbPools, cardanoNode) => {
    if (!genesisData) {
      throw new MissingProgramOption(ServiceNames.StakePool, ProviderServerOptionDescriptions.CardanoNodeConfigPath);
    }

    return new DbSyncStakePoolProvider(
      {
        paginationPageSizeLimit: args.paginationPageSizeLimit!,
        responseConfig: { search: { metrics: { apy: !args.disableStakePoolMetricApy } } },
        useBlockfrost: args.useBlockfrost!
      },
      {
        cache: {
          db: getDbCache(),
          healthCheck: healthCheckCache
        },
        cardanoNode,
        dbPools,
        epochMonitor: getEpochMonitor(dbPools.main),
        genesisData,
        logger,
        metadataService: createHttpStakePoolMetadataService(logger)
      }
    );
  }, ServiceNames.StakePool);

  const getTypeormStakePoolProvider = () => {
    const entities = getEntities([
      'block',
      'currentPoolMetrics',
      'poolMetadata',
      'poolRegistration',
      'poolRetirement',
      'stakePool'
    ]);
    const connectionConfig$ = getConnectionConfig(dnsResolver, serverName, 'StakePool', args);
    return new TypeormStakePoolProvider(
      { paginationPageSizeLimit: args.paginationPageSizeLimit! },
      { connectionConfig$, entities, logger }
    );
  };

  return {
    [ServiceNames.Asset]: withDbSyncProvider(async (dbPools, cardanoNode) => {
      const ntfMetadataService = new DbSyncNftMetadataService({
        db: dbPools.main,
        logger,
        metadataService: createDbSyncMetadataService(dbPools.main, logger)
      });
      const tokenMetadataService = args.tokenMetadataServerUrl?.startsWith('stub:')
        ? new StubTokenMetadataService()
        : new CardanoTokenRegistry({ logger }, args);
      const assetProvider = new DbSyncAssetProvider(
        {
          cacheTTL: args.assetCacheTTL,
          disableDbCache: args.disableDbCache,
          paginationPageSizeLimit: Math.min(args.paginationPageSizeLimit! * 10, PAGINATION_PAGE_SIZE_LIMIT_ASSETS)
        },
        {
          cache: {
            healthCheck: healthCheckCache
          },
          cardanoNode,
          dbPools,
          logger,
          ntfMetadataService,
          tokenMetadataService
        }
      );

      return new AssetHttpService({ assetProvider, logger });
    }, ServiceNames.Asset),
    [ServiceNames.StakePool]: async () => {
      const stakePoolProvider = args.useTypeormStakePoolProvider
        ? getTypeormStakePoolProvider()
        : getDbSyncStakePoolProvider();
      return new StakePoolHttpService({ logger, stakePoolProvider });
    },
    [ServiceNames.Utxo]: withDbSyncProvider(
      async (dbPools, cardanoNode) =>
        new UtxoHttpService({
          logger,
          utxoProvider: new DbSyncUtxoProvider({
            cache: {
              healthCheck: healthCheckCache
            },
            cardanoNode,
            dbPools,
            logger
          })
        }),
      ServiceNames.Utxo
    ),
    [ServiceNames.ChainHistory]: withDbSyncProvider(async (dbPools, cardanoNode) => {
      const metadataService = createDbSyncMetadataService(dbPools.main, logger);
      const chainHistoryProvider = new DbSyncChainHistoryProvider(
        { paginationPageSizeLimit: args.paginationPageSizeLimit! },
        {
          cache: {
            healthCheck: healthCheckCache
          },
          cardanoNode,
          dbPools,
          logger,
          metadataService
        }
      );
      return new ChainHistoryHttpService({ chainHistoryProvider, logger });
    }, ServiceNames.ChainHistory),
    [ServiceNames.Rewards]: withDbSyncProvider(async (dbPools, cardanoNode) => {
      const rewardsProvider = new DbSyncRewardsProvider(
        { paginationPageSizeLimit: args.paginationPageSizeLimit! },
        {
          cache: {
            healthCheck: healthCheckCache
          },
          cardanoNode,
          dbPools,
          logger
        }
      );
      return new RewardsHttpService({ logger, rewardsProvider });
    }, ServiceNames.Rewards),
    [ServiceNames.NetworkInfo]: withDbSyncProvider(async (dbPools, cardanoNode) => {
      if (!genesisData)
        throw new MissingProgramOption(
          ServiceNames.NetworkInfo,
          ProviderServerOptionDescriptions.CardanoNodeConfigPath
        );
      const networkInfoProvider = new DbSyncNetworkInfoProvider({
        cache: {
          db: getDbCache(),
          healthCheck: healthCheckCache
        },
        cardanoNode,
        dbPools,
        epochMonitor: getEpochMonitor(dbPools.main),
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
      name: serverName
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

  const cardanoNode = await getCardanoNode(dnsResolver, logger, args);
  const genesisData = await getGenesisData(args);
  const pools: Partial<DbPools> = await getDbPools(dnsResolver, logger, args);
  const serviceMap = serviceMapFactory({ args, dnsResolver, genesisData, logger, node: cardanoNode, pools });

  for (const serviceName of args.serviceNames) {
    if (serviceMap[serviceName]) {
      services.push(await serviceMap[serviceName]());
    } else {
      throw new UnknownServiceName(serviceName, Object.values(ServiceNames));
    }
  }
  const config: HttpServerConfig = {
    allowedOrigins: args.allowedOrigins,
    listen: getListen(args.apiUrl),
    meta: { ...args.buildInfo, startupTime: Date.now() }
  };
  if (args.enableMetrics) {
    config.metrics = { enabled: args.enableMetrics };
  }
  return new HttpServer(config, { logger, runnableDependencies: [cardanoNode].filter(isNotNil), services });
};
