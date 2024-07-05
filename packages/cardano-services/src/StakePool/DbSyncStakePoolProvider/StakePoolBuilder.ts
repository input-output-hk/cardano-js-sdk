/* eslint-disable sonarjs/no-nested-template-literals */
import {
  BlockfrostPoolMetricsModel,
  EpochModel,
  OrderByOptions,
  OwnerAddressModel,
  PoolAPY,
  PoolAPYModel,
  PoolDataModel,
  PoolMetricsModel,
  PoolRegistrationModel,
  PoolRetirementModel,
  PoolUpdateModel,
  QueryPoolsApyArgs,
  RelayModel,
  StakePoolStatsModel,
  SubQuery
} from './types';
import {
  Cardano,
  MultipleChoiceSearchFilter,
  ProviderError,
  ProviderFailure,
  QueryStakePoolsArgs,
  StakePoolStats
} from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Pool, QueryResult } from 'pg';
import { findLastEpoch } from '../../util';
import {
  mapAddressOwner,
  mapBlockfrostPoolMetrics,
  mapEpoch,
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
  blockfrostQuery,
  buildOrQueryFromClauses,
  findPoolStats,
  getIdentifierFullJoinClause,
  getIdentifierWhereClause,
  getStatusWhereClause,
  poolsByPledgeMetSubqueries,
  withPagination,
  withSort
} from './queries';

export class StakePoolBuilder {
  #db: Pool;
  #logger: Logger;
  constructor(db: Pool, logger: Logger) {
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

  public async queryPoolAPY(hashesIds: number[], epochLength: number, options?: QueryPoolsApyArgs): Promise<PoolAPY[]> {
    this.#logger.debug('About to query pools APY');
    const defaultSort: OrderByOptions[] = [{ field: 'apy', order: 'desc' }];

    const sorted = withSort(Queries.findPoolAPY(epochLength, options?.apyEpochsBackLimit), options?.sort, defaultSort);
    const { query, args } = withPagination(sorted, [hashesIds], options?.pagination);
    const result = await this.#db.query<PoolAPYModel>(query, args);

    return result.rows.map(mapPoolAPY);
  }

  public async queryPoolData(updatesIds: number[], useBlockfrost: boolean, options?: QueryStakePoolsArgs) {
    this.#logger.debug('About to query pool data');
    const defaultSort: OrderByOptions[] = [
      { field: 'name', order: 'asc' },
      { field: 'pool_id', order: 'asc' }
    ];
    const sorted = withSort(
      useBlockfrost ? Queries.findBlockfrostPoolsData : Queries.findPoolsData,
      options?.sort,
      defaultSort
    );
    const { query, args } = withPagination(sorted, [updatesIds], options?.pagination);
    const result = await this.#db.query<PoolDataModel>(query, args);
    return result.rows.length > 0 ? result.rows.map(mapPoolData) : [];
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  public async queryPoolHashes(query: string, params: any[] = []) {
    this.#logger.debug('About to query pool hashes');
    const result: QueryResult<PoolUpdateModel> = await this.#db.query(query, params);
    return result.rows.length > 0 ? result.rows.map(mapPoolUpdate) : [];
  }

  public async queryPoolMetrics(
    hashesIds: number[],
    totalStake: string | null,
    useBlockfrost: boolean,
    options?: QueryStakePoolsArgs
  ) {
    this.#logger.debug('About to query pool metrics');

    if (useBlockfrost) {
      const sorted = withSort(Queries.findBlockfrostPoolsMetrics, options?.sort, [
        { field: 'saturation', order: 'desc' }
      ]);
      const { query, args } = withPagination(sorted, [hashesIds], options?.pagination);
      const result = await this.#db.query<BlockfrostPoolMetricsModel>(query, args);
      return result.rows.map(mapBlockfrostPoolMetrics);
    }

    const sorted = withSort(Queries.findPoolsMetrics, options?.sort, [{ field: 'saturation', order: 'desc' }]);
    const { query, args } = withPagination(sorted, [hashesIds, totalStake], options?.pagination);
    const result = await this.#db.query<PoolMetricsModel>(query, args);
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
    const result: QueryResult<EpochModel> = await this.#db.query({
      name: 'current_epoch',
      text: findLastEpoch
    });
    const lastEpoch = result.rows[0];
    if (!lastEpoch) throw new ProviderError(ProviderFailure.Unknown, null, "Couldn't find last epoch");
    return lastEpoch.no;
  }

