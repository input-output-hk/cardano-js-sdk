import { DbSyncProvider } from '../../DbSyncProvider';
import { Logger } from 'ts-log';
import { Pool } from 'pg';
import {
  ProviderError,
  ProviderFailure,
  RewardAccountBalanceArgs,
  RewardsHistoryArgs,
  RewardsProvider
} from '@cardano-sdk/core';
import { RewardsBuilder } from './RewardsBuilder';
import { rewardsToCore } from './mappers';

export interface RewardsProviderProps {
  paginationPageSizeLimit: number;
}
export interface RewardsProviderDependencies {
  db: Pool;
  logger: Logger;
}

export class DbSyncRewardsProvider extends DbSyncProvider() implements RewardsProvider {
  #logger: Logger;
  #builder: RewardsBuilder;
  #paginationPageSizeLimit: number;

  constructor({ paginationPageSizeLimit }: RewardsProviderProps, { db, logger }: RewardsProviderDependencies) {
    super(db);
    this.#builder = new RewardsBuilder(db, logger);
    this.#logger = logger;
    this.#paginationPageSizeLimit = paginationPageSizeLimit;
  }

  public async rewardsHistory({ rewardAccounts, epochs }: RewardsHistoryArgs) {
    if (rewardAccounts.length > this.#paginationPageSizeLimit) {
      throw new ProviderError(
        ProviderFailure.BadRequest,
        undefined,
        `Reward accounts count of ${rewardAccounts.length} can not be greater than ${this.#paginationPageSizeLimit}`
      );
    }

    const rewards = await this.#builder.getRewardsHistory(rewardAccounts, epochs);
    return rewardsToCore(rewards);
  }
  public async rewardAccountBalance({ rewardAccount }: RewardAccountBalanceArgs) {
    this.#logger.debug(`About to get balance of reward account ${rewardAccount.toString()}`);
    const balance = await this.#builder.getAccountBalance(rewardAccount);
    return BigInt(balance?.balance || '0');
  }
}
