import { Cardano, RewardHistoryProps, RewardsProvider } from '@cardano-sdk/core';
import { DbSyncProvider } from '../../DbSyncProvider';
import { Logger, dummyLogger } from 'ts-log';
import { Pool } from 'pg';
import { RewardsBuilder } from './RewardsBuilder';
import { rewardsToCore } from './mappers';

export class DbSyncRewardsProvider extends DbSyncProvider implements RewardsProvider {
  #builder: RewardsBuilder;
  #logger: Logger;

  constructor(db: Pool, logger = dummyLogger) {
    super(db);
    this.#builder = new RewardsBuilder(db, logger);
    this.#logger = logger;
  }

  public async rewardsHistory(props: RewardHistoryProps) {
    const { rewardAccounts, epochs } = props;
    const rewards = await this.#builder.getRewardsHistory(rewardAccounts, epochs);
    return rewardsToCore(rewards);
  }
  public async rewardAccountBalance(rewardAccount: Cardano.RewardAccount) {
    this.#logger.debug(`About to get balance of reward account ${rewardAccount.toString()}`);
    const balance = await this.#builder.getAccountBalance(rewardAccount);
    return BigInt(balance?.balance || '0');
  }
}
