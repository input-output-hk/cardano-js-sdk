import { BlockfrostProvider } from '../../util/BlockfrostProvider/BlockfrostProvider';
import { BlockfrostToCore, blockfrostToProviderError, fetchByAddressSequentially } from '../../util';
import { Cardano, Serialization, UtxoByAddressesArgs, UtxoProvider } from '@cardano-sdk/core';
import { PaginationOptions } from '@blockfrost/blockfrost-js/lib/types';
import { Responses } from '@blockfrost/blockfrost-js';
import { Schemas } from '@blockfrost/blockfrost-js/lib/types/open-api';

export class BlockfrostUtxoProvider extends BlockfrostProvider implements UtxoProvider {
  protected async fetchUtxos(addr: Cardano.PaymentAddress, pagination: PaginationOptions): Promise<Cardano.Utxo[]> {
    const utxos: Responses['address_utxo_content'] = (await this.blockfrost.addressesUtxos(
      addr.toString(),
      pagination
    )) as Responses['address_utxo_content'];

    const utxoPromises = utxos.map((utxo) =>
      this.fetchDetailsFromCBOR(utxo.tx_hash).then((tx) => {
        const txOut = tx ? tx.body.outputs.find((output) => output.address === utxo.address) : undefined;
        return BlockfrostToCore.addressUtxoContent(addr.toString(), utxo, txOut);
      })
    );
    return Promise.all(utxoPromises);
  }

  async fetchCBOR(hash: string): Promise<string> {
    return this.blockfrost
      .instance<Schemas['script_cbor']>(`txs/${hash}/cbor`)
      .then((response) => {
        if (response.body.cbor) return response.body.cbor;
        throw new Error('CBOR is null');
      })
      .catch((_error) => {
        throw new Error('CBOR fetch failed');
      });
  }
  protected async fetchDetailsFromCBOR(hash: string) {
    return this.fetchCBOR(hash)
      .then((cbor) => {
        const tx = Serialization.Transaction.fromCbor(Serialization.TxCBOR(cbor)).toCore();
        this.logger.info('Fetched details from CBOR for tx', hash);
        return tx;
      })
      .catch((error) => {
        this.logger.warn('Failed to fetch details from CBOR for tx', hash, error);
        return null;
      });
  }
  public async utxoByAddresses({ addresses }: UtxoByAddressesArgs): Promise<Cardano.Utxo[]> {
    try {
      const utxoResults = await Promise.all(
        addresses.map(async (address) =>
          fetchByAddressSequentially<Cardano.Utxo, Cardano.Utxo>({
            address,
            request: async (addr: Cardano.PaymentAddress, pagination) => await this.fetchUtxos(addr, pagination)
          })
        )
      );
      return utxoResults.flat(1);
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }
}
