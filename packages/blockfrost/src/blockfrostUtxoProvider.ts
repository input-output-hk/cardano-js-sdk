import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { BlockfrostToCore, BlockfrostUtxo } from './BlockfrostToCore';
import { Cardano, UtxoProvider } from '@cardano-sdk/core';
import { fetchByAddressSequentially, healthCheck } from './util';

/**
 * Connect to the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {BlockFrostAPI} blockfrost BlockFrostAPI instance
 * @returns {UtxoProvider} UtxoProvider
 */
export const blockfrostUtxoProvider = (blockfrost: BlockFrostAPI): UtxoProvider => {
  const utxoByAddresses: UtxoProvider['utxoByAddresses'] = async ({ addresses }) => {
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
    healthCheck: healthCheck.bind(undefined, blockfrost),
    utxoByAddresses
  };
};
