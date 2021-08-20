import { Schema as Cardano } from '@cardano-ogmios/client';

// Cardano.Tx currently does not have property "hash"
type Tx = { hash: Cardano.Hash16 } & Cardano.Tx;

export interface CardanoProvider {
  submitTx: (signedTransaction: string) => Promise<boolean>;
  utxo: (addresses: Cardano.Address[]) => Promise<Cardano.Utxo>;
  queryTransactionsByAddresses: (addresses: Cardano.Address[]) => Promise<Tx[]>;
  queryTransactionsByHashes: (hashes: Cardano.Hash16[]) => Promise<Tx[]>;
}
