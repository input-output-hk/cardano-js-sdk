import {
  APY_EPOCHS_BACK_LIMIT_DEFAULT,
  IDS_NAMESPACE,
  StakePoolsSubQuery,
  emptyPoolsExtraInfo,
  getStakePoolSortType,
  queryCacheKey
} from './util';
import {
  Cardano,
  Paginated,
  ProviderError,
  ProviderFailure,
  QueryStakePoolsArgs,
  SortField,
  StakePoolProvider,
  StakePoolStats
} from '@cardano-sdk/core';
import {
  CommonPoolInfo,
  OrderedResult,
  PoolAPY,
  PoolData,
  PoolMetrics,
  PoolSortType,
  PoolUpdate,
  StakePoolResults
} from './types';
import { DbSyncProvider, DbSyncProviderDependencies, Disposer, EpochMonitor } from '../../util';
import { GenesisData } from '../../types';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../InMemoryCache';
import { PromiseOrValue, RunnableModule, resolveObjectValues } from '@cardano-sdk/util';
import { StakePoolBuilder } from './StakePoolBuilder';
import { StakePoolMetadataService } from '../types';
import { toStakePoolResults } from './mappers';
import merge from 'lodash/merge';

/** Properties that are need to create DbSyncStakePoolProvider */
export interface StakePoolProviderProps {
  /** Pagination page size limit used for provider methods constraint. */
  paginationPageSizeLimit: number;

  /** Configure the response optional fields */
  responseConfig?: {
    search?: {
      metrics?: {
        apy?: boolean;
      };
    };
  };

  /** Enables Blockfrost hybrid cache. */
  useBlockfrost: boolean;
}

/** Dependencies that are need to create DbSyncStakePoolProvider */
export interface StakePoolProviderDependencies extends DbSyncProviderDependencies {
  /** The in memory cache engine. */
  cache: DbSyncProviderDependencies['cache'] & {
    db: InMemoryCache;
  };

  /** Monitor the epoch rollover through db polling. */
  epochMonitor: EpochMonitor;

  /** The genesis data loaded from the genesis file. */
  genesisData: GenesisData;

  /** The Stake Pool extended metadata service. */
  metadataService: StakePoolMetadataService;
}

export class DbSyncStakePoolProvider extends DbSyncProvider(RunnableModule) implements StakePoolProvider {
  #builder: StakePoolBuilder;
  #cache: InMemoryCache;
  #epochLength: number;
  #epochMonitor: EpochMonitor;
  #epochRolloverDisposer: Disposer;
  #metadataService: StakePoolMetadataService;
  #paginationPageSizeLimit: number;
  #responseConfig: StakePoolProviderProps['responseConfig'];
  #useBlockfrost: boolean;

  static notSupportedSortFields: SortField[] = ['blocks', 'lastRos', 'liveStake', 'margin', 'pledge', 'ros'];

