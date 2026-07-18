import { BigIntMath } from '@cardano-sdk/util';
import { coalesceTokenMaps } from '../Asset/util';
import type { Credential, InputResolver, RewardAccount } from '../Cardano/Address';
import type { Inspector } from './txInspector';
import type { Lovelace, TransactionId, Tx } from '../Cardano/types';

const nonEmpty = <T>(items: T[]): T[] | undefined => (items.length > 0 ? items : undefined);

/**
 * Creates an InputResolver that resolves inputs against the outputs produced within the given
 * transaction's own batch (CIP-0118): the top level outputs and the outputs of every sub
 * transaction that carries an id (hydrated sub transactions do; serialization-side ones do not
 * and are skipped). Inputs produced outside the batch are delegated to fallbackResolver, or
 * resolve to null without one.
 */
export const createBatchInputResolver = (tx: Tx, fallbackResolver?: InputResolver): InputResolver => {
  const producers = [
    { id: tx.id as TransactionId | undefined, outputs: tx.body.outputs },
    ...(tx.body.subTransactions ?? []).map((subTx) => ({
      id: (subTx as { id?: TransactionId }).id,
      outputs: subTx.body.outputs
    }))
  ];

  return {
    resolveInput: async (txIn, options) => {
      const producer = producers.find(({ id }) => id !== undefined && id === txIn.txId);
      if (producer) return producer.outputs[txIn.index] ?? null;
      return fallbackResolver ? fallbackResolver.resolveInput(txIn, options) : null;
    }
  };
};

/**
 * Merges a CIP-0118 batch into a single flat transaction view for value arithmetic: inputs,
 * outputs, mint, certificates, withdrawals and direct deposits are concatenated across the top
 * level and every sub transaction, witness scripts are pooled, and subTransactions is cleared.
 * Intra-batch spends cancel naturally because both their producing output and their consuming
 * input remain in the view.
 *
 * All other fields (fee, validity interval, guards, governance procedures, auxiliary data) stay
 * as the top level transaction defined them. The view keeps the id of the top level transaction
 * and is meant for inspection only - it does not re-serialize to a valid transaction.
 *
 * Returns the input unchanged when the transaction carries no sub transactions. The cast to the
 * input type is sound because merging only combines arrays of the input's own hydration level.
 */
export const toMergedBatchView = <T extends Tx>(tx: T): T => {
  const subTransactions = tx.body.subTransactions;
  if (!subTransactions || subTransactions.length === 0) return tx;

  const bodies = [tx.body, ...subTransactions.map(({ body }) => body)];
  const scripts = [...(tx.witness.scripts ?? []), ...subTransactions.flatMap(({ witness }) => witness.scripts ?? [])];

  return {
    ...tx,
    body: {
      ...tx.body,
      certificates: nonEmpty(bodies.flatMap(({ certificates }) => certificates ?? [])),
      directDeposits: nonEmpty(bodies.flatMap(({ directDeposits }) => directDeposits ?? [])),
      inputs: bodies.flatMap(({ inputs }) => inputs),
      mint: coalesceTokenMaps(bodies.map(({ mint }) => mint)),
      outputs: bodies.flatMap(({ outputs }) => outputs),
      subTransactions: undefined,
      withdrawals: nonEmpty(bodies.flatMap(({ withdrawals }) => withdrawals ?? []))
    },
    witness: { ...tx.witness, scripts: nonEmpty(scripts) }
  } as T;
};

/**
 * Inspects a transaction for direct deposits (Dijkstra body key 25) and returns their total.
 * When reward accounts are given only deposits into those accounts are counted; otherwise all
 * direct deposits of the transaction are.
 */
export const directDepositsInspector =
  (rewardAccounts?: RewardAccount[]): Inspector<Lovelace> =>
  async (tx) =>
    BigIntMath.sum(
      (tx.body.directDeposits ?? [])
        .filter(({ stakeAddress }) => !rewardAccounts || rewardAccounts.includes(stakeAddress))
        .map(({ quantity }) => quantity)
    );

/** Inspects a transaction for its guard credentials (Dijkstra body key 14). */
export const guardsInspector: Inspector<Credential[]> = async (tx) => tx.body.guards ?? [];
