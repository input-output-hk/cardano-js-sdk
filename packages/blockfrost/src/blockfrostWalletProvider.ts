import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { BlockfrostToCore } from './BlockfrostToCore';
import { Cardano, EpochRange, EpochRewards, ProviderUtil, WalletProvider } from '@cardano-sdk/core';
import { formatBlockfrostError, toProviderError } from './util';

/**
 * Connect to the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {BlockFrostAPI} blockfrost BlockFrostAPI instance
 * @returns {WalletProvider} WalletProvider
 */
export const blockfrostWalletProvider = (blockfrost: BlockFrostAPI): WalletProvider => {
  const ledgerTip: WalletProvider['ledgerTip'] = async () => {
    const block = await blockfrost.blocksLatest();
    return BlockfrostToCore.blockToTip(block);
  };

  const rewards: WalletProvider['rewardAccountBalance'] = async (rewardAccount: Cardano.RewardAccount) => {
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

  const currentWalletProtocolParameters: WalletProvider['currentWalletProtocolParameters'] = async () => {
    const response = await blockfrost.axiosInstance({
      url: `${blockfrost.apiUrl}/epochs/latest/parameters`
    });

    return BlockfrostToCore.currentWalletProtocolParameters(response.data);
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

  const rewardsHistory: WalletProvider['rewardsHistory'] = async ({ rewardAccounts, epochs }) => {
    const allAddressRewards = await Promise.all(rewardAccounts.map((address) => accountRewards(address, epochs)));
    return new Map(allAddressRewards.map((epochRewards, i) => [rewardAccounts[i], epochRewards]));
  };

  const genesisParameters: WalletProvider['genesisParameters'] = async () => {
    const response = await blockfrost.genesis();
    return {
      activeSlotsCoefficient: response.active_slots_coefficient,
      epochLength: response.epoch_length,
      maxKesEvolutions: response.max_kes_evolutions,
      maxLovelaceSupply: BigInt(response.max_lovelace_supply),
      networkMagic: response.network_magic,
      securityParameter: response.security_param,
      slotLength: response.slot_length,
      slotsPerKesPeriod: response.slots_per_kes_period,
      systemStart: new Date(response.system_start * 1000),
      updateQuorum: response.update_quorum
    };
  };

  const providerFunctions: WalletProvider = {
    currentWalletProtocolParameters,
    genesisParameters,
    ledgerTip,
    rewardAccountBalance: rewards,
    rewardsHistory
  };

  return ProviderUtil.withProviderErrors(providerFunctions, toProviderError);
};
