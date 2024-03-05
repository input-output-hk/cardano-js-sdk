import type { Cardano, ChainHistoryProvider } from '@cardano-sdk/core';

export type ChainHistoryInputResolverDependencies = {
  chainHistoryProvider: ChainHistoryProvider;
};

/** Very inefficient input resolver: has to fetch the entire transaction, just to look up one output. */
export class ChainHistoryInputResolver implements Cardano.InputResolver {
  #chainHistoryProvider: ChainHistoryProvider;

  constructor({ chainHistoryProvider }: ChainHistoryInputResolverDependencies) {
    this.#chainHistoryProvider = chainHistoryProvider;
  }

  async resolveInput(txIn: Cardano.TxIn) {
    const [tx] = await this.#chainHistoryProvider.transactionsByHashes({ ids: [txIn.txId] });
    return tx.body.outputs[txIn.index];
  }
}
