import { Address, Hash16 } from '.';
import { TxIn as OgmiosTxIn } from '@cardano-ogmios/schema';
import { Value } from './Value';

export interface TxIn extends OgmiosTxIn {
  address: Address;
}

export interface TxOut {
  address: Address;
  value: Value;
  datum?: Hash16;
}

export type Utxo = [TxIn, TxOut];
