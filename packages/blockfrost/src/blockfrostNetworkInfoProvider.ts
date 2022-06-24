import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { BlockfrostToCore } from './BlockfrostToCore';
import { Cardano, NetworkInfoProvider, ProviderError, ProviderFailure, testnetTimeSettings } from '@cardano-sdk/core';

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
  const networkInfo: NetworkInfoProvider['networkInfo'] = async () => {
    const { stake, supply } = await blockfrost.network();
    return {
      lovelaceSupply: {
        circulating: BigInt(supply.circulating),
        max: BigInt(supply.max),
        total: BigInt(supply.total)
      },
      network: {
        id: Cardano.NetworkId.testnet,
        magic: 1_097_911_063,
        timeSettings: testnetTimeSettings
      },
      stake: {
        active: BigInt(stake.active),
        live: BigInt(stake.live)
      }
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
      networkMagic: response.network_magic,
      securityParameter: response.security_param,
      slotLength: response.slot_length,
      slotsPerKesPeriod: response.slots_per_kes_period,
      systemStart: new Date(response.system_start * 1000),
      updateQuorum: response.update_quorum
    };
  };

  return { currentWalletProtocolParameters, genesisParameters, ledgerTip, networkInfo };
};
