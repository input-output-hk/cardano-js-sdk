import {
  Cardano,
  Paginated,
  ProviderError,
  ProviderFailure,
  QueryStakePoolsArgs,
  StakePoolProvider,
  StakePoolStats
} from '@cardano-sdk/core';
import { DataSource } from 'typeorm';
import { MissingProgramOption } from '../../Program/errors';
import { PoolDelistedEntity, StakePoolEntity } from '@cardano-sdk/projection-typeorm';
import { PoolStatsModel, mapPoolStats, mapStakePoolsResult } from './mappers';
import { ServiceNames } from '../../Program/programs/types';
import { TypeormProvider, TypeormProviderDependencies } from '../../util';
import {
  computeROS,
  getSortOptions,
  getWhereClauseAndArgs,
  nullsInSort,
  stakePoolSearchSelection,
  stakePoolSearchTotalCount
} from './util';

/** Properties that are need to create DbSyncStakePoolProvider */
export interface TypeOrmStakePoolProviderProps {
  /** Number of epochs over which lastRos is computed */
  lastRosEpochs?: number;

  /** Pagination page size limit used for provider methods constraint. */
  paginationPageSizeLimit: number;
}

export class TypeormStakePoolProvider extends TypeormProvider implements StakePoolProvider {
  #lastRosEpochs: number;
  #paginationPageSizeLimit: number;

  constructor(config: TypeOrmStakePoolProviderProps, deps: TypeormProviderDependencies) {
    const { lastRosEpochs, paginationPageSizeLimit } = config;

    super('TypeormStakePoolProvider', deps);
    this.#paginationPageSizeLimit = paginationPageSizeLimit;

    // Introduced following code repetition as the correct form is source of a circular-deps:check failure.
    // Solving it would require an invasive refactoring action, probably better to defer it.
    // if (!lastRosEpochs) throw new MissingProgramOption(STAKE_POOL_REWARDS, Descriptions.LastRosEpochs);
    if (!lastRosEpochs)
      throw new MissingProgramOption(ServiceNames.StakePool, 'Number of epochs over which lastRos is computed');

    this.#lastRosEpochs = lastRosEpochs;
  }

  // eslint-disable-next-line sonarjs/cognitive-complexity
  public async queryStakePools(options: QueryStakePoolsArgs): Promise<Paginated<Cardano.StakePool>> {
    const { epochRewards, epochsLength, filters, pagination, sort } = options;

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

    this.logger.debug('About to query projected stake pools');

    const { clause, args } = getWhereClauseAndArgs(filters);
    const { field, order } = getSortOptions(sort);

    return this.withDataSource<Paginated<Cardano.StakePool>>(async (dataSource: DataSource) => {
      const rawResult = await dataSource
        .createQueryBuilder()
        .from(StakePoolEntity, 'pool')
        .leftJoinAndSelect('pool.metrics', 'metrics')
        .leftJoinAndSelect('pool.lastRegistration', 'params')
        .leftJoinAndSelect('params.metadata', 'metadata')
        .leftJoin(PoolDelistedEntity, 'delist', 'delist.stakePoolId = pool.id')
        .select(stakePoolSearchSelection)
        .addSelect(stakePoolSearchTotalCount)
        .where(clause, args)
        .andWhere('delist.stakePoolId IS NULL')
        .orderBy(field, order, !field.includes('cost') ? nullsInSort : undefined)
        .addOrderBy('pool.id', 'ASC')
        .offset(pagination.startAt)
        .limit(pagination.limit)
        .getRawMany();

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
