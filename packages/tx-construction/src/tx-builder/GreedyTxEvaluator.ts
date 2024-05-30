import { Cardano } from '@cardano-sdk/core';
import { TxEvaluationResult, TxEvaluator } from './types';

/*
 * This evaluator assigns the maximum execution units per transaction to each redeemer.
 */
export class GreedyTxEvaluator implements TxEvaluator {
  #params: Promise<Cardano.ProtocolParameters>;

  /**
   * Creates an instance of GreedyTxEvaluator.
   *
   * @param getProtocolParams - A callback that resolves to the Cardano protocol parameters.
   */
  constructor(getProtocolParams: () => Promise<Cardano.ProtocolParameters>) {
    this.#params = getProtocolParams();
  }

  /**
   * Evaluates a transaction and assigns the maximum execution units per transaction to each redeemer.
   *
   * @param tx - The transaction to be evaluated.
   * @param _ - The list of UTXOs (not used in this implementation).
   * @returns A promise that resolves to the transaction evaluation result.
   */
  async evaluate(tx: Cardano.Tx, _: Array<Cardano.Utxo>): Promise<TxEvaluationResult> {
    const { maxExecutionUnitsPerTransaction } = await this.#params;
    const { witness } = tx;

    if (!witness || !witness.redeemers) return [];

    const result: TxEvaluationResult = [];

    for (const redeemer of witness.redeemers) {
      result.push({
        budget: maxExecutionUnitsPerTransaction,
        index: redeemer.index,
        purpose: redeemer.purpose
      });
    }

    return result;
  }
}
