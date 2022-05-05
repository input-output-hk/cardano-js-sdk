import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { BlockfrostToCore, BlockfrostUtxo } from './BlockfrostToCore';
import { Cardano, ProviderError, ProviderFailure, UtxoProvider } from '@cardano-sdk/core';
import { fetchByAddressSequentially } from './util';

/**
 * Connect to the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {BlockFrostAPI} blockfrost BlockFrostAPI instance
 * @returns {UtxoProvider} UtxoProvider
 * @throws {ProviderError}
 */
export const blockfrostUtxoProvider = (blockfrost: BlockFrostAPI): UtxoProvider => {
  const healthCheck: UtxoProvider['healthCheck'] = async () => {
    try {
      const result = await blockfrost.health();
      return { ok: result.is_healthy };
    } catch (error) {
      throw new ProviderError(ProviderFailure.Unknown, error);
    }
  };

  const utxoByAddresses: UtxoProvider['utxoByAddresses'] = async (addresses) => {
    const utxoResults = await Promise.all(
      addresses.map(async (address) =>
        fetchByAddressSequentially<Cardano.Utxo, BlockfrostUtxo>({
          address,
          request: (addr: Cardano.Address, pagination) => blockfrost.addressesUtxos(addr.toString(), pagination),
          responseTranslator: (addr: Cardano.Address, response: Responses['address_utxo_content']) =>
            BlockfrostToCore.addressUtxoContent(addr.toString(), response)
        })
      )
    );
    return utxoResults.flat(1);
  };

  return {
    healthCheck,
    utxoByAddresses
  };
};
