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
import { PoolDelistedEntity, StakePoolEntity } from '@cardano-sdk/projection-typeorm';
import { PoolModel, PoolStatsModel, mapPoolStats, mapStakePoolsResult } from './mappers';
import { TypeormProvider, TypeormProviderDependencies } from '../../util';
import {
  getSortOptions,
  getWhereClauseAndArgs,
  nullsInSort,
  stakePoolSearchSelection,
  stakePoolSearchTotalCount
} from './util';

/** Properties that are need to create DbSyncStakePoolProvider */
export interface TypeOrmStakePoolProviderProps {
  /** Pagination page size limit used for provider methods constraint. */
  paginationPageSizeLimit: number;
}

export class TypeormStakePoolProvider extends TypeormProvider implements StakePoolProvider {
  #paginationPageSizeLimit: number;

  constructor({ paginationPageSizeLimit }: TypeOrmStakePoolProviderProps, deps: TypeormProviderDependencies) {
    super('TypeormStakePoolProvider', deps);
    this.#paginationPageSizeLimit = paginationPageSizeLimit;
  }

  public async queryStakePools(options: QueryStakePoolsArgs): Promise<Paginated<Cardano.StakePool>> {
    const { filters, pagination, sort } = options;

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

    const rawResult = await this.withDataSource<PoolModel[]>((dataSource: DataSource) =>
      dataSource
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
        .getRawMany()
    );

    return mapStakePoolsResult(rawResult);
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
