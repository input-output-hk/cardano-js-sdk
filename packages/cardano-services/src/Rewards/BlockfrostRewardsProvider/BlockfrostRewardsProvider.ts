import { Cardano, Reward, RewardAccountBalanceArgs, RewardsHistoryArgs, RewardsProvider } from '@cardano-sdk/core';

import { BlockfrostProvider } from '../../util/BlockfrostProvider/BlockfrostProvider';
import { Range } from '@cardano-sdk/util';
import { blockfrostToProviderError, isBlockfrostNotFoundError } from '../../util';

const stringToBigInt = (str: string) => BigInt(str);

export class BlockfrostRewardsProvider extends BlockfrostProvider implements RewardsProvider {
  public async rewardAccountBalance({ rewardAccount }: RewardAccountBalanceArgs) {
    try {
      const accountResponse = await this.blockfrost.accounts(rewardAccount.toString());
      return BigInt(accountResponse.withdrawable_amount);
    } catch (error) {
      if (isBlockfrostNotFoundError(error)) {
        return 0n;
      }
      throw blockfrostToProviderError(error);
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
        const rewardsPage = await this.blockfrost.accountsRewards(stakeAddress.toString(), { count: batchSize, page });

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
      throw blockfrostToProviderError(error);
    }
  }
  public async rewardsHistory({ rewardAccounts, epochs }: RewardsHistoryArgs) {
    const allAddressRewards = await Promise.all(rewardAccounts.map((address) => this.accountRewards(address, epochs)));
    return new Map(allAddressRewards.map((epochRewards, i) => [rewardAccounts[i], epochRewards]));
  }
}
