import {
  BigIntMath,
  Cardano,
  EpochRange,
  EpochRewards,
  ProviderError,
  ProviderFailure,
  ProviderUtil,
  WalletProvider
} from '@cardano-sdk/core';
import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { BlockfrostToCore, BlockfrostTransactionContent, BlockfrostUtxo } from './BlockfrostToCore';
import { PaginationOptions } from '@blockfrost/blockfrost-js/lib/types';
import { dummyLogger } from 'ts-log';
import { fetchSequentially, formatBlockfrostError, jsonToMetadatum, toProviderError } from './util';
import { flatten, groupBy } from 'lodash-es';

const fetchByAddressSequentially = async <Item, Response>(props: {
  address: Cardano.Address;
  request: (address: Cardano.Address, pagination: PaginationOptions) => Promise<Response[]>;
  responseTranslator?: (address: Cardano.Address, response: Response[]) => Item[];
}): Promise<Item[]> =>
  fetchSequentially({
    arg: props.address,
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

  const utxoDelegationAndRewards: WalletProvider['utxoDelegationAndRewards'] = async (addresses, rewardAccount) => {
    const utxoResults = await Promise.all(
      addresses.map(async (address) =>
        fetchByAddressSequentially<Cardano.Utxo, BlockfrostUtxo>({
          address,
          request: (addr: Cardano.Address, pagination) => blockfrost.addressesUtxos(addr.toString(), pagination),
          responseTranslator: (addr: Cardano.Address, response: Responses['address_utxo_content']) =>
            BlockfrostToCore.addressUtxoContent(addr.toString(), response)
        })
      )
    );
    const utxo = utxoResults.flat(1);
    if (rewardAccount !== undefined) {
      try {
        const accountResponse = await blockfrost.accounts(rewardAccount.toString());
        const delegationAndRewards = {
          delegate: accountResponse.pool_id ? Cardano.PoolId(accountResponse.pool_id) : undefined,
          rewards: BigInt(accountResponse.withdrawable_amount)
        };
        return { delegationAndRewards, utxo };
      } catch (error) {
        if (formatBlockfrostError(error).status_code === 404) {
          return { utxo };
        }
        throw error;
      }
    }
    return { utxo };
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

  const fetchPoolRetireCerts = async (hash: string): Promise<Cardano.PoolRetirementCertificate[]> => {
    const response = await blockfrost.txsPoolRetires(hash);
    return response.map(({ pool_id, retiring_epoch }) => ({
      __typename: Cardano.CertificateType.PoolRetirement,
      epoch: retiring_epoch,
      poolId: Cardano.PoolId(pool_id)
    }));
  };

  const fetchPoolUpdateCerts = async (hash: string): Promise<Cardano.PoolRegistrationCertificate[]> => {
    const response = await blockfrost.txsPoolUpdates(hash);
    return response.map(({ pool_id, active_epoch }) => ({
      __typename: Cardano.CertificateType.PoolRegistration,
      epoch: active_epoch,
      poolId: Cardano.PoolId(pool_id),
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
      certIndex: cert_index,
      pot,
      quantity: BigInt(amount),
      rewardAccount: Cardano.RewardAccount(address)
    }));
  };

  const fetchStakeCerts = async (hash: string): Promise<Cardano.StakeAddressCertificate[]> => {
    const response = await blockfrost.txsStakes(hash);
    return response.map(({ address, cert_index, registration }) => ({
      __typename: registration
        ? Cardano.CertificateType.StakeKeyRegistration
        : Cardano.CertificateType.StakeKeyDeregistration,
      certIndex: cert_index,
      rewardAccount: Cardano.RewardAccount(address)
    }));
  };

  const fetchDelegationCerts = async (hash: string): Promise<Cardano.StakeDelegationCertificate[]> => {
    const response = await blockfrost.txsDelegations(hash);
    return response.map(({ cert_index, index, address, active_epoch, pool_id }) => ({
      __typename: Cardano.CertificateType.StakeDelegation,
      certIndex: cert_index,
      delegationIndex: index,
      epoch: active_epoch,
      poolId: Cardano.PoolId(pool_id),
      rewardAccount: Cardano.RewardAccount(address)
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
      ...(pool_retire_count ? await fetchPoolRetireCerts(hash) : []),
      ...(pool_update_count ? await fetchPoolUpdateCerts(hash) : []),
      ...(mir_cert_count ? await fetchMirCerts(hash) : []),
      ...(stake_cert_count ? await fetchStakeCerts(hash) : []),
      ...(delegation_count ? await fetchDelegationCerts(hash) : [])
    ];
  };

  const fetchJsonMetadata = async (txHash: Cardano.TransactionId): Promise<Cardano.TxMetadata | null> => {
    try {
      const response = await blockfrost.txsMetadata(txHash.toString());
      return response.reduce((map, metadatum) => {
        // Not sure if types are correct, missing 'label', but it's present in docs
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const { json_metadata, label } = metadatum as any;
        if (!json_metadata || !label) return map;
        map.set(BigInt(label), jsonToMetadatum(json_metadata));
        return map;
      }, new Map<bigint, Cardano.Metadatum>());
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
  const fetchTransaction = async (hash: Cardano.TransactionId): Promise<Cardano.TxAlonzo> => {
    const { inputs, outputs, collaterals } = BlockfrostToCore.transactionUtxos(
      await blockfrost.txsUtxos(hash.toString())
    );
    const response = await blockfrost.txs(hash.toString());
    const metadata = await fetchJsonMetadata(hash);
    const protocolParameters = await currentWalletProtocolParameters();
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

  const queryTransactionsByHashes: WalletProvider['queryTransactionsByHashes'] = async (hashes) =>
    Promise.all(hashes.map(fetchTransaction));

  const queryTransactionsByAddresses: WalletProvider['queryTransactionsByAddresses'] = async (addresses) => {
    const addressTransactions = await Promise.all(
      addresses.map(async (address) =>
        fetchByAddressSequentially<
          { tx_hash: string; tx_index: number; block_height: number },
          BlockfrostTransactionContent
        >({
          address,
          request: (addr: Cardano.Address, pagination) => blockfrost.addressesTransactions(addr.toString(), pagination)
        })
      )
    );

    const transactionsArray = await Promise.all(
      addressTransactions.map((transactionArray) =>
        queryTransactionsByHashes(transactionArray.map(({ tx_hash }) => Cardano.TransactionId(tx_hash)))
      )
    );

    return transactionsArray.flat(1);
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
      const rewards = await blockfrost.accountsRewards(stakeAddress.toString(), { count: batchSize, page });
      result.push(
        ...rewards
          .filter(({ epoch }) => lowerBound <= epoch && epoch <= upperBound)
          .map(({ epoch, amount }) => ({
            epoch,
            rewards: BigInt(amount)
          }))
      );
      haveMorePages = rewards.length === 100 && rewards[rewards.length - 1].epoch < upperBound;
      page += 1;
    }
    return result;
  };

  const rewardsHistory: WalletProvider['rewardsHistory'] = async ({ stakeAddresses, epochs }) => {
    const allAddressRewards = await Promise.all(stakeAddresses.map((address) => accountRewards(address, epochs)));
    const accountRewardsByEpoch = groupBy(flatten(allAddressRewards), ({ epoch }) => epoch);
    return Object.keys(accountRewardsByEpoch).map((key) => ({
      epoch: accountRewardsByEpoch[key][0].epoch,
      rewards: BigIntMath.sum(accountRewardsByEpoch[key].map(({ rewards }) => rewards))
    }));
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

  const queryBlocksByHashes: WalletProvider['queryBlocksByHashes'] = async (hashes) => {
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
    currentWalletProtocolParameters,
    genesisParameters,
    ledgerTip,
    networkInfo,
    queryBlocksByHashes,
    queryTransactionsByAddresses,
    queryTransactionsByHashes,
    rewardsHistory,
    stakePoolStats,
    utxoDelegationAndRewards
  };

  return ProviderUtil.withProviderErrors(providerFunctions, toProviderError);
};
