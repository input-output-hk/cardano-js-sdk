import {
  Cardano,
  FuzzyOptions,
  Paginated,
  ProviderError,
  ProviderFailure,
  QueryStakePoolsArgs,
  StakePoolProvider,
  StakePoolStats
} from '@cardano-sdk/core';
import { DataSource } from 'typeorm';
import { InMemoryCache } from '../../InMemoryCache';
import { MissingProgramOption } from '../../Program/errors';
import { PoolDelistedEntity, StakePoolEntity } from '@cardano-sdk/projection-typeorm';
import { PoolModel, PoolStatsModel, mapPoolStats, mapStakePoolsResult } from './mappers';
import { ServiceNames } from '../../Program/programs/types';
import { TypeormProvider, TypeormProviderDependencies } from '../../util';
import {
  computeROS,
  getSortOptions,
  getWhereClauseAndArgs,
  stakePoolSearchSelection,
  stakePoolSearchTotalCount,
  withTextFilter
} from './util';
import Fuse from 'fuse.js';

export const DEFAULT_FUZZY_SEARCH_OPTIONS: FuzzyOptions = {
  threshold: 0.4,
  weights: { description: 1, homepage: 2, name: 3, poolId: 4, ticker: 4 }
};

/** Properties that are need to create TypeormStakePoolProvider */
export interface TypeOrmStakePoolProviderProps {
  /** Options for the fuzzy search on stake pool metadata */
  fuzzyOptions?: FuzzyOptions;

  /** Number of epochs over which lastRos is computed */
  lastRosEpochs?: number;

  /** Pagination page size limit used for provider methods constraint. */
  paginationPageSizeLimit: number;

  /** If `true` allows the override of `fuzzyOptions` through `queryStakePools` call.*/
  overrideFuzzyOptions?: boolean;
}

export interface TypeormStakePoolProviderDependencies extends TypeormProviderDependencies {
  cache: InMemoryCache;
}

export class TypeormStakePoolProvider extends TypeormProvider implements StakePoolProvider {
  #cache: InMemoryCache;
  #fuzzyOptions: FuzzyOptions;
  #lastRosEpochs: number;
  #paginationPageSizeLimit: number;
  #overrideFuzzyOptions: boolean;

  constructor(config: TypeOrmStakePoolProviderProps, deps: TypeormStakePoolProviderDependencies) {
    const { lastRosEpochs, paginationPageSizeLimit } = config;

    super('TypeormStakePoolProvider', deps);
    this.#cache = deps.cache;
    this.#fuzzyOptions = DEFAULT_FUZZY_SEARCH_OPTIONS;
    this.#paginationPageSizeLimit = paginationPageSizeLimit;
    this.#overrideFuzzyOptions = true;

    // Introduced following code repetition as the correct form is source of a circular-deps:check failure.
    // Solving it would require an invasive refactoring action, probably better to defer it.
    // if (!lastRosEpochs) throw new MissingProgramOption(STAKE_POOL_REWARDS, Descriptions.LastRosEpochs);
    if (!lastRosEpochs)
      throw new MissingProgramOption(ServiceNames.StakePool, 'Number of epochs over which lastRos is computed');

    this.#lastRosEpochs = lastRosEpochs;
  }

  async startImpl() {
    await super.startImpl();

    await this.withDataSource((dataSource) => this.getFuse(dataSource));
  }

  private async getFuse(dataSource: DataSource, fuzzyOptions?: FuzzyOptions) {
    const {
      threshold,
      weights: { description, homepage, name, poolId, ticker }
    } = this.#overrideFuzzyOptions ? { ...this.#fuzzyOptions, ...fuzzyOptions } : this.#fuzzyOptions;

    const cacheKey = this.#overrideFuzzyOptions
      ? `fuzzy-index-${JSON.stringify([description, homepage, name, threshold, ticker])}`
      : 'fuzzy-index';

    return this.#cache.get(cacheKey, async () => {
      const metadata = await this.#cache.get('all-metadata', async () =>
        dataSource
          .createQueryBuilder()
          .from(StakePoolEntity, 'pool')
          .leftJoinAndSelect('pool.lastRegistration', 'params')
          .leftJoinAndSelect('params.metadata', 'metadata')
          .select(['description', 'homepage', 'name', 'pool.id AS pool_id', 'ticker'])
          .getRawMany<{ description: string; homepage: string; name: string; pool_id: string; ticker: string }>()
      );

