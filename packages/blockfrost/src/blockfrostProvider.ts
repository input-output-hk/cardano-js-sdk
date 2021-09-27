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

  const ledgerTip: CardanoProvider['ledgerTip'] = async () => {
    const block = await blockfrost.blocksLatest();
    return BlockfrostToOgmios.blockToTip(block);
  };

  const networkInfo: CardanoProvider['networkInfo'] = async () => {
    const currentEpoch = await blockfrost.epochsLatest();
    const { stake, supply } = await blockfrost.network();
    return {
      currentEpoch: {
        end: {
          date: new Date(currentEpoch.end_time)
        },
        number: currentEpoch.epoch,
        start: {
          date: new Date(currentEpoch.start_time)
        }
      },
      lovelaceSupply: {
        circulating: BigInt(supply.circulating),
        max: BigInt(supply.max),
        total: BigInt(supply.total)
      },
      stake: {
        active: BigInt(stake.active),
        live: BigInt(stake.live)
      }
    };
  };

  const submitTx: CardanoProvider['submitTx'] = async (signedTransaction) => {
    try {
      const hash = await blockfrost.txSubmit(signedTransaction.to_bytes());

      return !!hash;
    } catch {
      return false;
    }
  };

  const utxoDelegationAndRewards: CardanoProvider['utxoDelegationAndRewards'] = async (addresses, stakeKeyHash) => {
    const utxoResults = await Promise.all(
      addresses.map(async (address) =>
        blockfrost.addressesUtxosAll(address).then((result) => BlockfrostToOgmios.addressUtxoContent(address, result))
      )
    );
    const utxo = utxoResults.flat(1);

    const accountResponse = await blockfrost.accounts(stakeKeyHash);
    const delegationAndRewards = {
      delegate: accountResponse.pool_id,
      rewards: Number(accountResponse.withdrawable_amount)
    };

    return { utxo, delegationAndRewards };
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

  const currentWalletProtocolParameters: CardanoProvider['currentWalletProtocolParameters'] = async () => {
    const response = await blockfrost.axiosInstance({
      url: `${blockfrost.apiUrl}/epochs/latest/parameters`
    });

    return BlockfrostToOgmios.currentWalletProtocolParameters(response.data);
  };

  return {
    ledgerTip,
    networkInfo,
    submitTx,
    utxoDelegationAndRewards,
    queryTransactionsByAddresses,
    queryTransactionsByHashes,
    currentWalletProtocolParameters
  };
};
