import { BlockfrostClient, BlockfrostProvider, BlockfrostToCore, fetchSequentially } from '../blockfrost';
import { Cardano, Serialization, UtxoByAddressesArgs, UtxoProvider } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import type { Cache } from '@cardano-sdk/util';
import type { Responses } from '@blockfrost/blockfrost-js';

type BlockfrostUtxoProviderDependencies = {
  client: BlockfrostClient;
  cache: Cache<Cardano.Tx>;
  logger: Logger;
};

export class BlockfrostUtxoProvider extends BlockfrostProvider implements UtxoProvider {
  private readonly cache: Cache<Cardano.Tx>;

  constructor({ cache, client, logger }: BlockfrostUtxoProviderDependencies) {
    super(client, logger);
    this.cache = cache;
  }

  protected async fetchUtxos(addr: Cardano.PaymentAddress, paginationQueryString: string): Promise<Cardano.Utxo[]> {
    const queryString = `addresses/${addr.toString()}/utxos?${paginationQueryString}`;
    const utxos = await this.request<Responses['address_utxo_content']>(queryString);

    const utxoPromises = utxos.map((utxo) =>
      this.fetchDetailsFromCBOR(utxo.tx_hash).then((tx) => {
        const txOut = tx ? tx.body.outputs.find((output) => output.address === utxo.address) : undefined;
        return BlockfrostToCore.addressUtxoContent(addr.toString(), utxo, txOut);
      })
    );
    return Promise.all(utxoPromises);
  }

  async fetchCBOR(hash: string): Promise<string> {
    return this.request<Responses['tx_content_cbor']>(`txs/${hash}/cbor`)
      .then((response) => {
        if (response.cbor) return response.cbor;
        throw new Error('CBOR is null');
      })
      .catch((_error) => {
        throw new Error('CBOR fetch failed');
      });
  }
  protected async fetchDetailsFromCBOR(hash: string) {
    const cached = await this.cache.get(hash);
    if (cached) return cached;

    const result = await this.fetchCBOR(hash)
      .then((cbor) => {
        const tx = Serialization.Transaction.fromCbor(Serialization.TxCBOR(cbor)).toCore();
        this.logger.debug('Fetched details from CBOR for tx', hash);
        return tx;
      })
      .catch((error) => {
        this.logger.warn('Failed to fetch details from CBOR for tx', hash, error);
        return null;
      });

    if (!result) {
      return null;
    }

    void this.cache.set(hash, result);
    return result;
  }

  public async utxoByAddresses({ addresses }: UtxoByAddressesArgs): Promise<Cardano.Utxo[]> {
    try {
      const utxoResults = await Promise.all(
        addresses.map(async (address) =>
          fetchSequentially<Cardano.Utxo, Cardano.Utxo>({
            request: async (paginationQueryString) => await this.fetchUtxos(address, paginationQueryString)
          })
        )
      );
      return utxoResults.flat(1);
    } catch (error) {
      throw this.toProviderError(error);
    }
  }
}
