import { AccountBalanceModel, RewardEpochModel } from './types';
import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Pool, QueryResult } from 'pg';
import { Range } from '@cardano-sdk/util';
import { findAccountBalance, findRewardsHistory } from './queries';

export class RewardsBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }

  public async getAccountBalance(rewardAccount: Cardano.RewardAccount) {
    this.#logger.debug('About to run findAccountBalance query');
    const result: QueryResult<AccountBalanceModel> = await this.#db.query(findAccountBalance, [rewardAccount]);
    return result.rows.length > 0 ? result.rows[0] : undefined;
  }

  public async getRewardsHistory(rewardAccounts: Cardano.RewardAccount[], epochs?: Range<Cardano.EpochNo>) {
    const params: (string[] | number)[] = [rewardAccounts.map((rewardAcc) => rewardAcc)];
    this.#logger.debug('About to run findRewardsHistory query');
    const result: QueryResult<RewardEpochModel> = await this.#db.query(
      findRewardsHistory(epochs?.lowerBound, epochs?.upperBound),
      params
    );
    return result.rows.length > 0 ? result.rows : [];
  }
}
