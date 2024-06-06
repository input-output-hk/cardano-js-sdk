import { DbSyncProvider } from '../../util/DbSyncProvider/index.js';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { RewardsBuilder } from './RewardsBuilder.js';
import { rewardsToCore } from './mappers.js';
import type { DbSyncProviderDependencies } from '../../util/DbSyncProvider/index.js';
import type { RewardAccountBalanceArgs, RewardsHistoryArgs, RewardsProvider } from '@cardano-sdk/core';

/** Properties that are need to create DbSyncRewardsProvider */
export interface RewardsProviderProps {
  /** Pagination page size limit used for provider methods constraint. */
  paginationPageSizeLimit: number;
}

export class DbSyncRewardsProvider extends DbSyncProvider() implements RewardsProvider {
  #builder: RewardsBuilder;
  #paginationPageSizeLimit: number;

  constructor(
    { paginationPageSizeLimit }: RewardsProviderProps,
    { cache, dbPools, cardanoNode, logger }: DbSyncProviderDependencies
  ) {
    super({ cache, cardanoNode, dbPools, logger });
    this.#builder = new RewardsBuilder(dbPools.main, logger);
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