      const opts = {
        ignoreFieldNorm: true,
        ignoreLocation: true,
        includeScore: true,
        keys: [
          { name: 'description', weight: description },
          { name: 'homepage', weight: homepage },
          { name: 'name', weight: name },
          { name: 'pool_id', weight: poolId },
          { name: 'ticker', weight: ticker }
        ],
        minMatchCharLength: 3,
        threshold
      };

      return new Fuse(metadata, opts, Fuse.createIndex(opts.keys, metadata));
    });
  }

  // eslint-disable-next-line sonarjs/cognitive-complexity
  public async queryStakePools(options: QueryStakePoolsArgs): Promise<Paginated<Cardano.StakePool>> {
    const { epochRewards, epochsLength, filters, fuzzyOptions, pagination, sort } = options;

    if (pagination.limit > this.#paginationPageSizeLimit) {
      throw new ProviderError(
        ProviderFailure.BadRequest,
        undefined,
        `Page size of ${pagination.limit} can not be greater than ${this.#paginationPageSizeLimit}`
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

    // eslint-disable-next-line complexity
    return this.withDataSource(async (dataSource: DataSource) => {
      const queryRunner = dataSource.createQueryRunner();

      let rawResult: PoolModel[];
      let sortByScore = false;
      let textFilter = false;

      try {
        if (withTextFilter(filters)) {
          sortByScore = sort === undefined;
          textFilter = true;

          const values = (await this.getFuse(dataSource, fuzzyOptions))
            .search(filters.text)
            .map(({ item: { pool_id }, score }) => `('${pool_id}',${score})`)
            .join(',');

          await queryRunner.query(
            [
              'DROP TABLE IF EXISTS tmp_fuzzy',
              'CREATE TEMPORARY TABLE tmp_fuzzy (pool_id VARCHAR, score NUMERIC) WITHOUT OIDS',
              `INSERT INTO tmp_fuzzy VALUES ${values}`
            ].join(';')
          );
        }

        this.logger.debug('About to query projected stake pools');

        const { clause, args } = getWhereClauseAndArgs(filters, textFilter);
        const { field, order } = getSortOptions(sortByScore, sort);

        const queryBuilder1 = dataSource.createQueryBuilder(queryRunner).from(StakePoolEntity, 'pool');
        const queryBuilder2 = textFilter ? queryBuilder1.innerJoin('tmp_fuzzy', 'tmp', 'id = pool_id') : queryBuilder1;

        rawResult = await queryBuilder2
          .leftJoinAndSelect('pool.metrics', 'metrics')
          .leftJoinAndSelect('pool.lastRegistration', 'params')
          .leftJoinAndSelect('params.metadata', 'metadata')
          .leftJoin(PoolDelistedEntity, 'delist', 'delist.stakePoolId = pool.id')
          .select(stakePoolSearchSelection)
          .addSelect(stakePoolSearchTotalCount)
          .where(clause, args)
          .andWhere('delist.stakePoolId IS NULL')
          .orderBy(field, order, 'NULLS LAST')
          .addOrderBy('pool.id', 'ASC')
          .offset(pagination.startAt)
          .limit(pagination.limit)
          .getRawMany<PoolModel>();
      } finally {
        try {
          if (textFilter) await queryRunner.query('DROP TABLE IF EXISTS tmp_fuzzy');
        } finally {
          await queryRunner.release();
        }
      }

      const result = mapStakePoolsResult(rawResult);
      const requestedNotStdLength = epochsLength !== undefined && epochsLength !== this.#lastRosEpochs;

      if (epochRewards || requestedNotStdLength) {
        const epochs = epochsLength || this.#lastRosEpochs;

        for (const pool of result.pageResults) {
          const { id, metrics } = pool;
          const [ros, history] = await computeROS({ dataSource, epochs, logger: this.logger, stakePool: { id } });

          if (epochRewards) pool.rewardHistory = history;
          if (requestedNotStdLength && metrics) metrics.lastRos = ros;
        }
      }

      return result;
    });
  }

  public async stakePoolStats(): Promise<StakePoolStats> {
    this.logger.debug('About to query projected pool stats');

    const rawResult = await this.withDataSource<PoolStatsModel[]>((dataSource: DataSource) =>
      dataSource
        .createQueryBuilder()
        .addSelect('count(*) as count, pool.status')
        .from(StakePoolEntity, 'pool')
        .groupBy('pool.status')
        .getRawMany()
    );

    return { qty: mapPoolStats(rawResult) };
  }
}
