import Cardano from '@cardano-ogmios/schema';
import { Tx } from '../Transaction';

export interface CardanoProvider {
  /** @param signedTransaction signed and serialized cbor */
  submitTx: (signedTransaction: string) => Promise<boolean>;
  utxoDelegationAndRewards: (
    addresses: Cardano.Address[],
    stakeKeyHash: Cardano.Hash16
  ) => Promise<{ utxo: Cardano.Utxo; delegationAndRewards: Cardano.DelegationsAndRewards }>;
  queryTransactionsByAddresses: (addresses: Cardano.Address[]) => Promise<Tx[]>;
  queryTransactionsByHashes: (hashes: Cardano.Hash16[]) => Promise<Tx[]>;
}