  constructor(
    { paginationPageSizeLimit, responseConfig, useBlockfrost }: StakePoolProviderProps,
    { cache, dbPools, cardanoNode, genesisData, metadataService, logger, epochMonitor }: StakePoolProviderDependencies
  ) {
    super(
      { cache: { healthCheck: cache.healthCheck }, cardanoNode, dbPools, logger },
      'DbSyncStakePoolProvider',
      logger
    );

    this.#builder = new StakePoolBuilder(dbPools.main, logger);
    this.#cache = cache.db;
    // epochLength can change, so it should come from EraSummaries instead of from CompactGenesis.
    // Then we would need to look up the length of the specific epoch based on slot number.
    // However it would add a lot of complexity to the queries, so for now we use this simple approach.
    this.#epochLength = genesisData.epochLength * 1000;
    this.#epochMonitor = epochMonitor;
    this.#metadataService = metadataService;
    this.#paginationPageSizeLimit = paginationPageSizeLimit;
    this.#responseConfig = merge({
      search: {
        metrics: {
          apy: true
        }
      },
      ...responseConfig
    });
    this.#useBlockfrost = useBlockfrost;
  }

  private getQueryBySortType(
    sortType: PoolSortType,
    queryArgs: { hashesIds: number[]; updatesIds: number[]; totalStake: string | null },
    useBlockfrost: boolean
  ) {
    const { hashesIds, updatesIds, totalStake } = queryArgs;
    // Identify which query to use to order and paginate the result
    // Should be the only one to get the sort options, rest should be ordered by their own defaults
    switch (sortType) {
      // Add more cases as more sort types are supported
      case 'metrics':
        return (options: QueryStakePoolsArgs) =>
          this.#builder.queryPoolMetrics(hashesIds, totalStake, useBlockfrost, options);
      case 'apy':
        // HACK: If the client request sort by APY default to normal sorting.
        if (this.#responseConfig?.search?.metrics?.apy === false) {
          return async (options: QueryStakePoolsArgs) => {
            options.sort = undefined;
            return await this.#builder.queryPoolData(updatesIds, useBlockfrost, options);
          };
        }

        return (options: QueryStakePoolsArgs) => this.#builder.queryPoolAPY(hashesIds, this.#epochLength, options);
      case 'data':
      default:
        return (options: QueryStakePoolsArgs) => this.#builder.queryPoolData(updatesIds, useBlockfrost, options);
    }
  }

  private async attachExtendedMetadata(poolData: PoolData[]): Promise<void> {
    for (const pool of poolData) {
      if (pool.metadata?.extDataUrl || pool.metadata?.extended) {
        try {
          pool.metadata.ext = await this.#metadataService.getStakePoolExtendedMetadata(pool.metadata);
        } catch (error) {
          if (error instanceof ProviderError && error.reason === ProviderFailure.ConnectionFailure) {
            pool.metadata.ext = undefined;
          } else if (error instanceof ProviderError && error.reason === ProviderFailure.NotFound) {
            pool.metadata.ext = null;
          } else {
            throw error;
          }
        }
      }
    }
  }

  private async getPoolsDataOrdered(
    poolUpdates: PoolUpdate[],
    totalStake: string | null,
    useBlockfrost: boolean,
    options: QueryStakePoolsArgs
  ) {
    const hashesIds = poolUpdates.map(({ id }) => id);
    const updatesIds = poolUpdates.map(({ updateId }) => updateId);
    this.logger.debug(`${hashesIds.length} pools found`);
    const sortType = options.sort?.field ? getStakePoolSortType(options.sort.field) : 'data';

    const orderedResult = await this.getQueryBySortType(
      sortType,
      { hashesIds, totalStake, updatesIds },
      useBlockfrost
    )(options);
    const orderedResultHashIds = (orderedResult as CommonPoolInfo[]).map(({ hashId }) => hashId);
    const orderedResultUpdateIds = orderedResultHashIds.map(
      (id) => poolUpdates[poolUpdates.findIndex((item) => item.id === id)].updateId
    );
    let poolDatas: PoolData[] = [];

    if (sortType !== 'data') {
      this.logger.debug('About to query stake pools data');
      poolDatas = await this.#builder.queryPoolData(orderedResultUpdateIds, useBlockfrost);
    } else {
      poolDatas = orderedResult as PoolData[];
    }

    await this.attachExtendedMetadata(poolDatas);
    return { hashesIds, orderedResult, orderedResultHashIds, orderedResultUpdateIds, poolDatas, sortType };
  }

  private cacheStakePools(
    cachedPromises: { [k: string]: PromiseOrValue<Cardano.StakePool | undefined> },
    resultPromise: Promise<StakePoolResults>,
    rewardsHistoryKey: string
  ) {
    for (const [hashId, promise] of Object.entries(cachedPromises)) {
      // If the pool was already cached, there is nothing to do
      if (promise) continue;

      const cacheKey = `${IDS_NAMESPACE}/${rewardsHistoryKey}/${hashId}`;

      // Cache a promise which will resolve with the pool when resultPromise will be resolved
      this.#cache.set(
        cacheKey,
        resultPromise.then(
          ({ poolsToCache }) => {
            // Once the resultPromise is resolved, pick the right pool from it
            const pool = poolsToCache[hashId as unknown as number];

            // Replace the cached promise with the pool
            this.#cache.set(cacheKey, pool, UNLIMITED_CACHE_TTL);

            return pool;
          },
          (error) => {
            // In case of error, reset the cached value to let next request to start a new query
            this.#cache.set(cacheKey, undefined, UNLIMITED_CACHE_TTL);

            throw error;
          }
        ),
        UNLIMITED_CACHE_TTL
      );
    }
  }

  private async queryExtraPoolsData(
    idsToFetch: PoolUpdate[],
    sortType: PoolSortType,
    totalStake: string | null,
    orderedResult: OrderedResult,
    useBlockfrost: boolean
  ) {
    if (idsToFetch.length === 0) return emptyPoolsExtraInfo;
    this.logger.debug('About to query stake pool extra information');
    const orderedResultHashIds = idsToFetch.map(({ id }) => id);
    const orderedResultUpdateIds = idsToFetch.map(({ updateId }) => updateId);
    const [poolRelays, poolOwners, poolRegistrations, poolRetirements, poolMetrics] = await Promise.all([
      // TODO: it would be easier and make the code cleaner if all queries had the same id as argument
      //       (either hash or update id)
      this.#builder.queryPoolRelays(orderedResultUpdateIds),
      useBlockfrost ? [] : this.#builder.queryPoolOwners(orderedResultUpdateIds),
      useBlockfrost ? [] : this.#builder.queryRegistrations(orderedResultHashIds),
      useBlockfrost ? [] : this.#builder.queryRetirements(orderedResultHashIds),
      sortType === 'metrics'
        ? (orderedResult as PoolMetrics[])
        : this.#builder.queryPoolMetrics(orderedResultHashIds, totalStake, useBlockfrost)
    ]);
    return { poolMetrics, poolOwners, poolRegistrations, poolRelays, poolRetirements };
  }

  public queryStakePoolsChecks(options: QueryStakePoolsArgs) {
    const { filters, pagination, sort } = options;

    if (pagination.limit > this.#paginationPageSizeLimit) {
      throw new ProviderError(
        ProviderFailure.BadRequest,
        undefined,
        `Page size of ${pagination.limit} can not be greater than ${this.#paginationPageSizeLimit}`
      );
    }

    if (filters?.text) {
      throw new ProviderError(
        ProviderFailure.NotImplemented,
        undefined,
        'DbSyncStakePoolProvider does not support text filter'
      );
    }

    if (filters?.identifier && filters.identifier.values.length > this.#paginationPageSizeLimit) {
      throw new ProviderError(
        ProviderFailure.BadRequest,
        undefined,
        `Filter identifiers of ${filters.identifier.values.length} can not be greater than ${
          this.#paginationPageSizeLimit
        }`
      );
    }

    if (DbSyncStakePoolProvider.notSupportedSortFields.includes(sort?.field || 'name')) {
      throw new ProviderError(
        ProviderFailure.NotImplemented,
        undefined,
        `DbSyncStakePoolProvider doesn't support sort by ${sort?.field} `
      );
    }
  }

  public async queryStakePools(options: QueryStakePoolsArgs): Promise<Paginated<Cardano.StakePool>> {
    const { filters, apyEpochsBackLimit = APY_EPOCHS_BACK_LIMIT_DEFAULT } = options;
    const useBlockfrost = this.#useBlockfrost;

    this.queryStakePoolsChecks(options);

    const { params, query } = useBlockfrost
      ? this.#builder.buildBlockfrostQuery(filters)
      : filters?._condition === 'or'
      ? this.#builder.buildOrQuery(filters)
      : this.#builder.buildAndQuery(filters);
    // Get pool updates/hashes cached
    const poolUpdates = await this.#cache.get(queryCacheKey(StakePoolsSubQuery.POOL_HASHES, options), () =>
      this.#builder.queryPoolHashes(query, params)
    );
    // Get cached total staked amount used to compute the saturation
    // When Blockfrost cache is enabled the saturation is one of the cached values: the query can be skipped
    const totalStake = this.#useBlockfrost
      ? null
      : await this.#cache.get(queryCacheKey(StakePoolsSubQuery.TOTAL_STAKE), async () => {
          const distribution = await this.cardanoNode.stakeDistribution();

          for (const [_, value] of distribution) return value.stake.supply.toString();

          throw new ProviderError(
            ProviderFailure.InvalidResponse,
            undefined,
            'Got an empty distribution response from OgmiosCardanoNode'
          );
        });
    // Get total stake pools count
    const totalCount = poolUpdates.length;
    // Get last epoch data
    const lastEpoch = await this.#builder.getLastEpochWithData();
    const { no: lastEpochNo } = lastEpoch;
    // Get stake pools data cached
    const { orderedResultHashIds, orderedResultUpdateIds, orderedResult, poolDatas, hashesIds, sortType } =
      await this.#cache.get(queryCacheKey(StakePoolsSubQuery.POOLS_DATA_ORDERED, options), () =>
        this.getPoolsDataOrdered(poolUpdates, totalStake, useBlockfrost, options)
      );
    // Get stake pools APYs cached
    let poolAPYs = [] as PoolAPY[];
    if (this.#responseConfig?.search?.metrics?.apy === true) {
      poolAPYs =
        sortType === 'apy'
          ? (orderedResult as PoolAPY[])
          : await this.#cache.get(queryCacheKey(StakePoolsSubQuery.APY, hashesIds, options), () =>
              this.#builder.queryPoolAPY(hashesIds, this.#epochLength, { apyEpochsBackLimit })
            );
    }
    // Create lookup table with pool ids: (hashId:updateId)
    const hashIdsMap = Object.fromEntries(
      orderedResultHashIds.map((hashId, idx) => [hashId, orderedResultUpdateIds[idx]])
    );
    // Create a lookup table with cached pools: (hashId:Cardano.StakePool)
    const rewardsHistoryKey = JSON.stringify(apyEpochsBackLimit);
    const cachedPromises = Object.fromEntries(
      orderedResultHashIds.map((hashId) => [
        hashId,
        this.#cache.getVal<PromiseOrValue<Cardano.StakePool | undefined>>(
          `${IDS_NAMESPACE}/${rewardsHistoryKey}/${hashId}`
        )
      ])
    );

    const queryExtraPoolsDataMissingFromCacheAndMap = async () => {
      const fromCache = await resolveObjectValues(cachedPromises);
      // Compute ids to fetch from db
      const idsToFetch = Object.entries(fromCache)
        .filter(([_, pool]) => pool === undefined)
        .map(([hashId, _]) => ({ id: Number(hashId), updateId: hashIdsMap[hashId] }));
      // Get stake pools extra information
      const { poolRelays, poolOwners, poolRegistrations, poolRetirements, poolMetrics } =
        await this.queryExtraPoolsData(idsToFetch, sortType, totalStake, orderedResult, useBlockfrost);

      return toStakePoolResults(orderedResultHashIds, fromCache, useBlockfrost, {
        lastEpochNo: Cardano.EpochNo(lastEpochNo),
        poolAPYs,
        poolDatas,
        poolMetrics,
        poolOwners,
        poolRegistrations,
        poolRelays,
        poolRetirements,
        totalCount
      });
    };

    const resultPromise = queryExtraPoolsDataMissingFromCacheAndMap();

    this.cacheStakePools(cachedPromises, resultPromise, rewardsHistoryKey);

    const { results } = await resultPromise;

    return results;
  }

  public async stakePoolStats(): Promise<StakePoolStats> {
    this.logger.debug('About to query pool stats');
    return await this.#cache.get(queryCacheKey(StakePoolsSubQuery.STATS), () => this.#builder.queryPoolStats());
  }

  async initializeImpl() {
    return Promise.resolve();
  }

  async startImpl() {
    this.#epochRolloverDisposer = this.#epochMonitor.onEpochRollover(() => this.#cache.clear());
  }

  async shutdownImpl() {
    this.#cache.shutdown();
    this.#epochRolloverDisposer();
  }
}
