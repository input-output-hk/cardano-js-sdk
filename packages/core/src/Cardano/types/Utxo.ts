import { Address, Hash32ByteBase16, TransactionId } from '.';
import { Value } from './Value';

export interface TxIn {
  txId: TransactionId;
  index: number;
  address: Address;
}

export interface TxOut {
  address: Address;
  value: Value;
  datum?: Hash32ByteBase16;
}

export type Utxo = [TxIn, TxOut];
