/* eslint-disable sonarjs/no-nested-template-literals */
import { Cardano, StakePoolQueryOptions, StakePoolSearchProvider, util } from '@cardano-sdk/core';
import { DbSyncProvider } from '../../DbSyncProvider';
import { Logger, dummyLogger } from 'ts-log';
import { Pool } from 'pg';
import { StakePoolSearchBuilder } from './StakePoolSearchBuilder';
import { toCoreStakePool } from './mappers';

export class DbSyncStakePoolSearchProvider extends DbSyncProvider implements StakePoolSearchProvider {
  #builder: StakePoolSearchBuilder;
  #logger: Logger;

  constructor(db: Pool, logger = dummyLogger) {
    super(db);
    this.#builder = new StakePoolSearchBuilder(db, logger);
    this.#logger = logger;
  }

  public async queryStakePools(options?: StakePoolQueryOptions): Promise<Cardano.StakePool[]> {
    const { params, query } =
      options?.filters?._condition === 'or'
        ? this.#builder.buildOrQuery(options?.filters)
        : this.#builder.buildAndQuery(options?.filters);
    this.#logger.debug('About to query pool hashes');
    const poolUpdates = await this.#builder.queryPoolHashes(query, params, options?.pagination);
    const hashesIds = poolUpdates.map(({ id }) => id);
    this.#logger.debug(`${hashesIds.length} pools found`);
    const updatesIds = poolUpdates.map(({ updateId }) => updateId);
    const totalAdaAmount = await this.#builder.getTotalAmountOfAda();
    const [poolDatas, poolRelays, poolOwners, poolRegistrations, poolRetirements, poolRewards, lastEpoch, poolMetrics] =
      await Promise.all([
        this.#builder.queryPoolData(updatesIds),
        this.#builder.queryPoolRelays(updatesIds),
        this.#builder.queryPoolOwners(updatesIds),
        this.#builder.queryRegistrations(hashesIds),
        this.#builder.queryRetirements(hashesIds),
        this.#builder.queryPoolRewards(hashesIds, options?.rewardsHistoryLimit),
        this.#builder.getLastEpoch(),
        this.#builder.queryPoolMetrics(hashesIds, totalAdaAmount)
      ]);
    return toCoreStakePool({
      lastEpoch,
      poolDatas,
      poolMetrics,
      poolOwners,
      poolRegistrations,
      poolRelays,
      poolRetirements,
      poolRewards: poolRewards.filter(util.isNotNil)
    });
  }
}
