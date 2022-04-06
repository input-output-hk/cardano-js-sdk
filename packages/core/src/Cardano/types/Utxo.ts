import { Address, Hash32ByteBase16, TransactionId } from '.';
import { Value } from './Value';

export interface NewTxIn {
  txId: TransactionId;
  index: number;
}

export interface TxIn extends NewTxIn {
  address: Address;
}

export interface TxOut {
  address: Address;
  value: Value;
  datum?: Hash32ByteBase16;
}

export type Utxo = [TxIn, TxOut];
