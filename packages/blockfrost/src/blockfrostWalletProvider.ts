import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { BlockfrostToCore, BlockfrostTransactionContent } from './BlockfrostToCore';
import {
  Cardano,
  EpochRange,
  EpochRewards,
  ProtocolParametersRequiredByWallet,
  ProviderError,
  ProviderFailure,
  ProviderUtil,
  WalletProvider
} from '@cardano-sdk/core';
import { PaginationOptions } from '@blockfrost/blockfrost-js/lib/types';
import { blockfrostMetadataToTxMetadata, fetchSequentially, formatBlockfrostError, toProviderError } from './util';
import { dummyLogger } from 'ts-log';
import { omit, orderBy } from 'lodash-es';

type WithCertIndex<T> = T & { cert_index: number };

const fetchByAddressSequentially = async <Item, Response>(props: {
  address: Cardano.Address;
  request: (address: Cardano.Address, pagination: PaginationOptions) => Promise<Response[]>;
  responseTranslator?: (address: Cardano.Address, response: Response[]) => Item[];
  /**
   * @returns true to indicatate that current result set should be returned
   */
  haveEnoughItems?: (items: Item[]) => boolean;
  paginationOptions?: PaginationOptions;
}): Promise<Item[]> =>
  fetchSequentially({
    arg: props.address,
    haveEnoughItems: props.haveEnoughItems,
    paginationOptions: props.paginationOptions,
    request: props.request,
    responseTranslator: props.responseTranslator
      ? (response, arg) => props.responseTranslator!(arg, response)
      : undefined
  });

/**
 * Connect to the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {BlockFrostAPI} blockfrost BlockFrostAPI instance
 * @returns {WalletProvider} WalletProvider
 * @throws {ProviderFailure}
 */
