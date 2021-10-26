import { Address, TxIn as OgmiosTxIn } from '@cardano-ogmios/schema';
import { Value } from './Value';
import { Hash16 } from './misc';

export { Address } from '@cardano-ogmios/schema';

export interface TxIn extends OgmiosTxIn {
  address: Address;
}

export interface TxOut {
  address: Address;
  value: Value;
  datum?: Hash16;
}

export type Utxo = [TxIn, TxOut];
