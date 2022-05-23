import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
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

  return { networkInfo };
};
