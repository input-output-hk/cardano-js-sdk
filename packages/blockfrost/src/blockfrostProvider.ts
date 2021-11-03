/* eslint-disable @typescript-eslint/no-explicit-any */
import { BlockFrostAPI, Error as BlockfrostError, Responses } from '@blockfrost/blockfrost-js';
import { BlockfrostToCore } from './BlockfrostToCore';
import { Cardano, ProviderError, ProviderFailure, WalletProvider } from '@cardano-sdk/core';
import { Options } from '@blockfrost/blockfrost-js/lib/types';
import { dummyLogger } from 'ts-log';

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
      error: errorAsType2.errno.toString(),
      message: errorAsType1.message,
      status_code
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
 * @returns {WalletProvider} WalletProvider
 */
export const blockfrostProvider = (options: Options, logger = dummyLogger): WalletProvider => {
  const blockfrost = new BlockFrostAPI(options);

  const ledgerTip: WalletProvider['ledgerTip'] = async () => {
    const block = await blockfrost.blocksLatest();
    return BlockfrostToCore.blockToTip(block);
  };

  const networkInfo: WalletProvider['networkInfo'] = async () => {
    const currentEpoch = await blockfrost.epochsLatest();
    const { stake, supply } = await blockfrost.network();
    return {
      currentEpoch: {
        end: {
          date: new Date(currentEpoch.end_time * 1000)
        },
        number: currentEpoch.epoch,
        start: {
          date: new Date(currentEpoch.start_time * 1000)
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

  const stakePoolStats: WalletProvider['stakePoolStats'] = async () => {
    const tallyPools = async (
      query: 'pools' | 'poolsRetired' | 'poolsRetiring',
      count = 0,
      page = 1
    ): Promise<number> => {
      const result = await blockfrost[query]({ page });
      const newCount = count + result.length;
      if (result.length === 100) {
        return tallyPools(query, newCount, page + 1);
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

  const submitTx: WalletProvider['submitTx'] = async (signedTransaction) => {
    await blockfrost.txSubmit(signedTransaction);
  };

  const utxoDelegationAndRewards: WalletProvider['utxoDelegationAndRewards'] = async (addresses, stakeKeyHash) => {
    const utxoResults = await Promise.all(
      addresses.map(async (address) =>
        blockfrost.addressesUtxosAll(address).then((result) => BlockfrostToCore.addressUtxoContent(address, result))
      )
    );
    const utxo = utxoResults.flat(1);

    const accountResponse = await blockfrost.accounts(stakeKeyHash);
    const delegationAndRewards = {
      delegate: accountResponse.pool_id || undefined,
      rewards: BigInt(accountResponse.withdrawable_amount)
    };

    return { delegationAndRewards, utxo };
  };

  const fetchRedeemers = async ({
    redeemer_count,
    hash
  }: Responses['tx_content']): Promise<Cardano.Redeemer[] | undefined> => {
    if (!redeemer_count) return;
    const response = await blockfrost.txsRedeemers(hash);
    return response.map(
      ({ purpose, script_hash, unit_mem, unit_steps, tx_index }): Cardano.Redeemer => ({
        executionUnits: {
          memory: Number.parseInt(unit_mem),
          steps: Number.parseInt(unit_steps)
        },
        index: tx_index,
        purpose: ((): Cardano.Redeemer['purpose'] => {
          switch (purpose) {
            case 'cert':
              return 'certificate';
            case 'reward':
              return 'withdrawal';
            default:
              return purpose;
          }
        })(),
        // TODO: need to confirm that this is correct encoding
        scriptHash: Buffer.from(script_hash, 'hex').toString('base64')
      })
    );
  };

  const fetchWithdrawals = async ({
    withdrawal_count,
    hash
  }: Responses['tx_content']): Promise<Cardano.Withdrawal[] | undefined> => {
    if (!withdrawal_count) return;
    const response = await blockfrost.txsWithdrawals(hash);
    return response.map(
      ({ address, amount }): Cardano.Withdrawal => ({
        quantity: BigInt(amount),
        stakeAddress: address
      })
    );
  };

  const fetchMint = async ({
    asset_mint_or_burn_count,
    hash
  }: Responses['tx_content']): Promise<Cardano.TokenMap | undefined> => {
    if (!asset_mint_or_burn_count) return;
    logger.warn(`Skipped fetching asset mint/burn for tx "${hash}": not implemented for Blockfrost provider`);
  };

  const fetchPoolRetireCerts = async (hash: string): Promise<Cardano.PoolRetirementCertificate[]> => {
    const response = await blockfrost.txsPoolRetires(hash);
    return response.map(({ pool_id, retiring_epoch }) => ({
      __typename: Cardano.CertificateType.PoolRetirement,
      epoch: retiring_epoch,
      poolId: pool_id
    }));
  };

  const fetchPoolUpdateCerts = async (hash: string): Promise<Cardano.PoolRegistrationCertificate[]> => {
    const response = await blockfrost.txsPoolUpdates(hash);
    return response.map(({ pool_id, active_epoch }) => ({
      __typename: Cardano.CertificateType.PoolRegistration,
      epoch: active_epoch,
      poolId: pool_id,
      poolParameters: ((): Cardano.PoolParameters => {
        logger.warn('Omitting poolParameters for certificate in tx', hash);
        return null as unknown as Cardano.PoolParameters;
      })()
    }));
  };

  const fetchMirCerts = async (hash: string): Promise<Cardano.MirCertificate[]> => {
    const response = await blockfrost.txsMirs(hash);
    return response.map(({ address, amount, cert_index, pot }) => ({
      __typename: Cardano.CertificateType.MIR,
      address,
      certIndex: cert_index,
      pot,
      quantity: BigInt(amount)
    }));
  };

  const fetchStakeCerts = async (hash: string): Promise<Cardano.StakeAddressCertificate[]> => {
    const response = await blockfrost.txsStakes(hash);
    return response.map(({ address, cert_index, registration }) => ({
      __typename: registration
        ? Cardano.CertificateType.StakeRegistration
        : Cardano.CertificateType.StakeDeregistration,
      address,
      certIndex: cert_index
    }));
  };

  const fetchDelegationCerts = async (hash: string): Promise<Cardano.StakeDelegationCertificate[]> => {
    const response = await blockfrost.txsDelegations(hash);
    return response.map(({ cert_index, index, address, active_epoch, pool_id }) => ({
      __typename: Cardano.CertificateType.StakeDelegation,
      address,
      certIndex: cert_index,
      delegationIndex: index,
      epoch: active_epoch,
      poolId: pool_id
    }));
  };

  const fetchCertificates = async ({
    pool_retire_count,
    pool_update_count,
    mir_cert_count,
    stake_cert_count,
    delegation_count,
    hash
  }: Responses['tx_content']): Promise<Cardano.Certificate[] | undefined> => {
    if (pool_retire_count + pool_update_count + mir_cert_count + stake_cert_count + delegation_count === 0) return;
    return [
      ...(pool_update_count ? await fetchPoolRetireCerts(hash) : []),
      ...(pool_update_count ? await fetchPoolUpdateCerts(hash) : []),
      ...(mir_cert_count ? await fetchMirCerts(hash) : []),
      ...(stake_cert_count ? await fetchStakeCerts(hash) : []),
      ...(delegation_count ? await fetchDelegationCerts(hash) : [])
    ];
  };

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const parseValidityInterval = (num: string | null) => Number.parseInt(num || '') || undefined;
  const fetchTransaction = async (hash: string): Promise<Cardano.TxAlonzo> => {
    const { inputs, outputs } = BlockfrostToCore.transactionUtxos(await blockfrost.txsUtxos(hash));
    const response = await blockfrost.txs(hash);
    return {
      blockHeader: {
        blockHash: response.block,
        blockHeight: response.block_height,
        slot: response.slot
      },
      body: {
        certificates: await fetchCertificates(response),
        fee: BigInt(response.fees),
        inputs,
        mint: await fetchMint(response),
        outputs,
        validityInterval: {
          invalidBefore: parseValidityInterval(response.invalid_before),
          invalidHereafter: parseValidityInterval(response.invalid_hereafter)
        },
        withdrawals: await fetchWithdrawals(response)
      },
      id: hash,
      implicitCoin: {
        deposit: BigInt(response.deposit)
        // TODO: use computeImplicitCoin to compute implicit input
      },
      index: response.index,
      txSize: response.size,
      witness: {
        redeemers: await fetchRedeemers(response),
        signatures: {}
      }
      // TODO: fetch metadata; not sure we can get the metadata hash and scripts from Blockfrost
    };
  };

  const queryTransactionsByHashes: WalletProvider['queryTransactionsByHashes'] = async (hashes) =>
    Promise.all(hashes.map(fetchTransaction));

  const queryTransactionsByAddresses: WalletProvider['queryTransactionsByAddresses'] = async (addresses) => {
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

  const currentWalletProtocolParameters: WalletProvider['currentWalletProtocolParameters'] = async () => {
    const response = await blockfrost.axiosInstance({
      url: `${blockfrost.apiUrl}/epochs/latest/parameters`
    });

    return BlockfrostToCore.currentWalletProtocolParameters(response.data);
  };

  const providerFunctions: WalletProvider = {
    currentWalletProtocolParameters,
    ledgerTip,
    networkInfo,
    queryTransactionsByAddresses,
    queryTransactionsByHashes,
    stakePoolStats,
    submitTx,
    utxoDelegationAndRewards
  };

  return Object.keys(providerFunctions).reduce((provider, key) => {
    provider[key] = (...args: any[]) => (providerFunctions as any)[key](...args).catch(toProviderError);
    return provider;
  }, {} as any) as WalletProvider;
};
