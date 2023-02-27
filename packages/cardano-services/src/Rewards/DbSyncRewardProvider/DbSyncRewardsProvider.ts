import { DbSyncProvider, DbSyncProviderDependencies } from '../../util/DbSyncProvider';
import {
  ProviderError,
  ProviderFailure,
  RewardAccountBalanceArgs,
  RewardsHistoryArgs,
  RewardsProvider
} from '@cardano-sdk/core';
import { RewardsBuilder } from './RewardsBuilder';
import { rewardsToCore } from './mappers';

/**
 * Properties that are need to create DbSyncRewardsProvider
 */
export interface RewardsProviderProps {
  /**
   * Pagination page size limit used for provider methods constraint.
   */
  paginationPageSizeLimit: number;
}

export class DbSyncRewardsProvider extends DbSyncProvider() implements RewardsProvider {
  #builder: RewardsBuilder;
  #paginationPageSizeLimit: number;

  constructor(
    { paginationPageSizeLimit }: RewardsProviderProps,
    { db, cardanoNode, logger }: DbSyncProviderDependencies
  ) {
    super({ cardanoNode, db, logger });
    this.#builder = new RewardsBuilder(db, logger);
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
    this.logger.debug(`About to get balance of reward account ${rewardAccount}`);
    const balance = await this.#builder.getAccountBalance(rewardAccount);
    return BigInt(balance?.balance || '0');
  }
}
