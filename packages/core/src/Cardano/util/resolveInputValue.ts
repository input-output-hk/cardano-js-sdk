import type { HydratedTx, HydratedTxIn, Value } from '../types/index.js';

/**
 * Resolves the value of an input by looking for the matching output in a list of transactions
 *
 * @param {HydratedTxIn} input input to resolve value for
 * @param {HydratedTx[]} transactions list of transactions to find the matching output
 * @returns {Value | undefined} input value or undefined if not found
 */
export const resolveInputValue = (input: HydratedTxIn, transactions: HydratedTx[]): Value | undefined => {
  const tx = transactions.find((transaction) => transaction.id === input.txId);
  return tx?.body.outputs[input.index]?.value;
};
