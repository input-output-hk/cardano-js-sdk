import { CommonPoolInfo, PoolAPY, PoolData, PoolMetrics, PoolSortType } from './types';
import { DbSyncProvider } from '../../DbSyncProvider';
import { Logger, dummyLogger } from 'ts-log';
import { Pool } from 'pg';
import { StakePoolBuilder } from './StakePoolBuilder';
import { StakePoolProvider, StakePoolQueryOptions, StakePoolSearchResults, StakePoolStats } from '@cardano-sdk/core';
import { getStakePoolSortType } from './util';
import { isNotNil } from '@cardano-sdk/util';
import { toCoreStakePool } from './mappers';

export class DbSyncStakePoolProvider extends DbSyncProvider implements StakePoolProvider {
  #builder: StakePoolBuilder;
  #logger: Logger;

  constructor(db: Pool, logger = dummyLogger) {
    super(db);
    this.#builder = new StakePoolBuilder(db, logger);
    this.#logger = logger;
  }

  private getQueryBySortType(
    sortType: PoolSortType,
    queryArgs: { hashesIds: number[]; updatesIds: number[]; totalAdaAmount: string }
  ) {
    const { hashesIds, updatesIds, totalAdaAmount } = queryArgs;
    // Identify which query to use to order and paginate the result
    // Should be the only one to get the sort options, rest should be ordered by their own defaults
    switch (sortType) {
      // Add more cases as more sort types are supported
      case 'metrics':
        return (options?: StakePoolQueryOptions) => this.#builder.queryPoolMetrics(hashesIds, totalAdaAmount, options);
      case 'apy':
        return (options?: StakePoolQueryOptions) => this.#builder.queryPoolAPY(hashesIds, options);
      case 'data':
      default:
        return (options?: StakePoolQueryOptions) => this.#builder.queryPoolData(updatesIds, options);
    }
  }

  public async queryStakePools(options?: StakePoolQueryOptions): Promise<StakePoolSearchResults> {
    const { params, query } =
      options?.filters?._condition === 'or'
        ? this.#builder.buildOrQuery(options?.filters)
        : this.#builder.buildAndQuery(options?.filters);
    this.#logger.debug('About to query pool hashes');
    const poolUpdates = await this.#builder.queryPoolHashes(query, params);
    const hashesIds = poolUpdates.map(({ id }) => id);
    const updatesIds = poolUpdates.map(({ updateId }) => updateId);
    this.#logger.debug(`${hashesIds.length} pools found`);
    const totalAdaAmount = await this.#builder.getTotalAmountOfAda();

    this.#logger.debug('About to query stake pools by sort options');
    const sortType = options?.sort?.field ? getStakePoolSortType(options.sort.field) : 'data';
    const orderedResult = await this.getQueryBySortType(sortType, { hashesIds, totalAdaAmount, updatesIds })(options);
    const orderedResultHashIds = (orderedResult as CommonPoolInfo[]).map(({ hashId }) => hashId);
    const orderedResultUpdateIds = poolUpdates
      .filter(({ id }) => orderedResultHashIds.includes(id))
      .map(({ updateId }) => updateId);

    let poolDatas: PoolData[] = [];
    if (sortType !== 'data') {
      // If queryPoolData is not the one used to sort there could be more stake pools that should be fetched
      // but might not appear in the orderByQuery result
      this.#logger.debug('About to query stake pools data');
      poolDatas = await this.#builder.queryPoolData(orderedResultUpdateIds);

      // If not reached, try to fill the pagination limit using pool data default order
      if (options?.pagination?.limit && orderedResult.length < options.pagination.limit) {
        const restOfPoolUpdateIds = updatesIds.filter((updateId) => !orderedResultUpdateIds.includes(updateId));
        this.#logger.debug('About to query rest of stake pools data');
        const restOfPoolData = await this.#builder.queryPoolData(restOfPoolUpdateIds, {
          pagination: { limit: options.pagination.limit - orderedResult.length, startAt: 0 }
        });
        poolDatas.push(...restOfPoolData);
        orderedResultUpdateIds.push(...restOfPoolData.map(({ updateId }) => updateId));
        orderedResultHashIds.push(...restOfPoolData.map(({ hashId }) => hashId));
      }
    } else {
      poolDatas = orderedResult as PoolData[];
    }

    this.#logger.debug('About to query stake pool extra information');
    const [
      poolRelays,
      poolOwners,
      poolRegistrations,
      poolRetirements,
      poolRewards,
      poolMetrics,
      poolAPYs,
      totalCount,
      lastEpoch
    ] = await Promise.all([
      // TODO: it would be easier and make the code cleaner if all queries had the same id as argument
      //       (either hash or update id)
      this.#builder.queryPoolRelays(orderedResultUpdateIds),
      this.#builder.queryPoolOwners(orderedResultUpdateIds),
      this.#builder.queryRegistrations(orderedResultHashIds),
      this.#builder.queryRetirements(orderedResultHashIds),
      this.#builder.queryPoolRewards(orderedResultHashIds, options?.rewardsHistoryLimit),
      sortType === 'metrics'
        ? (orderedResult as PoolMetrics[])
        : this.#builder.queryPoolMetrics(orderedResultHashIds, totalAdaAmount),
      sortType === 'apy'
        ? (orderedResult as PoolAPY[])
        : this.#builder.queryPoolAPY(hashesIds, { rewardsHistoryLimit: options?.rewardsHistoryLimit }),
      this.#builder.queryTotalCount(query, params),
      this.#builder.getLastEpoch()
    ]);

    return toCoreStakePool(orderedResultHashIds, {
      lastEpoch,
      poolAPYs,
      poolDatas,
      poolMetrics,
      poolOwners,
      poolRegistrations,
      poolRelays,
      poolRetirements,
      poolRewards: poolRewards.filter(isNotNil),
      totalCount
    });
  }

  public async stakePoolStats(): Promise<StakePoolStats> {
    this.#logger.debug('About to query pool stats');
    return this.#builder.queryPoolStats();
  }
}
