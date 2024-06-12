/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import {
  AssetHttpService,
  CardanoTokenRegistry,
  DbSyncAssetProvider,
  DbSyncNftMetadataService,
  StubTokenMetadataService
} from '../../Asset';
import { CardanoNode, HandleProvider, Seconds } from '@cardano-sdk/core';
import { ChainHistoryHttpService, DbSyncChainHistoryProvider } from '../../ChainHistory';
import { ConnectionNames, PostgresOptionDescriptions, suffixType2Cli } from '../options/postgres';
import { DbPools, DbSyncEpochPollService } from '../../util';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../NetworkInfo';
import { DbSyncRewardsProvider, RewardsHttpService } from '../../Rewards';
import { DbSyncStakePoolProvider, StakePoolHttpService, createHttpStakePoolMetadataService } from '../../StakePool';
import { DbSyncUtxoProvider, UtxoHttpService } from '../../Utxo';
import { DnsResolver, createDnsResolver, getCardanoNode, getDbPools, getGenesisData } from '../utils';
import { GenesisData } from '../../types';
import { HandleHttpService, TypeOrmHandleProvider } from '../../Handle';
import { HandlePolicyIdsOptionDescriptions, handlePolicyIdsFromFile } from '../options/policyIds';
import { HttpServer, HttpServerConfig, HttpService, getListen } from '../../Http';
import { InMemoryCache, NoCache } from '../../InMemoryCache';
import { Logger } from 'ts-log';
import { MissingProgramOption, MissingServiceDependency, RunnableDependencies, UnknownServiceName } from '../errors';
import { Observable } from 'rxjs';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { Pool } from 'pg';
import { ProviderServerArgs, ProviderServerOptionDescriptions, ServiceNames } from './types';
import { SrvRecord } from 'dns';
import { TxSubmitApiProvider } from '@cardano-sdk/cardano-services-client';
import { TxSubmitHttpService } from '../../TxSubmit';
import { TypeormAssetProvider } from '../../Asset/TypeormAssetProvider';
import { TypeormStakePoolProvider } from '../../StakePool/TypeormStakePoolProvider/TypeormStakePoolProvider';
import { createDbSyncMetadataService } from '../../Metadata';
import { createLogger } from 'bunyan';
import { getConnectionConfig, getOgmiosTxSubmitProvider } from '../services';
import { getEntities } from '../../Projection/prepareTypeormProjection';
import { isNotNil } from '@cardano-sdk/util';
import memoize from 'lodash/memoize.js';

export const ALLOWED_ORIGINS_DEFAULT = false;
export const DISABLE_DB_CACHE_DEFAULT = false;
export const DISABLE_STAKE_POOL_METRIC_APY_DEFAULT = false;
export const PROVIDER_SERVER_API_URL_DEFAULT = new URL('http://localhost:3000');
export const PAGINATION_PAGE_SIZE_LIMIT_DEFAULT = 25;
export const PAGINATION_PAGE_SIZE_LIMIT_ASSETS = 300;
export const USE_BLOCKFROST_DEFAULT = false;
export const USE_TYPEORM_STAKE_POOL_PROVIDER_DEFAULT = false;
export const HANDLE_PROVIDER_SERVER_URL_DEFAULT = '';
export const USE_TYPEORM_ASSET_PROVIDER_DEFAULT = false;

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

const connectionConfigs: { [k in ConnectionNames]?: Observable<PgConnectionConfig> } = {};

