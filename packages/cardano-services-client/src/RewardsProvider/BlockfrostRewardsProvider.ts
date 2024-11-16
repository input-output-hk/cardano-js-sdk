import { Cardano, Reward, RewardAccountBalanceArgs, RewardsHistoryArgs, RewardsProvider } from '@cardano-sdk/core';

import { BlockfrostClient, BlockfrostProvider, isBlockfrostNotFoundError } from '../blockfrost';
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
    try {
      const result: Reward[] = [];
      const batchSize = 100;
      let page = 1;
      let haveMorePages = true;
      while (haveMorePages) {
        const rewardsPage = await this.request<Responses['account_reward_content']>(
          `accounts/${stakeAddress.toString()}/rewards?count=${batchSize}?page=${page}`
        );

        result.push(
          ...rewardsPage
            .filter(({ epoch }) => lowerBound <= epoch && epoch <= upperBound)
            .map(({ epoch, amount }) => ({
              epoch: Cardano.EpochNo(epoch),
              rewards: stringToBigInt(amount)
            }))
        );
        haveMorePages = rewardsPage.length === batchSize && rewardsPage[rewardsPage.length - 1].epoch < upperBound;
        page += 1;
      }
      return result;
    } catch (error) {
      throw this.toProviderError(error);
    }
  }
  public async rewardsHistory({ rewardAccounts, epochs }: RewardsHistoryArgs) {
    const allAddressRewards = await Promise.all(rewardAccounts.map((address) => this.accountRewards(address, epochs)));
    return new Map(allAddressRewards.map((epochRewards, i) => [rewardAccounts[i], epochRewards]));
  }
}
