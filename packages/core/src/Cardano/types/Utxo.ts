import { Address, Hash16, TransactionId } from '.';
import { Value } from './Value';

export interface TxIn {
  txId: TransactionId;
  index: number;
  address: Address;
}

export interface TxOut {
  address: Address;
  value: Value;
  datum?: Hash16; // TODO: Review: need to find an example of this to verify type and length
}

export type Utxo = [TxIn, TxOut];
