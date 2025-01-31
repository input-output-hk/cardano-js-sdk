import { Cardano, Reward, RewardAccountBalanceArgs, RewardsHistoryArgs, RewardsProvider } from '@cardano-sdk/core';

import { BlockfrostClient, BlockfrostProvider, fetchSequentially, isBlockfrostNotFoundError } from '../blockfrost';
import { Logger } from 'ts-log';
import { Range } from '@cardano-sdk/util';
import type { Responses } from '@blockfrost/blockfrost-js';

const stringToBigInt = (str: string) => BigInt(str);

export class BlockfrostRewardsProvider extends BlockfrostProvider implements RewardsProvider {
  constructor(client: BlockfrostClient, logger: Logger) {
    super(client, logger);
  }

  public async rewardAccountBalance({ rewardAccount }: RewardAccountBalanceArgs) {
    try {
      const accountResponse = await this.request<Responses['account_content']>(`accounts/${rewardAccount.toString()}`);
      return BigInt(accountResponse.withdrawable_amount);
    } catch (error) {
      if (isBlockfrostNotFoundError(error)) {
        return 0n;
      }
      throw this.toProviderError(error);
    }
  }
  protected async accountRewards(
    stakeAddress: Cardano.RewardAccount,
    {
      lowerBound = Cardano.EpochNo(0),
      upperBound = Cardano.EpochNo(Number.MAX_SAFE_INTEGER)
    }: Range<Cardano.EpochNo> = {}
  ): Promise<Reward[]> {
    const batchSize = 100;
    return fetchSequentially<Responses['account_reward_content'][0], Reward>({
      haveEnoughItems: (_, rewardsPage) => {
        const lastReward = rewardsPage[rewardsPage.length - 1];
        return !lastReward || lastReward.epoch >= upperBound;
      },
      paginationOptions: { count: batchSize },
      request: (paginationQueryString) =>
        this.request<Responses['account_reward_content']>(
          `accounts/${stakeAddress.toString()}/rewards?${paginationQueryString}`
        ),
      responseTranslator: (rewardsPage) =>
        rewardsPage
          .filter(({ epoch }) => lowerBound <= epoch && epoch <= upperBound)
          .map(({ epoch, amount, pool_id }) => ({
            epoch: Cardano.EpochNo(epoch),
            rewards: stringToBigInt(amount),
            ...(pool_id && { poolId: Cardano.PoolId(pool_id) })
          }))
    });
  }
  public async rewardsHistory({ rewardAccounts, epochs }: RewardsHistoryArgs) {
    const allAddressRewards = await Promise.all(rewardAccounts.map((address) => this.accountRewards(address, epochs)));
    return new Map(allAddressRewards.map((epochRewards, i) => [rewardAccounts[i], epochRewards]));
  }
}
