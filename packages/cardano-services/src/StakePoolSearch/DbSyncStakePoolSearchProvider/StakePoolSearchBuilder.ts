/* eslint-disable sonarjs/no-nested-template-literals */
import { Cardano, MultipleChoiceSearchFilter, StakePoolQueryOptions } from '@cardano-sdk/core';
import {
  EpochModel,
  EpochRewardModel,
  OwnerAddressModel,
  PoolDataModel,
  PoolMetricsModel,
  PoolRegistrationModel,
  PoolRetirementModel,
  PoolUpdateModel,
  RelayModel,
  SubQuery,
  TotalAdaModel
} from './types';
import { Logger, dummyLogger } from 'ts-log';
import { Pool, QueryResult } from 'pg';
import {
  mapAddressOwner,
  mapEpochReward,
  mapPoolData,
  mapPoolMetrics,
  mapPoolRegistration,
  mapPoolRetirement,
  mapPoolUpdate,
  mapRelay
} from './mappers';
import Queries, {
  addSentenceToQuery,
  buildOrQueryFromClauses,
  findLastEpoch,
  getIdentifierFullJoinClause,
  getIdentifierWhereClause,
  getStatusWhereClause,
  poolsByPledgeMetSubqueries,
  withPagination
} from './queries';

export class StakePoolSearchBuilder {
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
          hashId
        ]);
        return result.rows.length > 0 ? mapEpochReward(result.rows[0], hashId) : undefined;
      })
    );
  }
  public async queryPoolData(updatesIds: number[]) {
    this.#logger.debug('About to query pool data');
    const result: QueryResult<PoolDataModel> = await this.#db.query(Queries.findPoolsData, [updatesIds]);
    return result.rows.length > 0 ? result.rows.map(mapPoolData) : [];
  }
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  public async queryPoolHashes(query: string, params: any[] = [], pagination?: StakePoolQueryOptions['pagination']) {
    const queryWithPagination = withPagination(query, pagination);
    const result: QueryResult<PoolUpdateModel> = await this.#db.query(queryWithPagination, params);
    return result.rows.length > 0 ? result.rows.map(mapPoolUpdate) : [];
  }
  public async queryPoolMetrics(hashesIds: number[], totalAdaAmount: string) {
    this.#logger.debug('About to query pool data');
    const result: QueryResult<PoolMetricsModel> = await this.#db.query(Queries.findPoolsMetrics, [
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
      query =
        subQueries.length > 1
          ? buildOrQueryFromClauses(subQueries)
          : `${subQueries.length > 1 ? `WITH (${subQueries.find((sq) => !sq.id.isPrimary)})` : ''} ${
              subQueries[0].query
            } `;
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
}
