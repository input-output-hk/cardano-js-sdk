import { Address } from './Address';
import { Hash32ByteBase16 } from '../util/primitives';
import { TransactionId } from './Transaction';
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
