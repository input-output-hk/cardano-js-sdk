import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { BlockfrostToCore } from './BlockfrostToCore';
import { NetworkInfoProvider, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { eraSummaries, healthCheck, networkMagicToIdMap } from './util';

/**
 * Connect to the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {BlockFrostAPI} blockfrost BlockFrostAPI instance
 * @returns {NetworkInfoProvider} NetworkInfoProvider
 * @throws {ProviderError}
 */
export const blockfrostNetworkInfoProvider = (blockfrost: BlockFrostAPI): NetworkInfoProvider => {
  if (!blockfrost.apiUrl.includes('testnet')) {
    throw new ProviderError(ProviderFailure.NotImplemented);
  }

  const stake: NetworkInfoProvider['stake'] = async () => {
    const network = await blockfrost.network();
    return {
      active: BigInt(network.stake.active),
      live: BigInt(network.stake.live)
    };
  };

  const lovelaceSupply: NetworkInfoProvider['lovelaceSupply'] = async () => {
    const { supply } = await blockfrost.network();
    return {
      circulating: BigInt(supply.circulating),
      total: BigInt(supply.total)
    };
  };

  const ledgerTip: NetworkInfoProvider['ledgerTip'] = async () => {
    const block = await blockfrost.blocksLatest();
    return BlockfrostToCore.blockToTip(block);
  };

  const currentWalletProtocolParameters: NetworkInfoProvider['currentWalletProtocolParameters'] = async () => {
    const response = await blockfrost.axiosInstance({
      url: `${blockfrost.apiUrl}/epochs/latest/parameters`
    });

    return BlockfrostToCore.currentWalletProtocolParameters(response.data);
  };

  const genesisParameters: NetworkInfoProvider['genesisParameters'] = async () => {
    const response = await blockfrost.genesis();
    return {
      activeSlotsCoefficient: response.active_slots_coefficient,
      epochLength: response.epoch_length,
      maxKesEvolutions: response.max_kes_evolutions,
      maxLovelaceSupply: BigInt(response.max_lovelace_supply),
      networkId: networkMagicToIdMap[response.network_magic],
      networkMagic: response.network_magic,
      securityParameter: response.security_param,
      slotLength: response.slot_length,
      slotsPerKesPeriod: response.slots_per_kes_period,
      systemStart: new Date(response.system_start * 1000),
      updateQuorum: response.update_quorum
    };
  };

  return {
    currentWalletProtocolParameters,
    eraSummaries,
    genesisParameters,
    healthCheck: healthCheck.bind(undefined, blockfrost),
    ledgerTip,
    lovelaceSupply,
    stake
  };
};
