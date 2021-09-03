import { CardanoProvider } from '@cardano-sdk/core';
import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { Options } from '@blockfrost/blockfrost-js/lib/types';
import { BlockfrostToOgmios } from './BlockfrostToOgmios';

/**
 * Connect to the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {Options} options BlockFrostAPI options
 * @returns {CardanoProvider} CardanoProvider
 */

export const blockfrostProvider = (options: Options): CardanoProvider => {
  const blockfrost = new BlockFrostAPI(options);

  const submitTx: CardanoProvider['submitTx'] = async (signedTransaction) => {
    try {
      const hash = await blockfrost.txSubmit(signedTransaction);

      return !!hash;
    } catch {
      return false;
    }
  };

  const utxo: CardanoProvider['utxo'] = async (addresses) => {
    const results = await Promise.all(
      addresses.map(async (address) =>
        blockfrost.addressesUtxosAll(address).then((result) => BlockfrostToOgmios.addressUtxoContent(address, result))
      )
    );

    return results.flat(1);
  };

  const queryTransactionsByAddresses: CardanoProvider['queryTransactionsByAddresses'] = async (addresses) => {
    const addressTransactions = await Promise.all(
      addresses.map(async (address) => blockfrost.addressesTransactionsAll(address))
    );

    const transactionsArray = await Promise.all(
      addressTransactions.map((transactionArray) =>
        Promise.all(transactionArray.map(async ({ tx_hash }) => blockfrost.txsUtxos(tx_hash)))
      )
    );

    return transactionsArray.flat(1).map((tx) => BlockfrostToOgmios.txContentUtxo(tx));
  };

  const queryTransactionsByHashes: CardanoProvider['queryTransactionsByHashes'] = async (hashes) => {
    const transactions = await Promise.all(hashes.map(async (hash) => blockfrost.txsUtxos(hash)));

    return transactions.map((tx) => BlockfrostToOgmios.txContentUtxo(tx));
  };

  return {
    submitTx,
    utxo,
    queryTransactionsByAddresses,
    queryTransactionsByHashes
  };
};
