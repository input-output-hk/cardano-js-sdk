import { Address } from './Address';
import { Hash32ByteBase16 } from '../util/primitives';
import { TransactionId } from './Transaction';
import { Value } from './Value';

export interface TxIn {
  txId: TransactionId;
  index: number;
}

export interface HydratedTxIn extends TxIn {
  address: Address;
}

export interface TxOut {
  address: Address;
  value: Value;
  datum?: Hash32ByteBase16;
}

export type Utxo = [HydratedTxIn, TxOut];
