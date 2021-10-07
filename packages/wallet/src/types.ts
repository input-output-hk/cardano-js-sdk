import Schema from '@cardano-ogmios/schema';
import { ImplicitCoin, SelectionConstraints, SelectionResult } from '@cardano-sdk/cip2';
import { CSL, Transaction } from '@cardano-sdk/core';
import { Withdrawal } from './Delegation';

export interface UtxoRepository {
  allUtxos: Schema.Utxo;
  rewards: Schema.Lovelace | null;
  delegation: Schema.PoolId | null;
  sync: () => Promise<void>;
  selectInputs: (
    outputs: Set<CSL.TransactionOutput>,
    constraints: SelectionConstraints,
    implicitCoin?: ImplicitCoin
  ) => Promise<SelectionResult>;
}

export type InitializeTxProps = {
  outputs: Set<Schema.TxOut>;
  certificates?: CSL.Certificate[];
  withdrawals?: Withdrawal[];
  options?: {
    validityInterval?: Transaction.ValidityInterval;
  };
};
