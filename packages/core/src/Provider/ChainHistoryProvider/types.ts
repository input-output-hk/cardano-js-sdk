import { Cardano, Provider } from '../..';

export type TransactionsByAddressesArgs = {
  addresses: Cardano.Address[];
  sinceBlock?: Cardano.BlockNo;
};
export type TransactionsByIdsArgs = { ids: Cardano.TransactionId[] };
export type BlocksByIdsArgs = { ids: Cardano.BlockId[] };

export interface ChainHistoryProvider extends Provider {
  /**
   * Gets the transactions involving the provided addresses.
   * It's also possible to provide a block number to only look for transactions since that block inclusive
   *
   * @param {Cardano.Address[]} addresses array of addresses
   * @param {Cardano.BlockNo} [sinceBlock] transactions since which block (inclusive)
   * @returns {Cardano.TxAlonzo[]} an array of transactions involving the addresses
   */
  transactionsByAddresses: (args: TransactionsByAddressesArgs) => Promise<Cardano.TxAlonzo[]>;
  /**
   * Gets the transactions matching the provided hashes.
   *
   * @param {Cardano.TransactionId[]} ids array of transaction ids
   * @returns {Cardano.TxAlonzo[]} an array of transactions
   */
  transactionsByHashes: (args: TransactionsByIdsArgs) => Promise<Cardano.TxAlonzo[]>;
  /**
   * Gets the blocks matching the provided hashes.
   *
   * @param {Cardano.BlockId[]} ids array of block ids
   * @returns {Cardano.Block[]} an array of blocks, same length and in the same order as `hashes` argument.
   */
  blocksByHashes: (args: BlocksByIdsArgs) => Promise<Cardano.Block[]>;
}
