import Schema from '@cardano-ogmios/schema';
import { ImplicitCoin, SelectionConstraints, SelectionResult } from '@cardano-sdk/cip2';
import { Ogmios, CSL } from '@cardano-sdk/core';
import Emittery from 'emittery';

export enum UtxoRepositoryEvent {
  Changed = 'changed',
  OutOfSync = 'out-of-sync'
}

export interface UtxoRepositoryFields {
  allUtxos: Schema.Utxo;
  availableUtxos: Schema.Utxo;
  allRewards: Ogmios.Lovelace | null;
  availableRewards: Ogmios.Lovelace | null;
  delegation: Schema.PoolId | null;
}

export type UtxoRepositoryEvents = {
  changed: UtxoRepositoryFields;
  'out-of-sync': void;
  'transaction-untracked': CSL.Transaction;
};
export type UtxoRepository = {
  sync: () => Promise<void>;
  selectInputs: (
    outputs: Set<CSL.TransactionOutput>,
    constraints: SelectionConstraints,
    implicitCoin?: ImplicitCoin
  ) => Promise<SelectionResult>;
} & UtxoRepositoryFields &
  Emittery<UtxoRepositoryEvents>;

export interface OnTransactionArgs {
  transaction: CSL.Transaction;
  /**
   * Resolves when transaction is confirmed.
   * Rejects if transaction fails to submit or validate.
   */
  confirmed: Promise<void>;
}

export enum TransactionTrackerEvent {
  NewTransaction = 'new-transaction'
}

export type TransactionTrackerEvents = { 'new-transaction': OnTransactionArgs };
export interface TransactionTracker extends Emittery<TransactionTrackerEvents> {
  /**
   * Track a new transaction.
   *
   * @param {CSL.Transaction} transaction transaction to track.
   * @param {Promise<void>} submitted defer checking for transaction confirmation until this resolves.
   */
  track(transaction: CSL.Transaction, submitted?: Promise<void>): Promise<void>;
}
