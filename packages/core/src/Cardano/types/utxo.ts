import { TxOut, Address, TxIn as OgmiosTxIn } from '@cardano-ogmios/schema';

export { TxOut, Address } from '@cardano-ogmios/schema';

export interface TxIn extends OgmiosTxIn {
  address: Address;
}

export type Utxo = [TxIn, TxOut];
