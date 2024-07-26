/* eslint-disable max-len */
import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { BlockfrostToCore, BlockfrostTransactionContent } from './BlockfrostToCore';
import { Cardano, ChainHistoryProvider, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { blockfrostMetadataToTxMetadata, fetchByAddressSequentially, formatBlockfrostError, healthCheck } from './util';
import omit from 'lodash/omit';
import orderBy from 'lodash/orderBy';

type WithCertIndex<T> = T & { cert_index: number };

/**
 * Connect to the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {BlockFrostAPI} blockfrost BlockFrostAPI instance
 * @returns {ChainHistoryProvider} ChainHistoryProvider
 * @throws {ProviderError}
 */
export const blockfrostChainHistoryProvider = (blockfrost: BlockFrostAPI, logger: Logger): ChainHistoryProvider => {
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
        scriptHash: Cardano.util.Hash28ByteBase16(script_hash)
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

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const parseValidityInterval = (num: string | null) => Number.parseInt(num || '') || undefined;

  const fetchTransaction = async (hash: Cardano.TransactionId): Promise<Cardano.TxAlonzo> => {
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
      index: response.index,
      txSize: response.size,
      witness: {
        redeemers: await fetchRedeemers(response),
        signatures: new Map() // not available in blockfrost
      }
    };
  };

  const blocksByHashes: ChainHistoryProvider['blocksByHashes'] = async ({ ids }) => {
    const responses = await Promise.all(ids.map((id) => blockfrost.blocks(id.toString())));
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

  const transactionsByHashes: ChainHistoryProvider['transactionsByHashes'] = async ({ ids }) =>
    Promise.all(ids.map((id) => fetchTransaction(id)));

  const transactionsByAddresses: ChainHistoryProvider['transactionsByAddresses'] = async ({
    addresses,
    blockRange,
    pagination
  }) => {
    // TODO: add pagination support for Blockfrost
    if (pagination) throw new ProviderError(ProviderFailure.NotImplemented);

    const addressTransactions = await Promise.all(
      addresses.map(async (address) =>
        fetchByAddressSequentially<
          { tx_hash: string; tx_index: number; block_height: number },
          BlockfrostTransactionContent
        >({
          address,
          haveEnoughItems: blockRange?.lowerBound
            ? (transactions) =>
                transactions.length > 0 && transactions[transactions.length - 1].block_height < blockRange!.lowerBound!
            : undefined,
          paginationOptions: { count: 5, order: 'desc' },
          request: (addr: Cardano.Address, paginationOptions) =>
            blockfrost.addressesTransactions(addr.toString(), paginationOptions)
        })
      )
    );

    const allTransactions = orderBy(addressTransactions.flat(1), ['block_height', 'tx_index']);
    const addressTransactionsSinceBlock = blockRange?.lowerBound
      ? allTransactions.filter(({ block_height }) => block_height >= blockRange!.lowerBound!)
      : allTransactions;
    const ids = addressTransactionsSinceBlock.map(({ tx_hash }) => Cardano.TransactionId(tx_hash));
    const pageResults = await transactionsByHashes({ ids });

    return { pageResults, totalResultCount: allTransactions.length };
  };

  return {
    blocksByHashes,
    healthCheck: healthCheck.bind(undefined, blockfrost),
    transactionsByAddresses,
    transactionsByHashes
  };
};
