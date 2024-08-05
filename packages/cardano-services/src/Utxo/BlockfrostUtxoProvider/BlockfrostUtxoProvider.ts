import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { BlockfrostToCore, BlockfrostUtxo, fetchByAddressSequentially, healthCheck } from '../../util';
import { Cardano, UtxoProvider } from '@cardano-sdk/core';

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
          request: (addr: Cardano.PaymentAddress, pagination) => blockfrost.addressesUtxos(addr.toString(), pagination),
          responseTranslator: (addr: Cardano.PaymentAddress, response: Responses['address_utxo_content']) =>
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
