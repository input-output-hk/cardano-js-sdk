/* eslint-disable sonarjs/no-nested-template-literals */
import { DbSyncProvider } from '../../DbSyncProvider';
import { Logger, dummyLogger } from 'ts-log';
import { Pool } from 'pg';
import { StakePoolBuilder } from './StakePoolBuilder';
import {
  StakePoolProvider,
  StakePoolQueryOptions,
  StakePoolSearchResults,
  StakePoolStats,
  util
} from '@cardano-sdk/core';
import { toCoreStakePool } from './mappers';

export class DbSyncStakePoolProvider extends DbSyncProvider implements StakePoolProvider {
  #builder: StakePoolBuilder;
  #logger: Logger;

  constructor(db: Pool, logger = dummyLogger) {
    super(db);
    this.#builder = new StakePoolBuilder(db, logger);
    this.#logger = logger;
  }

  public async queryStakePools(options?: StakePoolQueryOptions): Promise<StakePoolSearchResults> {
    const { params, query } =
      options?.filters?._condition === 'or'
        ? this.#builder.buildOrQuery(options?.filters)
        : this.#builder.buildAndQuery(options?.filters);
    this.#logger.debug('About to query pool hashes');
    const poolUpdates = await this.#builder.queryPoolHashes(query, params);
    const hashesIds = poolUpdates.map(({ id }) => id);
    this.#logger.debug(`${hashesIds.length} pools found`);
    const updatesIds = poolUpdates.map(({ updateId }) => updateId);
    const totalAdaAmount = await this.#builder.getTotalAmountOfAda();
    const [
      poolDatas,
      poolRelays,
      poolOwners,
      poolRegistrations,
      poolRetirements,
      poolRewards,
      lastEpoch,
      poolMetrics,
      totalCount
    ] = await Promise.all([
      this.#builder.queryPoolData(updatesIds, options),
      this.#builder.queryPoolRelays(updatesIds),
      this.#builder.queryPoolOwners(updatesIds),
      this.#builder.queryRegistrations(hashesIds),
      this.#builder.queryRetirements(hashesIds),
      this.#builder.queryPoolRewards(hashesIds, options?.rewardsHistoryLimit),
      this.#builder.getLastEpoch(),
      this.#builder.queryPoolMetrics(hashesIds, totalAdaAmount),
      this.#builder.queryTotalCount(query, params)
    ]);
    return toCoreStakePool({
      lastEpoch,
      poolDatas,
      poolMetrics,
      poolOwners,
      poolRegistrations,
      poolRelays,
      poolRetirements,
      poolRewards: poolRewards.filter(util.isNotNil),
      totalCount
    });
  }

  public async stakePoolStats(): Promise<StakePoolStats> {
    this.#logger.debug('About to query pool stats');
    return this.#builder.queryPoolStats();
  }
}
