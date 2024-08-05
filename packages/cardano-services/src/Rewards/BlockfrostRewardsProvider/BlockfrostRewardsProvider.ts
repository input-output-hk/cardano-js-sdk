import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { Cardano, Reward, RewardAccountBalanceArgs, RewardsProvider } from '@cardano-sdk/core';

import { Range } from '@cardano-sdk/util';
import { healthCheck, isBlockfrostNotFoundError } from '../../util';

const stringToBigInt = (str: string) => BigInt(str);

/**
 * Connect to the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {BlockFrostAPI} blockfrost BlockFrostAPI instance
 * @returns {RewardsProvider} RewardsProvider
 * @throws {Cardano.TxSubmissionErrors.UnknownTxSubmissionError}
 */
export const blockfrostRewardsProvider = (blockfrost: BlockFrostAPI): RewardsProvider => {
  const rewardAccountBalance: RewardsProvider['rewardAccountBalance'] = async ({
    rewardAccount
  }: RewardAccountBalanceArgs) => {
    try {
      const accountResponse = await blockfrost.accounts(rewardAccount.toString());
      return BigInt(accountResponse.withdrawable_amount);
    } catch (error) {
      if (isBlockfrostNotFoundError(error)) {
        return 0n;
      }
      throw error;
    }
  };
  const accountRewards = async (
    stakeAddress: Cardano.RewardAccount,
    {
      lowerBound = Cardano.EpochNo(0),
      upperBound = Cardano.EpochNo(Number.MAX_SAFE_INTEGER)
    }: Range<Cardano.EpochNo> = {}
  ): Promise<Reward[]> => {
    const result: Reward[] = [];
    const batchSize = 100;
    let page = 1;
    let haveMorePages = true;
    while (haveMorePages) {
      const rewardsPage = await blockfrost.accountsRewards(stakeAddress.toString(), { count: batchSize, page });

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
  };
  const rewardsHistory: RewardsProvider['rewardsHistory'] = async ({ rewardAccounts, epochs }) => {
    const allAddressRewards = await Promise.all(rewardAccounts.map((address) => accountRewards(address, epochs)));
    return new Map(allAddressRewards.map((epochRewards, i) => [rewardAccounts[i], epochRewards]));
  };

  return {
    healthCheck: healthCheck.bind(undefined, blockfrost),
    rewardAccountBalance,
    rewardsHistory
  };
};
