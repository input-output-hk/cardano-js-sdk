import type { TxIn, Utxo } from '../Cardano';

export const createUtxoId = (txHash: string, index: number) => `${txHash}:${index}`;

/**
 * Sorts the given TxIn set first by txId and then by index.
 *
 * @param lhs The left-hand side of the comparison operation.
 * @param rhs The right-hand side of the comparison operation.
 */
export const sortTxIn = (lhs: TxIn, rhs: TxIn) => {
  const txIdComparison = lhs.txId.localeCompare(rhs.txId);
  if (txIdComparison !== 0) return txIdComparison;

  return lhs.index - rhs.index;
};

/**
 * Sorts the given Utxo set first by TxIn.
 *
 * @param lhs The left-hand side of the comparison operation.
 * @param rhs The right-hand side of the comparison operation.
 */
export const sortUtxoByTxIn = (lhs: Utxo, rhs: Utxo) => sortTxIn(lhs[0], rhs[0]);
