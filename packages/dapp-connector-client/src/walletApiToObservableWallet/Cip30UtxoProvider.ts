import {
  Cardano,
  HealthCheckResponse,
  ProviderError,
  ProviderFailure,
  Serialization,
  UtxoProvider
} from '@cardano-sdk/core';
import { Cip30WalletDependencyBase, Cip30WalletDependencyProps } from './Cip30WalletDependencyBase';
import { HexBlob, WithLogger } from '@cardano-sdk/util';

export type Cip30UtxoProviderDependencies = WithLogger & { inputResolver: Cardano.InputResolver };

export class Cip30UtxoProvider extends Cip30WalletDependencyBase implements UtxoProvider {
  readonly #inputResolver: Cardano.InputResolver;

  constructor(props: Cip30WalletDependencyProps, dependencies: Cip30UtxoProviderDependencies) {
    super(props, dependencies);
    this.#inputResolver = dependencies.inputResolver;
  }

  async utxoByAddresses(): Promise<Cardano.Utxo[]> {
    const utxoCbor = await this.api.getUtxos();
    if (!utxoCbor) return [];
    return Promise.all(
      utxoCbor.map(async (cbor) => {
        const [txIn, txOut] = Serialization.TransactionUnspentOutput.fromCbor(HexBlob(cbor)).toCore();
        return [
          await this.#inputResolver.resolveInput(txIn).then((resolved) => {
            if (!resolved) {
              throw new ProviderError(
                ProviderFailure.NotFound,
                undefined,
                `Input could not be resolved: ${txIn.txId} ${txIn.index}`
              );
            }
            return { ...txIn, ...resolved };
          }),
          txOut
        ];
      })
    );
  }

  async healthCheck(): Promise<HealthCheckResponse> {
    return { ok: true };
  }
}
