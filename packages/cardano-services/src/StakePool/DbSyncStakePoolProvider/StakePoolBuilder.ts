/* eslint-disable sonarjs/no-nested-template-literals */
import {
  Cardano,
  MultipleChoiceSearchFilter,
  ProviderError,
  ProviderFailure,
  StakePoolQueryOptions,
  StakePoolStats
} from '@cardano-sdk/core';
import {
  EpochModel,
  EpochRewardModel,
  OrderByOptions,
  OwnerAddressModel,
  PoolAPY,
  PoolAPYModel,
  PoolDataModel,
  PoolMetricsModel,
  PoolRegistrationModel,
  PoolRetirementModel,
  PoolUpdateModel,
  RelayModel,
  StakePoolStatsModel,
  SubQuery,
  TotalAdaModel,
  TotalCountModel
} from './types';
import { Logger, dummyLogger } from 'ts-log';
import { Pool, QueryResult } from 'pg';
import {
  mapAddressOwner,
  mapEpochReward,
  mapPoolAPY,
  mapPoolData,
  mapPoolMetrics,
  mapPoolRegistration,
  mapPoolRetirement,
  mapPoolStats,
  mapPoolUpdate,
  mapRelay
} from './mappers';
import Queries, {
  addSentenceToQuery,
  buildOrQueryFromClauses,
  findLastEpoch,
  findPoolStats,
  getIdentifierFullJoinClause,
  getIdentifierWhereClause,
  getStatusWhereClause,
  getTotalCountQueryFromQuery,
  poolsByPledgeMetSubqueries,
  withPagination,
  withSort
} from './queries';

