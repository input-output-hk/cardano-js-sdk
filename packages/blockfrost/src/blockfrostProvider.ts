/* eslint-disable @typescript-eslint/no-explicit-any */
import { CardanoProvider, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { BlockFrostAPI, Error as BlockfrostError } from '@blockfrost/blockfrost-js';
import { Options } from '@blockfrost/blockfrost-js/lib/types';
import { BlockfrostToOgmios } from './BlockfrostToOgmios';

const formatBlockfrostError = (error: unknown) => {
  const blockfrostError = error as BlockfrostError;
  if (typeof blockfrostError === 'string') {
    throw new ProviderError(ProviderFailure.Unknown, error, blockfrostError);
  }
  if (typeof blockfrostError !== 'object') {
    throw new ProviderError(ProviderFailure.Unknown, error, 'failed to parse error (response type)');
  }
  const errorAsType1 = blockfrostError as {
    status_code: number;
    message: string;
    error: string;
  };
  if (errorAsType1.status_code) {
    return errorAsType1;
  }
  const errorAsType2 = blockfrostError as {
    errno: number;
    message: string;
    code: string;
  };
  if (errorAsType2.code) {
    const status_code = Number.parseInt(errorAsType2.code);
    if (!status_code) {
      throw new ProviderError(ProviderFailure.Unknown, error, 'failed to parse error (status code)');
    }
    return {
      status_code,
      message: errorAsType1.message,
      error: errorAsType2.errno.toString()
    };
  }
  throw new ProviderError(ProviderFailure.Unknown, error, 'failed to parse error (response json)');
};

const toProviderError = (error: unknown) => {
  const { status_code } = formatBlockfrostError(error);
  if (status_code === 404) {
    throw new ProviderError(ProviderFailure.NotFound);
  }
  throw new ProviderError(ProviderFailure.Unknown, error, `status_code: ${status_code}`);
};

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

  const stakePoolStats: CardanoProvider['stakePoolStats'] = async () => {
    const tallyPools = async (query: 'pools' | 'poolsRetired' | 'poolsRetiring', count = 0, page = 1) => {
      const result = await blockfrost[query]({ page });
      const newCount = count + result.length;
      if (result.length === 100) {
        await tallyPools(query, newCount, page + 1);
      }
      return newCount;
    };
    return {
      qty: {
        active: await tallyPools('pools'),
        retired: await tallyPools('poolsRetired'),
        retiring: await tallyPools('poolsRetiring')
      }
    };
  };

  const submitTx: CardanoProvider['submitTx'] = async (signedTransaction) => {
    await blockfrost.txSubmit(signedTransaction.to_bytes());
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
      delegate: accountResponse.pool_id || undefined,
      rewards: Number(accountResponse.withdrawable_amount)
    };

    return { utxo, delegationAndRewards };
  };

  const queryTransactionsByHashes: CardanoProvider['queryTransactionsByHashes'] = async (hashes) => {
    const transactions = await Promise.all(hashes.map(async (hash) => blockfrost.txsUtxos(hash)));
    return transactions.map((tx) => BlockfrostToOgmios.txContentUtxo(tx));
  };

  const queryTransactionsByAddresses: CardanoProvider['queryTransactionsByAddresses'] = async (addresses) => {
    const addressTransactions = await Promise.all(
      addresses.map(async (address) => blockfrost.addressesTransactionsAll(address))
    );

    const transactionsArray = await Promise.all(
      addressTransactions.map((transactionArray) =>
        queryTransactionsByHashes(transactionArray.map(({ tx_hash }) => tx_hash))
      )
    );

    return transactionsArray.flat(1);
  };

  const currentWalletProtocolParameters: CardanoProvider['currentWalletProtocolParameters'] = async () => {
    const response = await blockfrost.axiosInstance({
      url: `${blockfrost.apiUrl}/epochs/latest/parameters`
    });

    return BlockfrostToOgmios.currentWalletProtocolParameters(response.data);
  };

  const providerFunctions: CardanoProvider = {
    ledgerTip,
    networkInfo,
    stakePoolStats,
    submitTx,
    utxoDelegationAndRewards,
    queryTransactionsByAddresses,
    queryTransactionsByHashes,
    currentWalletProtocolParameters
  };

  return Object.keys(providerFunctions).reduce((provider, key) => {
    provider[key] = (...args: any[]) => (providerFunctions as any)[key](...args).catch(toProviderError);
    return provider;
  }, {} as any) as CardanoProvider;
};
