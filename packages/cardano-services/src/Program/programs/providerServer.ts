/* eslint-disable unicorn/consistent-function-scoping */
// cSpell:ignore impls

/* eslint-disable complexity */
import {
  AssetProvider,
  CardanoNode,
  ChainHistoryProvider,
  HandleProvider,
  NetworkInfoProvider,
  Provider,
  RewardsProvider,
  Seconds,
  StakePoolProvider,
  UtxoProvider
} from '@cardano-sdk/core';
import {
  BlockfrostAssetProvider,
  BlockfrostChainHistoryProvider,
  BlockfrostNetworkInfoProvider,
  BlockfrostRewardsProvider,
  BlockfrostTxSubmitProvider,
  BlockfrostUtxoProvider,
  CardanoWsClient,
  TxSubmitApiProvider
} from '@cardano-sdk/cardano-services-client';
import { Logger } from 'ts-log';
import { Observable } from 'rxjs';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { Pool } from 'pg';
import { SrvRecord } from 'dns';
import { createLogger } from 'bunyan';
import { isNotNil } from '@cardano-sdk/util';
import memoize from 'lodash/memoize.js';
/* eslint-disable sonarjs/cognitive-complexity */
import {
  AssetHttpService,
  CardanoTokenRegistry,
  DbSyncAssetProvider,
  DbSyncNftMetadataService,
  StubTokenMetadataService,
  TypeormAssetProvider
} from '../../Asset';
import { ChainHistoryHttpService, DbSyncChainHistoryProvider } from '../../ChainHistory';
import {
  CommonOptionsDescriptions,
  ConnectionNames,
  HandlePolicyIdsOptionDescriptions,
  PostgresOptionDescriptions,
  ProviderImplementation,
  handlePolicyIdsFromFile,
  suffixType2Cli
} from '../options';
import { DbPools, DbSyncEpochPollService, TypeormProvider, getBlockfrostClient } from '../../util';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../NetworkInfo';
import { DbSyncRewardsProvider, RewardsHttpService } from '../../Rewards';
import {
  DbSyncStakePoolProvider,
  StakePoolHttpService,
  TypeormStakePoolProvider,
  createHttpStakePoolMetadataService
} from '../../StakePool';
import { DbSyncUtxoProvider, UtxoHttpService } from '../../Utxo';
import { DnsResolver, createDnsResolver, getCardanoNode, getDbPools, getGenesisData } from '../utils';
import { GenesisData } from '../../types';
import { HandleHttpService, TypeOrmHandleProvider } from '../../Handle';
import { HttpServer, HttpServerConfig, HttpService, getListen } from '../../Http';
import { InMemoryCache, NoCache } from '../../InMemoryCache';
import { MissingProgramOption, MissingServiceDependency, RunnableDependencies, UnknownServiceName } from '../errors';
import { NodeTxSubmitProvider, TxSubmitHttpService } from '../../TxSubmit';
import { ProviderServerArgs, ProviderServerOptionDescriptions, ServiceNames } from './types';
import { WarmCache } from '../../InMemoryCache/WarmCache';
import { createDbSyncMetadataService } from '../../Metadata';
import { getConnectionConfig, getOgmiosObservableCardanoNode } from '../services';
import { getEntities } from '../../Projection';

export const ALLOWED_ORIGINS_DEFAULT = false;
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

const selectProviderImplementation = <T extends Provider>(
  impl: ProviderImplementation,
  impls: {
    typeorm?: () => T & TypeormProvider;
    dbsync?: () => T & Provider;
    blockfrost?: () => T;
  },
  logger: Logger,
  service?: ServiceNames
) => {
  const selected =
    impl === ProviderImplementation.TYPEORM
      ? impls.typeorm!()
      : impl === ProviderImplementation.DBSYNC
      ? impls.dbsync!()
      : (impls.blockfrost!() as T);

  logger.info(`Selected ${typeof selected} for ${service} provider based on value ${impl}`);

  return selected;
};

