import { Address, Hash32ByteBase16, TransactionId } from '.';
import { Value } from './Value';

export interface TxIn {
  txId: TransactionId;
  index: number;
  /**
   * Might or might not be present based on source.
   * Not present in serialized tx.
   */
  address?: Address;
}

export interface TxOut {
  address: Address;
  value: Value;
  datum?: Hash32ByteBase16;
}

export type Utxo = [TxIn, TxOut];