export class StakePoolBuilder {
  #db: Pool;
  #logger: Logger;
  constructor(db: Pool, logger = dummyLogger) {
    this.#db = db;
    this.#logger = logger;
  }
  public async queryRetirements(hashesIds: number[]) {
    this.#logger.debug('About to query pool retirements');
    const result: QueryResult<PoolRetirementModel> = await this.#db.query(Queries.findPoolsRetirements, [hashesIds]);
    return result.rows.length > 0 ? result.rows.map(mapPoolRetirement) : [];
  }
  public async queryRegistrations(hashesIds: number[]) {
    this.#logger.debug('About to query pool registrations');
    const result: QueryResult<PoolRegistrationModel> = await this.#db.query(Queries.findPoolsRegistrations, [
      hashesIds
    ]);
    return result.rows.length > 0 ? result.rows.map(mapPoolRegistration) : [];
  }
  public async queryPoolRelays(updatesIds: number[]) {
    this.#logger.debug('About to query pool relays');
    const result: QueryResult<RelayModel> = await this.#db.query(Queries.findPoolsRelays, [updatesIds]);
    return result.rows.length > 0 ? result.rows.map(mapRelay) : [];
  }
  public async queryPoolOwners(updatesIds: number[]) {
    this.#logger.debug('About to query pool owners');
    const result: QueryResult<OwnerAddressModel> = await this.#db.query(Queries.findPoolsOwners, [updatesIds]);
    return result.rows.length > 0 ? result.rows.map(mapAddressOwner) : [];
  }
  public async queryPoolRewards(hashesIds: number[], limit?: number) {
    return Promise.all(
      hashesIds.map(async (hashId) => {
        const result: QueryResult<EpochRewardModel> = await this.#db.query(Queries.findPoolEpochRewards(limit), [
          [hashId]
        ]);
        return result.rows.length > 0 ? mapEpochReward(result.rows[0], hashId) : undefined;
      })
    );
  }
  public async queryPoolAPY(hashesIds: number[], options?: StakePoolQueryOptions): Promise<PoolAPY[]> {
    this.#logger.debug('About to query pools APY');
    const defaultSort: OrderByOptions[] = [{ field: 'apy', order: 'desc' }];
    const queryWithSortAndPagination = withPagination(
      withSort(Queries.findPoolAPY(options?.rewardsHistoryLimit), options?.sort, defaultSort),
      options?.pagination
    );
    const result: QueryResult<PoolAPYModel> = await this.#db.query(queryWithSortAndPagination, [hashesIds]);
    return result.rows.map(mapPoolAPY);
  }
  public async queryPoolData(updatesIds: number[], options?: StakePoolQueryOptions) {
    this.#logger.debug('About to query pool data');
    const defaultSort: OrderByOptions[] = [
      { field: 'name', order: 'asc' },
      { field: 'pool_id', order: 'asc' }
    ];
    const queryWithSortAndPagination = withPagination(
      withSort(Queries.findPoolsData, options?.sort, defaultSort),
      options?.pagination
    );
    const result: QueryResult<PoolDataModel> = await this.#db.query(queryWithSortAndPagination, [updatesIds]);
    return result.rows.length > 0 ? result.rows.map(mapPoolData) : [];
  }
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  public async queryPoolHashes(query: string, params: any[] = []) {
    const result: QueryResult<PoolUpdateModel> = await this.#db.query(query, params);
    return result.rows.length > 0 ? result.rows.map(mapPoolUpdate) : [];
  }
  public async queryPoolMetrics(hashesIds: number[], totalAdaAmount: string, options?: StakePoolQueryOptions) {
    this.#logger.debug('About to query pool metrics');
    const queryWithSortAndPagination = withPagination(
      withSort(Queries.findPoolsMetrics, options?.sort, [{ field: 'saturation', order: 'desc' }]),
      options?.pagination
    );
    const result: QueryResult<PoolMetricsModel> = await this.#db.query(queryWithSortAndPagination, [
      hashesIds,
      totalAdaAmount
    ]);
    return result.rows.length > 0 ? result.rows.map(mapPoolMetrics) : [];
  }
  public buildPoolsByIdentifierQuery(
    identifier: MultipleChoiceSearchFilter<
      Partial<Pick<Cardano.PoolParameters, 'id'> & Pick<Cardano.StakePoolMetadata, 'name' | 'ticker'>>
    >
  ) {
    const { where, params } = getIdentifierWhereClause(identifier);
    const whereClause = 'WHERE '.concat(where);
    const query = `
    ${Queries.IDENTIFIER_QUERY.SELECT_CLAUSE}
    ${Queries.IDENTIFIER_QUERY.JOIN_CLAUSE.POOL_UPDATE}
    ${Queries.IDENTIFIER_QUERY.JOIN_CLAUSE.OFFLINE_METADATA}
    ${whereClause}
    `;
    return { id: { isPrimary: true, name: 'pools_by_identifier' }, params, query };
  }
  public buildPoolsByStatusQuery(status: Cardano.StakePoolStatus[]) {
    const whereClause = getStatusWhereClause(status);
    const query = `
    ${Queries.STATUS_QUERY.SELECT_CLAUSE}
    WHERE ${whereClause}
    `;
    return { id: { isPrimary: true, name: 'pools_by_status' }, query };
  }
  public buildPoolsByPledgeMetQuery(pledgeMet: boolean) {
    const subQueries = [...poolsByPledgeMetSubqueries];
    subQueries.push({
      id: { isPrimary: true, name: 'pools_by_pledge_met' },
      query: `
    ${Queries.POOLS_WITH_PLEDGE_MET.SELECT_CLAUSE} 
    ${Queries.POOLS_WITH_PLEDGE_MET.JOIN_CLAUSE} 
    WHERE ${Queries.POOLS_WITH_PLEDGE_MET.WHERE_CLAUSE(pledgeMet)}`
    });
    return subQueries;
  }
  public async getLastEpoch() {
    this.#logger.debug('About to query last epoch');
    const result: QueryResult<EpochModel> = await this.#db.query(Queries.findLastEpoch);
    return result.rows[0].no;
  }
  public async getTotalAmountOfAda() {
    this.#logger.debug('About to get total amount of ada');
    const result: QueryResult<TotalAdaModel> = await this.#db.query(Queries.findTotalAda);
    return result.rows[0].total_ada;
  }
  public buildOrQuery(filters: StakePoolQueryOptions['filters']) {
    const subQueries: SubQuery[] = [];
    const params = [];
    let query = Queries.findPools;
    if (filters?.identifier) {
      const { id: _id, query: _query, params: _params } = this.buildPoolsByIdentifierQuery(filters.identifier);
      subQueries.push({ id: _id, query: _query });
      params.push(..._params);
    }
    if (filters?.status) {
      const statusQuery = this.buildPoolsByStatusQuery(filters.status);
      subQueries.push(statusQuery);
    }
    if (filters?.pledgeMet !== undefined) {
      const pledgeMetQuery = this.buildPoolsByPledgeMetQuery(filters.pledgeMet);
      subQueries.push(...pledgeMetQuery);
    }
    if (filters?.status || filters?.pledgeMet !== undefined)
      subQueries.unshift({ id: { name: 'current_epoch' }, query: findLastEpoch });
    if (subQueries.length > 0) {
      query = subQueries.length > 1 ? buildOrQueryFromClauses(subQueries) : subQueries[0].query;
    }
    return { params, query };
  }
  public buildAndQuery(filters: StakePoolQueryOptions['filters']) {
    let query = Queries.findPools;
    let groupByClause = ' GROUP BY ph.id, pu.id ORDER BY ph.id DESC';
    const params = [];
    const whereClause = [];
    if (filters?.pledgeMet !== undefined) {
      const { WITH_CLAUSE, SELECT_CLAUSE, JOIN_CLAUSE, WHERE_CLAUSE } = Queries.POOLS_WITH_PLEDGE_MET;
      query = WITH_CLAUSE + SELECT_CLAUSE + JOIN_CLAUSE;
      whereClause.push(WHERE_CLAUSE(filters.pledgeMet));
      if (filters.identifier) {
        query = addSentenceToQuery(query, `${getIdentifierFullJoinClause()}`);
        const { where, params: identifierParams } = getIdentifierWhereClause(filters.identifier);
        whereClause.push(where);
        params.push(...identifierParams);
      }
      if (filters.status) {
        query = addSentenceToQuery(
          query,
          `
          LEFT JOIN pool_retire pr ON 
            pr.id = (
              SELECT id
              FROM pool_retire pr2
              WHERE pr2.hash_id = ph.id
              ORDER BY id desc 
              LIMIT 1
            )
          `
        );
        whereClause.push(getStatusWhereClause(filters.status, { activeEpoch: 'ph.active_epoch_no' }));
      }
      groupByClause = ' GROUP BY ph.id, ph.update_id ORDER BY ph.id DESC';
    } else if (filters?.status) {
      query = `${Queries.STATUS_QUERY.WITH_CLAUSE} ${Queries.STATUS_QUERY.SELECT_CLAUSE}`;
      whereClause.push(getStatusWhereClause(filters.status));
      if (filters?.identifier) {
        query = addSentenceToQuery(query, Queries.IDENTIFIER_QUERY.JOIN_CLAUSE.OFFLINE_METADATA);
        const { where, params: identifierParams } = getIdentifierWhereClause(filters.identifier);
        whereClause.push(where);
        params.push(...identifierParams);
      }
    } else if (filters?.identifier) {
      const { where, params: identifierParams } = getIdentifierWhereClause(filters.identifier);
      query = `
        ${Queries.IDENTIFIER_QUERY.SELECT_CLAUSE}
        ${getIdentifierFullJoinClause()}
        WHERE ${where}
        `;
      params.push(...identifierParams);
    }
    if (whereClause.length > 0) query = addSentenceToQuery(query, ` WHERE ${whereClause.join(' AND ')}`);
    query = addSentenceToQuery(query, groupByClause);
    return { params, query };
  }
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  public async queryTotalCount(query: string, _params: any[]) {
    this.#logger.debug('About to get total count of pools');
    const result: QueryResult<TotalCountModel> = await this.#db.query(getTotalCountQueryFromQuery(query), _params);
    return result.rows[0].total_count;
  }

  public async queryPoolStats(): Promise<StakePoolStats> {
    this.#logger.debug('About to get pool stats');
    const result: QueryResult<StakePoolStatsModel> = await this.#db.query(findPoolStats);
    const poolStats = result.rows[0];
    if (!poolStats) throw new ProviderError(ProviderFailure.Unknown, null, "Couldn't fetch pool stats");
    return mapPoolStats(poolStats);
  }
}
