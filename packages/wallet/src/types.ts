import Schema from '@cardano-ogmios/schema';
import { ImplicitCoin, SelectionConstraints, SelectionResult } from '@cardano-sdk/cip2';
import { CSL } from '@cardano-sdk/core';
import Emittery from 'emittery';

export type UtxoRepositoryEvents = { transactionUntracked: CSL.Transaction };
export interface UtxoRepository extends Emittery<UtxoRepositoryEvents> {
  allUtxos: Schema.Utxo;
  availableUtxos: Schema.Utxo;
  rewards: Schema.Lovelace | null;
  delegation: Schema.PoolId | null;
  sync: () => Promise<void>;
  selectInputs: (
    outputs: Set<CSL.TransactionOutput>,
    constraints: SelectionConstraints,
    implicitCoin?: ImplicitCoin
  ) => Promise<SelectionResult>;
}

export interface OnTransactionArgs {
  transaction: CSL.Transaction;
  /**
   * Resolves when transaction is confirmed.
   * Rejects if transaction fails to submit or validate.
   */
  confirmed: Promise<void>;
}
export type TransactionTrackerEvents = { transaction: OnTransactionArgs };
export interface TransactionTracker extends Emittery<TransactionTrackerEvents> {
  /**
   * Track a new transaction
   */
  trackTransaction(transaction: CSL.Transaction, submitted?: Promise<void>): Promise<void>;
}
