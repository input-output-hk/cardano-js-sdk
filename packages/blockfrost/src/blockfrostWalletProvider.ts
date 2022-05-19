import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { BlockfrostToCore } from './BlockfrostToCore';
import { ProviderUtil, WalletProvider } from '@cardano-sdk/core';
import { toProviderError } from './util';

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

  const currentWalletProtocolParameters: WalletProvider['currentWalletProtocolParameters'] = async () => {
    const response = await blockfrost.axiosInstance({
      url: `${blockfrost.apiUrl}/epochs/latest/parameters`
    });

    return BlockfrostToCore.currentWalletProtocolParameters(response.data);
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
    ledgerTip
  };

  return ProviderUtil.withProviderErrors(providerFunctions, toProviderError);
};
