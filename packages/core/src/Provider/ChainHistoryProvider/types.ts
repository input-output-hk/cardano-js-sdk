import { Cardano, Paginated, PaginationArgs, Provider } from '../..';
import { Range } from '@cardano-sdk/util';

export type TransactionsByAddressesArgs = {
  addresses: Cardano.PaymentAddress[];
  pagination: PaginationArgs;
  blockRange?: Range<Cardano.BlockNo>;
};
export type TransactionsByIdsArgs = { ids: Cardano.TransactionId[] };
export type BlocksByIdsArgs = { ids: Cardano.BlockId[] };

export interface ChainHistoryProvider extends Provider {
  /**
   * Gets the transactions involving the provided addresses.
   * It's also possible to provide a block number to only look for transactions since that block inclusive
   *
   * @param {Cardano.PaymentAddress[]} addresses array of addresses
   * @param {Cardano.PaginationArgs} [pagination] pagination args
   * @param {Range<Cardano.BlockNo>} [blockRange] transactions in specified block ranges (lower and upper bounds inclusive)
   * @returns {Cardano.HydratedTx[]} an array of transactions involving the addresses
   */
  transactionsByAddresses: (
    args: TransactionsByAddressesArgs
  ) => Promise<Paginated<Cardano.HydratedTx<Cardano.HydratedTxBodyPostConway>>>;
  /**
   * Gets the transactions matching the provided hashes.
   *
   * @param {Cardano.TransactionId[]} ids array of transaction ids
   * @returns {Cardano.HydratedTx[]} an array of transactions
   */
  transactionsByHashes: (
    args: TransactionsByIdsArgs
  ) => Promise<Cardano.HydratedTx<Cardano.HydratedTxBodyPostConway>[]>;
  /**
   * Gets the blocks matching the provided hashes.
   *
   * @param {Cardano.BlockId[]} ids array of block ids
   * @returns {Cardano.ExtendedBlockInfo[]} an array of blocks, same length and in the same order as `hashes` argument.
   */
  blocksByHashes: (args: BlocksByIdsArgs) => Promise<Cardano.ExtendedBlockInfo[]>;
}
