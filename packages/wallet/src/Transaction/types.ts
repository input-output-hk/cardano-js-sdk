import { Transaction, CSL, Cardano } from '@cardano-sdk/core';
import { Withdrawal } from './withdrawal';

export type InitializeTxProps = {
  outputs: Set<Cardano.TxOut>;
  certificates?: CSL.Certificate[];
  withdrawals?: Withdrawal[];
  options?: {
    validityInterval?: Transaction.ValidityInterval;
  };
};