  public async getLastEpochWithData() {
    this.#logger.debug('About to query last epoch with data');
    const result: QueryResult<EpochModel> = await this.#db.query(Queries.findLastEpochWithData);
    const lastEpoch = result.rows[0];
    if (!lastEpoch) throw new ProviderError(ProviderFailure.Unknown, null, "Couldn't find last epoch");
    return mapEpoch(lastEpoch);
  }

  public buildOrQuery(filters: QueryStakePoolsArgs['filters']) {
    const subQueries: SubQuery[] = [];
    const params = [];
    let query = Queries.findPools;
    if (filters?.identifier && filters.identifier.values.length > 0) {
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

  // eslint-disable-next-line max-statements
  public buildAndQuery(filters: QueryStakePoolsArgs['filters']) {
    let query = Queries.findPools;
    let groupByClause = ' GROUP BY ph.id, pu.id ORDER BY ph.id DESC';
    const params = [];
    const whereClause = [];
    const containsIdentifierCondition = filters?.identifier && filters.identifier.values.length > 0;
    if (filters?.pledgeMet !== undefined) {
      const { WITH_CLAUSE, SELECT_CLAUSE, JOIN_CLAUSE, WHERE_CLAUSE } = Queries.POOLS_WITH_PLEDGE_MET;
      query = WITH_CLAUSE + SELECT_CLAUSE + JOIN_CLAUSE;
      whereClause.push(WHERE_CLAUSE(filters.pledgeMet));
      if (containsIdentifierCondition) {
        query = addSentenceToQuery(query, `${getIdentifierFullJoinClause()}`);
        const { where, params: identifierParams } = getIdentifierWhereClause(filters!.identifier!);
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
      if (containsIdentifierCondition) {
        query = addSentenceToQuery(query, Queries.IDENTIFIER_QUERY.JOIN_CLAUSE.OFFLINE_METADATA);
        const { where, params: identifierParams } = getIdentifierWhereClause(filters!.identifier!);
        whereClause.push(where);
        params.push(...identifierParams);
      }
    } else if (containsIdentifierCondition) {
      const { where, params: identifierParams } = getIdentifierWhereClause(filters!.identifier!);
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

  public async queryPoolStats(): Promise<StakePoolStats> {
    this.#logger.debug('About to get pool stats');
    const result: QueryResult<StakePoolStatsModel> = await this.#db.query(findPoolStats);
    const poolStats = result.rows[0];
    if (!poolStats) throw new ProviderError(ProviderFailure.Unknown, null, "Couldn't fetch pool stats");
    return mapPoolStats(poolStats);
  }

  public buildBlockfrostQuery(filters: QueryStakePoolsArgs['filters']): { params: string[]; query: string } {
    const query = blockfrostQuery.SELECT;
    let params: string[] = [];

    if (!filters) return { params, query };

    const { _condition, identifier, pledgeMet, status } = filters;
    const clauses: string[] = [query];
    const whereConditions: string[] = [];

    if (identifier || pledgeMet !== undefined) clauses.push(blockfrostQuery.identifierOrPledge.JOIN);

    if (identifier) {
      let where: string;
      ({ params, where } = getIdentifierWhereClause(filters!.identifier!));

      clauses.push(blockfrostQuery.identifier.JOIN);
      whereConditions.push(where);
    }

    if (pledgeMet !== undefined || status) clauses.push(blockfrostQuery.pledgeOrStatus.JOIN);

    if (pledgeMet !== undefined) whereConditions.push(blockfrostQuery.pledge.WHERE(pledgeMet));

    if (status) whereConditions.push(blockfrostQuery.status.WHERE(status));

    // this happens when an empty object is provided as filter parameter
    if (whereConditions.length === 0) return { params, query };

    return {
      params,
      query: `${clauses.join('')}
      WHERE
      ${whereConditions.join(` ${_condition === 'or' ? 'OR' : 'AND'}\n  `)}`
    };
  }
}