let sharedHandleProvider: HandleProvider;

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

  const withTypeOrmProvider =
    <T>(suffix: ConnectionNames, factory: (connectionConfig$: Observable<PgConnectionConfig>) => T) =>
    () => {
      const name = suffixType2Cli(suffix).slice(1);
      const connectionConfig$ =
        connectionConfigs[suffix] ?? (connectionConfigs[suffix] = getConnectionConfig(dnsResolver, name, suffix, args));

      return factory(connectionConfig$);
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

  const getTypeormStakePoolProvider = withTypeOrmProvider('StakePool', (connectionConfig$) => {
    const entities = getEntities(['currentPoolMetrics', 'poolDelisted', 'poolMetadata', 'poolRewards']);

    return new TypeormStakePoolProvider(args, { cache: getDbCache(), connectionConfig$, entities, logger });
  });

  let networkInfoProvider: DbSyncNetworkInfoProvider | undefined;

  const getNetworkInfoProvider = (cardanoNode: CardanoNode, dbPools: DbPools) => {
    if (networkInfoProvider) {
      return networkInfoProvider;
    }

    if (!genesisData)
      throw new MissingProgramOption(ServiceNames.NetworkInfo, ProviderServerOptionDescriptions.CardanoNodeConfigPath);

    networkInfoProvider = new DbSyncNetworkInfoProvider({
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

    return networkInfoProvider;
  };

  const getHandleProvider = async () => {
    if (sharedHandleProvider) return sharedHandleProvider;

    if (!args.handlePolicyIds)
      throw new MissingProgramOption(ServiceNames.Handle, HandlePolicyIdsOptionDescriptions.HandlePolicyIds);

    sharedHandleProvider = await withTypeOrmProvider(
      'Handle',
      async (connectionConfig$) =>
        new TypeOrmHandleProvider({ connectionConfig$, entities: getEntities(['handle', 'handleMetadata']), logger })
    )();

    return sharedHandleProvider;
  };

  const getSubmitApiProvider = () => {
    const { submitApiUrl } = args;

    if (!submitApiUrl)
      throw new MissingProgramOption(ServiceNames.TxSubmit, ProviderServerOptionDescriptions.SubmitApiUrl);

    return new TxSubmitApiProvider({ baseUrl: submitApiUrl }, { logger });
  };

  const getTypeormAssetProvider = withTypeOrmProvider('Asset', (connectionConfig$) => {
    const tokenMetadataService = args.tokenMetadataServerUrl?.startsWith('stub:')
      ? new StubTokenMetadataService()
      : new CardanoTokenRegistry({ logger }, args);

    return new TypeormAssetProvider(
      { paginationPageSizeLimit: Math.min(args.paginationPageSizeLimit! * 10, PAGINATION_PAGE_SIZE_LIMIT_ASSETS) },
      {
        connectionConfig$,
        entities: getEntities(['asset']),
        logger,
        tokenMetadataService
      }
    );
  });

  const getDbSyncAssetProvider = withDbSyncProvider((dbPools, cardanoNode) => {
    const ntfMetadataService = new DbSyncNftMetadataService({
      db: dbPools.main,
      logger,
      metadataService: createDbSyncMetadataService(dbPools.main, logger)
    });

    const tokenMetadataService = args.tokenMetadataServerUrl?.startsWith('stub:')
      ? new StubTokenMetadataService()
      : new CardanoTokenRegistry({ logger }, args);
    return new DbSyncAssetProvider(
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
  }, ServiceNames.Asset);

  return {
    [ServiceNames.Asset]: async () => {
      const assetProvider = args.useTypeormAssetProvider ? getTypeormAssetProvider() : getDbSyncAssetProvider();
      return new AssetHttpService({ assetProvider, logger });
    },
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
    [ServiceNames.Handle]: async () => new HandleHttpService({ handleProvider: await getHandleProvider(), logger }),
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
    [ServiceNames.NetworkInfo]: withDbSyncProvider(
      async (dbPools, cardanoNode) =>
        new NetworkInfoHttpService({
          logger,
          networkInfoProvider: getNetworkInfoProvider(cardanoNode, dbPools)
        }),
      ServiceNames.NetworkInfo
    ),
    [ServiceNames.TxSubmit]: async () => {
      const txSubmitProvider = args.useSubmitApi
        ? getSubmitApiProvider()
        : await getOgmiosTxSubmitProvider(
            dnsResolver,
            logger,
            args,
            args.submitValidateHandles ? await getHandleProvider() : undefined
          );
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

  await handlePolicyIdsFromFile(args);

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