export const blockfrostWalletProvider = (blockfrost: BlockFrostAPI, logger = dummyLogger): WalletProvider => {
  const ledgerTip: WalletProvider['ledgerTip'] = async () => {
    const block = await blockfrost.blocksLatest();
    return BlockfrostToCore.blockToTip(block);
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

  const rewards: WalletProvider['rewardAccountBalance'] = async (rewardAccount: Cardano.RewardAccount) => {
    try {
      const accountResponse = await blockfrost.accounts(rewardAccount.toString());
      return BigInt(accountResponse.withdrawable_amount);
    } catch (error) {
      if (formatBlockfrostError(error).status_code === 404) {
        return 0n;
      }
      throw error;
    }
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
              return Cardano.RedeemerPurpose.certificate;
            case 'reward':
              return Cardano.RedeemerPurpose.withdrawal;
            case 'mint':
              return Cardano.RedeemerPurpose.mint;
            case 'spend':
              return Cardano.RedeemerPurpose.spend;
            default:
              return purpose;
          }
        })(),
        scriptHash: Cardano.Hash28ByteBase16(script_hash)
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
        stakeAddress: Cardano.RewardAccount(address)
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

  const fetchPoolRetireCerts = async (hash: string): Promise<WithCertIndex<Cardano.PoolRetirementCertificate>[]> => {
    const response = await blockfrost.txsPoolRetires(hash);
    return response.map(({ pool_id, retiring_epoch, cert_index }) => ({
      __typename: Cardano.CertificateType.PoolRetirement,
      cert_index,
      epoch: retiring_epoch,
      poolId: Cardano.PoolId(pool_id)
    }));
  };

  const fetchPoolUpdateCerts = async (hash: string): Promise<WithCertIndex<Cardano.PoolRegistrationCertificate>[]> => {
    const response = await blockfrost.txsPoolUpdates(hash);
    return response.map(({ pool_id, cert_index }) => ({
      __typename: Cardano.CertificateType.PoolRegistration,
      cert_index,
      poolId: Cardano.PoolId(pool_id),
      poolParameters: ((): Cardano.PoolParameters => {
        logger.warn('Omitting poolParameters for certificate in tx', hash);
        return null as unknown as Cardano.PoolParameters;
      })()
    }));
  };

  const fetchMirCerts = async (hash: string): Promise<WithCertIndex<Cardano.MirCertificate>[]> => {
    const response = await blockfrost.txsMirs(hash);
    return response.map(({ address, amount, cert_index, pot }) => ({
      __typename: Cardano.CertificateType.MIR,
      cert_index,
      pot: pot === 'reserve' ? Cardano.MirCertificatePot.Reserves : Cardano.MirCertificatePot.Treasury,
      quantity: BigInt(amount),
      rewardAccount: Cardano.RewardAccount(address)
    }));
  };

  const fetchStakeCerts = async (hash: string): Promise<WithCertIndex<Cardano.StakeAddressCertificate>[]> => {
    const response = await blockfrost.txsStakes(hash);
    return response.map(({ address, cert_index, registration }) => ({
      __typename: registration
        ? Cardano.CertificateType.StakeKeyRegistration
        : Cardano.CertificateType.StakeKeyDeregistration,
      cert_index,
      stakeKeyHash: Cardano.Ed25519KeyHash.fromRewardAccount(Cardano.RewardAccount(address))
    }));
  };

  const fetchDelegationCerts = async (hash: string): Promise<WithCertIndex<Cardano.StakeDelegationCertificate>[]> => {
    const response = await blockfrost.txsDelegations(hash);
    return response.map(({ address, pool_id, cert_index }) => ({
      __typename: Cardano.CertificateType.StakeDelegation,
      cert_index,
      poolId: Cardano.PoolId(pool_id),
      stakeKeyHash: Cardano.Ed25519KeyHash.fromRewardAccount(Cardano.RewardAccount(address))
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
    return orderBy(
      [
        ...(pool_retire_count ? await fetchPoolRetireCerts(hash) : []),
        ...(pool_update_count ? await fetchPoolUpdateCerts(hash) : []),
        ...(mir_cert_count ? await fetchMirCerts(hash) : []),
        ...(stake_cert_count ? await fetchStakeCerts(hash) : []),
        ...(delegation_count ? await fetchDelegationCerts(hash) : [])
      ],
      (cert) => cert.cert_index
    ).map((cert) => omit(cert, 'cert_index') as Cardano.Certificate);
  };

  const fetchJsonMetadata = async (txHash: Cardano.TransactionId): Promise<Cardano.TxMetadata | null> => {
    try {
      const response = await blockfrost.txsMetadata(txHash.toString());
      // Not sure if types are correct, missing 'label', but it's present in docs
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      return blockfrostMetadataToTxMetadata(response as any);
    } catch (error) {
      if (formatBlockfrostError(error).status_code === 404) {
        return null;
      }
      throw error;
    }
  };

  const currentWalletProtocolParameters: WalletProvider['currentWalletProtocolParameters'] = async () => {
    const response = await blockfrost.axiosInstance({
      url: `${blockfrost.apiUrl}/epochs/latest/parameters`
    });

    return BlockfrostToCore.currentWalletProtocolParameters(response.data);
  };

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const parseValidityInterval = (num: string | null) => Number.parseInt(num || '') || undefined;
  const fetchTransaction = async (
    hash: Cardano.TransactionId,
    protocolParameters: ProtocolParametersRequiredByWallet
  ): Promise<Cardano.TxAlonzo> => {
    const { inputs, outputs, collaterals } = BlockfrostToCore.transactionUtxos(
      await blockfrost.txsUtxos(hash.toString())
    );
    const response = await blockfrost.txs(hash.toString());
    const metadata = await fetchJsonMetadata(hash);
    const certificates = await fetchCertificates(response);
    const withdrawals = await fetchWithdrawals(response);
    return {
      auxiliaryData: metadata
        ? {
            body: { blob: metadata }
          }
        : undefined,
      blockHeader: {
        blockNo: response.block_height,
        hash: Cardano.BlockId(response.block),
        slot: response.slot
      },
      body: {
        certificates,
        collaterals,
        fee: BigInt(response.fees),
        inputs,
        mint: await fetchMint(response),
        outputs,
        validityInterval: {
          invalidBefore: parseValidityInterval(response.invalid_before),
          invalidHereafter: parseValidityInterval(response.invalid_hereafter)
        },
        withdrawals
      },
      id: hash,
      implicitCoin: Cardano.util.computeImplicitCoin(protocolParameters, { certificates, withdrawals }),
      index: response.index,
      txSize: response.size,
      witness: {
        redeemers: await fetchRedeemers(response),
        signatures: new Map() // not available in blockfrost
      }
    };
  };

  const transactionsByHashes: WalletProvider['transactionsByHashes'] = async (hashes) => {
    const protocolParameters = await currentWalletProtocolParameters();
    return Promise.all(hashes.map((hash) => fetchTransaction(hash, protocolParameters)));
  };

  const transactionsByAddresses: WalletProvider['transactionsByAddresses'] = async (addresses, sinceBlock) => {
    const addressTransactions = await Promise.all(
      addresses.map(async (address) =>
        fetchByAddressSequentially<
          { tx_hash: string; tx_index: number; block_height: number },
          BlockfrostTransactionContent
        >({
          address,
          haveEnoughItems: sinceBlock
            ? (transactions) =>
                transactions.length > 0 && transactions[transactions.length - 1].block_height < sinceBlock
            : undefined,
          paginationOptions: { count: 5, order: 'desc' },
          request: (addr: Cardano.Address, pagination) => blockfrost.addressesTransactions(addr.toString(), pagination)
        })
      )
    );

    const allTransactions = orderBy(addressTransactions.flat(1), ['block_height', 'tx_index']);
    const addressTransactionsSinceBlock = sinceBlock
      ? allTransactions.filter(({ block_height }) => block_height >= sinceBlock)
      : allTransactions;

    return transactionsByHashes(addressTransactionsSinceBlock.map(({ tx_hash }) => Cardano.TransactionId(tx_hash)));
  };

  const accountRewards = async (
    stakeAddress: Cardano.RewardAccount,
    { lowerBound = 0, upperBound = Number.MAX_SAFE_INTEGER }: EpochRange = {}
  ): Promise<EpochRewards[]> => {
    const result: EpochRewards[] = [];
    const batchSize = 100;
    let page = 1;
    let haveMorePages = true;
    while (haveMorePages) {
      const rewardsPage = await blockfrost.accountsRewards(stakeAddress.toString(), { count: batchSize, page });
      result.push(
        ...rewardsPage
          .filter(({ epoch }) => lowerBound <= epoch && epoch <= upperBound)
          .map(({ epoch, amount }) => ({
            epoch,
            rewards: BigInt(amount)
          }))
      );
      haveMorePages = rewardsPage.length === batchSize && rewardsPage[rewardsPage.length - 1].epoch < upperBound;
      page += 1;
    }
    return result;
  };

  const rewardsHistory: WalletProvider['rewardsHistory'] = async ({ rewardAccounts, epochs }) => {
    const allAddressRewards = await Promise.all(rewardAccounts.map((address) => accountRewards(address, epochs)));
    return new Map(allAddressRewards.map((epochRewards, i) => [rewardAccounts[i], epochRewards]));
  };

  const genesisParameters: WalletProvider['genesisParameters'] = async () => {
    const response = await blockfrost.genesis();
    return {
      activeSlotsCoefficient: response.active_slots_coefficient,
      epochLength: response.epoch_length,
      maxKesEvolutions: response.max_kes_evolutions,
      maxLovelaceSupply: BigInt(response.max_lovelace_supply),
      networkMagic: response.network_magic,
      securityParameter: response.security_param,
      slotLength: response.slot_length,
      slotsPerKesPeriod: response.slots_per_kes_period,
      systemStart: new Date(response.system_start * 1000),
      updateQuorum: response.update_quorum
    };
  };

  const blocksByHashes: WalletProvider['blocksByHashes'] = async (hashes) => {
    const responses = await Promise.all(hashes.map((hash) => blockfrost.blocks(hash.toString())));
    return responses.map((response) => {
      if (!response.epoch || !response.epoch_slot || !response.height || !response.slot || !response.block_vrf) {
        throw new ProviderError(ProviderFailure.Unknown, null, 'Queried unsupported block');
      }
      return {
        confirmations: response.confirmations,
        date: new Date(response.time * 1000),
        epoch: response.epoch,
        epochSlot: response.epoch_slot,
        fees: BigInt(response.fees || '0'),
        header: {
          blockNo: response.height,
          hash: Cardano.BlockId(response.hash),
          slot: response.slot
        },
        nextBlock: response.next_block ? Cardano.BlockId(response.next_block) : undefined,
        previousBlock: response.previous_block ? Cardano.BlockId(response.previous_block) : undefined,
        size: response.size,
        slotLeader: Cardano.SlotLeader(response.slot_leader),
        totalOutput: BigInt(response.output || '0'),
        txCount: response.tx_count,
        vrf: Cardano.VrfVkBech32(response.block_vrf)
      };
    });
  };

  const providerFunctions: WalletProvider = {
    blocksByHashes,
    currentWalletProtocolParameters,
    genesisParameters,
    ledgerTip,
    rewardAccountBalance: rewards,
    rewardsHistory,
    stakePoolStats,
    transactionsByAddresses,
    transactionsByHashes
  };

  return ProviderUtil.withProviderErrors(providerFunctions, toProviderError);
};
