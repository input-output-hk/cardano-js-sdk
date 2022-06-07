import { ActiveStakeModel, CirculatingSupplyModel, LiveStakeModel, TotalSupplyModel } from './types';
import { Cardano } from '@cardano-sdk/core';
import { Logger, dummyLogger } from 'ts-log';
import { Pool, QueryResult } from 'pg';
import Queries from './queries';

export class NetworkInfoBuilder {
  #db: Pool;
  #logger: Logger;
  constructor(db: Pool, logger = dummyLogger) {
    this.#db = db;
    this.#logger = logger;
  }

  public async queryCirculatingSupply() {
    this.#logger.debug('About to query circulation supply');
    const result: QueryResult<CirculatingSupplyModel> = await this.#db.query(Queries.findCirculatingSupply);
    return result.rows[0].circulating_supply;
  }

  public async queryTotalSupply(maxLovelaceSupply: Cardano.Lovelace) {
    this.#logger.debug('About to query total supply');
    const result: QueryResult<TotalSupplyModel> = await this.#db.query(Queries.findTotalSupply, [maxLovelaceSupply]);
    return result.rows[0].total_supply;
  }
  public async queryLiveStake() {
    this.#logger.debug('About to query live stake');
    const result: QueryResult<LiveStakeModel> = await this.#db.query(Queries.findLiveStake);
    return result.rows[0].live_stake;
  }

  public async queryActiveStake() {
    this.#logger.debug('About to query active stake');
    const result: QueryResult<ActiveStakeModel> = await this.#db.query(Queries.findActiveStake);
    return result.rows[0].active_stake;
  }
}
