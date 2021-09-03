import Cardano from '@cardano-ogmios/schema';
import { Tx } from '../Transaction';

export interface CardanoProvider {
  /** @param signedTransaction signed and serialized cbor */
  submitTx: (signedTransaction: string) => Promise<boolean>;
  utxo: (addresses: Cardano.Address[]) => Promise<Cardano.Utxo>;
  queryTransactionsByAddresses: (addresses: Cardano.Address[]) => Promise<Tx[]>;
  queryTransactionsByHashes: (hashes: Cardano.Hash16[]) => Promise<Tx[]>;
}
