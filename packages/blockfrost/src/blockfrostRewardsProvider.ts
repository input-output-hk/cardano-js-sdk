import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { Cardano, EpochRange, EpochRewards, ProviderError, ProviderFailure, RewardsProvider } from '@cardano-sdk/core';
import { formatBlockfrostError } from './util';
/**
 * Connect to the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {BlockFrostAPI} blockfrost BlockFrostAPI instance
 * @returns {RewardsProvider} RewardsProvider
 * @throws {Cardano.TxSubmissionErrors.UnknownTxSubmissionError}
 */
export const blockfrostRewardsProvider = (blockfrost: BlockFrostAPI): RewardsProvider => {
  const healthCheck: RewardsProvider['healthCheck'] = async () => {
    try {
      const result = await blockfrost.health();
      return { ok: result.is_healthy };
    } catch (error) {
      throw new ProviderError(ProviderFailure.Unknown, error);
    }
  };

  const rewardAccountBalance: RewardsProvider['rewardAccountBalance'] = async (
    rewardAccount: Cardano.RewardAccount
  ) => {
    try {
      const accountResponse = await blockfrost.accounts(rewardAccount.toString());
      return BigInt(accountResponse.withdrawable_amount);
    } catch (error) {
      if (formatBlockfrostError(error).status_code === 404) {
        return 0n;
      }
      throw error;
    }
  };
  const accountRewards = async (
    stakeAddress: Cardano.RewardAccount,
    { lowerBound = 0, upperBound = Number.MAX_SAFE_INTEGER }: EpochRange = {}
  ): Promise<EpochRewards[]> => {
    const result: EpochRewards[] = [];
    const batchSize = 100;
    let page = 1;
    let haveMorePages = true;
    while (haveMorePages) {
      const rewardsPage = await blockfrost.accountsRewards(stakeAddress.toString(), { count: batchSize, page });
      result.push(
        ...rewardsPage
          .filter(({ epoch }) => lowerBound <= epoch && epoch <= upperBound)
          .map(({ epoch, amount }) => ({
            epoch,
            rewards: BigInt(amount)
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
    healthCheck,
    rewardAccountBalance,
    rewardsHistory
  };
};
