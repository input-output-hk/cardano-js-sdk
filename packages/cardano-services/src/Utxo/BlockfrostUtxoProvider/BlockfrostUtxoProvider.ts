import { BlockfrostProvider } from '../../util/BlockfrostProvider/BlockfrostProvider';
import { BlockfrostToCore, BlockfrostUtxo, blockfrostToProviderError, fetchByAddressSequentially } from '../../util';
import { Cardano, UtxoByAddressesArgs, UtxoProvider } from '@cardano-sdk/core';
import { Responses } from '@blockfrost/blockfrost-js';

export class BlockfrostUtxoProvider extends BlockfrostProvider implements UtxoProvider {
  public async utxoByAddresses({ addresses }: UtxoByAddressesArgs): Promise<Cardano.Utxo[]> {
    try {
      const utxoResults = await Promise.all(
        addresses.map(async (address) =>
          fetchByAddressSequentially<Cardano.Utxo, BlockfrostUtxo>({
            address,
            request: (addr: Cardano.PaymentAddress, pagination) =>
              this.blockfrost.addressesUtxos(addr.toString(), pagination),
            responseTranslator: (addr: Cardano.PaymentAddress, response: Responses['address_utxo_content']) =>
              BlockfrostToCore.addressUtxoContent(addr.toString(), response)
          })
        )
      );
      return utxoResults.flat(1);
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }
}