const createProviderCache = () => {
  const cache = new Map();
  return {
    async get(key: string) {
      return cache.get(key);
    },
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    async set(key: string, val: any) {
      cache.set(key, val);
    }
  };
};

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
  const getWarmCache = (ttl: Seconds) => (args.disableDbCache ? new NoCache() : new WarmCache(ttl, Seconds(ttl / 10)));

  const getDbCache = () => getCache(args.dbCacheTtl);

  // Shared cache across all providers
  const healthCheckCache = getWarmCache(args.healthCheckCacheTtl);

  const getEpochMonitor = memoize((dbPool: Pool) => new DbSyncEpochPollService(dbPool, args.epochPollInterval!));

  const getDbSyncChainHistoryProvider = withDbSyncProvider((dbPools, cardanoNode) => {
    const cache = { healthCheck: healthCheckCache };
    const metadataService = createDbSyncMetadataService(dbPools.main, logger);

    return new DbSyncChainHistoryProvider(
      { paginationPageSizeLimit: args.paginationPageSizeLimit! },
      { cache, cardanoNode, dbPools, logger, metadataService }
    );
  }, ServiceNames.ChainHistory);

  const getWebSocketClient = () => {
    const url = args.webSocketApiUrl;

    if (!url) throw new MissingProgramOption('WebSocket', CommonOptionsDescriptions.WebSocketApiUrl);

    const chainHistoryProvider = getDbSyncChainHistoryProvider();

    return new CardanoWsClient({ chainHistoryProvider, logger }, { url });
  };

  const getDbSyncStakePoolProvider = withDbSyncProvider((dbPools, cardanoNode) => {
    if (!genesisData)
      throw new MissingProgramOption(ServiceNames.StakePool, CommonOptionsDescriptions.CardanoNodeConfigPath);

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

    return new TypeormStakePoolProvider(args, {
      cache: getDbCache(),
      connectionConfig$,
      entities,
      healthCheckCache,
      logger
    });
  });

  const getHandleProvider = async () => {
    if (sharedHandleProvider) return sharedHandleProvider;

    if (!args.handlePolicyIds)
      throw new MissingProgramOption(ServiceNames.Handle, HandlePolicyIdsOptionDescriptions.HandlePolicyIds);

    sharedHandleProvider = await withTypeOrmProvider(
      'Handle',
      async (connectionConfig$) =>
        new TypeOrmHandleProvider({
          connectionConfig$,
          entities: getEntities(['handle', 'handleMetadata']),
          healthCheckCache,
          logger
        })
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
        healthCheckCache,
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

  const getBlockfrostAssetProvider = () => new BlockfrostAssetProvider(getBlockfrostClient(), logger);

  const getBlockfrostUtxoProvider = () =>
    new BlockfrostUtxoProvider({
      cache: createProviderCache(),
      client: getBlockfrostClient(),
      logger
    });

  const getDbSyncUtxoProvider = withDbSyncProvider(
    (dbPools, cardanoNode) =>
      new DbSyncUtxoProvider({
        cache: {
          healthCheck: healthCheckCache
        },
        cardanoNode,
        dbPools,
        logger
      }),
    ServiceNames.Utxo
  );

  const getBlockfrostNetworkInfoProvider = () => new BlockfrostNetworkInfoProvider(getBlockfrostClient(), logger);

  const getDbSyncNetworkInfoProvider = withDbSyncProvider((dbPools, cardanoNode) => {
    if (args.useWebSocketApi) return getWebSocketClient().networkInfoProvider;

    if (!genesisData)
      throw new MissingProgramOption(ServiceNames.NetworkInfo, CommonOptionsDescriptions.CardanoNodeConfigPath);

    return new DbSyncNetworkInfoProvider({
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
  }, ServiceNames.NetworkInfo);

  let networkInfoProvider: NetworkInfoProvider;
  const getNetworkInfoProvider = () => {
    if (!networkInfoProvider)
      networkInfoProvider =
        args.networkInfoProvider === ProviderImplementation.BLOCKFROST
          ? getBlockfrostNetworkInfoProvider()
          : getDbSyncNetworkInfoProvider();
    return networkInfoProvider;
  };
  const getBlockfrostChainHistoryProvider = (nInfoProvider: NetworkInfoProvider | DbSyncNetworkInfoProvider) =>
    new BlockfrostChainHistoryProvider({
      cache: createProviderCache(),
      client: getBlockfrostClient(),
      logger,
      networkInfoProvider: nInfoProvider
    });

  const getBlockfrostRewardsProvider = () => new BlockfrostRewardsProvider(getBlockfrostClient(), logger);

  const getDbSyncRewardsProvider = withDbSyncProvider(
    (dbPools, cardanoNode) =>
      new DbSyncRewardsProvider(
        { paginationPageSizeLimit: args.paginationPageSizeLimit! },
        {
          cache: {
            healthCheck: healthCheckCache
          },
          cardanoNode,
          dbPools,
          logger
        }
      ),
    ServiceNames.Rewards
  );
  const getBlockfrostTxSubmitProvider = () => new BlockfrostTxSubmitProvider(getBlockfrostClient(), logger);

  return {
    [ServiceNames.Asset]: async () =>
      new AssetHttpService({
        assetProvider: selectProviderImplementation<AssetProvider>(
          args.useTypeormAssetProvider
            ? ProviderImplementation.TYPEORM
            : args.assetProvider ?? ProviderImplementation.DBSYNC,
          { blockfrost: getBlockfrostAssetProvider, dbsync: getDbSyncAssetProvider, typeorm: getTypeormAssetProvider },
          logger,
          ServiceNames.Asset
        ),
        logger
      }),
    [ServiceNames.StakePool]: async () =>
      new StakePoolHttpService({
        logger,
        stakePoolProvider: selectProviderImplementation<StakePoolProvider>(
          args.useTypeormStakePoolProvider
            ? ProviderImplementation.TYPEORM
            : args.stakePoolProvider ?? ProviderImplementation.DBSYNC,
          { dbsync: getDbSyncStakePoolProvider, typeorm: getTypeormStakePoolProvider },
          logger,
          ServiceNames.StakePool
        )
      }),
    [ServiceNames.Utxo]: async () =>
      new UtxoHttpService({
        logger,
        utxoProvider: selectProviderImplementation<UtxoProvider>(
          args.utxoProvider ?? ProviderImplementation.DBSYNC,
          {
            blockfrost: getBlockfrostUtxoProvider,
            dbsync: getDbSyncUtxoProvider
          },
          logger,
          ServiceNames.Utxo
        )
      }),
    [ServiceNames.ChainHistory]: async () =>
      new ChainHistoryHttpService({
        chainHistoryProvider: selectProviderImplementation<ChainHistoryProvider>(
          args.chainHistoryProvider ?? ProviderImplementation.DBSYNC,
          {
            blockfrost: () => getBlockfrostChainHistoryProvider(getNetworkInfoProvider()),
            dbsync: getDbSyncChainHistoryProvider
          },
          logger,
          ServiceNames.ChainHistory
        ),
        logger
      }),
    [ServiceNames.Handle]: async () => new HandleHttpService({ handleProvider: await getHandleProvider(), logger }),
    [ServiceNames.Rewards]: async () =>
      new RewardsHttpService({
        logger,
        rewardsProvider: selectProviderImplementation<RewardsProvider>(
          args.rewardsProvider ?? ProviderImplementation.DBSYNC,
          { blockfrost: getBlockfrostRewardsProvider, dbsync: getDbSyncRewardsProvider },
          logger,
          ServiceNames.Rewards
        )
      }),
    [ServiceNames.NetworkInfo]: async () =>
      new NetworkInfoHttpService({
        logger,
        networkInfoProvider: getNetworkInfoProvider()
      }),
    [ServiceNames.TxSubmit]: async () => {
      const txSubmitProvider = args.useSubmitApi
        ? getSubmitApiProvider()
        : args.txSubmitProvider === ProviderImplementation.BLOCKFROST
        ? getBlockfrostTxSubmitProvider()
        : args.txSubmitProvider === ProviderImplementation.SUBMIT_API
        ? getSubmitApiProvider()
        : new NodeTxSubmitProvider({
            cardanoNode: getOgmiosObservableCardanoNode(dnsResolver, logger, args),
            handleProvider: args.submitValidateHandles ? await getHandleProvider() : undefined,
            healthCheckCache,
            logger
          });
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
