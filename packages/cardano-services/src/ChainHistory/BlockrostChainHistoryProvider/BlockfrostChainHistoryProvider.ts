// eslint-disable-next-line jsdoc/check-param-names
import * as Crypto from '@cardano-sdk/crypto';
import { BlockfrostProvider } from '../../util/BlockfrostProvider/BlockfrostProvider';
import {
  BlockfrostToCore,
  BlockfrostTransactionContent,
  blockfrostMetadataToTxMetadata,
  blockfrostToProviderError,
  fetchByAddressSequentially,
  isBlockfrostNotFoundError
} from '../../util';
import {
  BlocksByIdsArgs,
  Cardano,
  ChainHistoryProvider,
  Paginated,
  ProviderError,
  ProviderFailure,
  TransactionsByAddressesArgs,
  TransactionsByIdsArgs
} from '@cardano-sdk/core';
import { Responses } from '@blockfrost/blockfrost-js';

type WithCertIndex<T> = T & { cert_index: number };

export class BlockfrostChainHistoryProvider extends BlockfrostProvider implements ChainHistoryProvider {
  protected async fetchRedeemers({
    hash,
    redeemer_count
  }: Responses['tx_content']): Promise<Cardano.Redeemer[] | undefined> {
    if (!redeemer_count) return;
    const response = await this.blockfrost.txsRedeemers(hash);
    return response.map(
      ({ purpose, script_hash, unit_mem, unit_steps, tx_index }): Cardano.Redeemer => ({
        data: Buffer.from(script_hash),
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
        })()
      })
    );
  }

  protected async fetchWithdrawals({
    withdrawal_count,
    hash
  }: Responses['tx_content']): Promise<Cardano.Withdrawal[] | undefined> {
    if (!withdrawal_count) return;
    const response = await this.blockfrost.txsWithdrawals(hash);
    return response.map(
      ({ address, amount }): Cardano.Withdrawal => ({
        quantity: BigInt(amount),
        stakeAddress: Cardano.RewardAccount(address)
      })
    );
  }
  /** This method gathers mints by finding the amounts that doesn't exist in 'inputs' but exist in 'outputs'. */
  protected gatherMintsFromUtxos(
    { asset_mint_or_burn_count }: Responses['tx_content'],
    { inputs, outputs }: Responses['tx_content_utxo']
  ): Cardano.TokenMap | undefined {
    if (!asset_mint_or_burn_count) return;

    const outputAmounts = outputs.flatMap((o) => o.amount);
    const inputAmounts = inputs.flatMap((i) => i.amount);

    const amountDifference = outputAmounts.filter(
      (amount1) => !inputAmounts.some((amount2) => amount1.unit === amount2.unit)
    );

    return new Map(amountDifference.map((amount) => [Cardano.AssetId(amount.unit), BigInt(amount.quantity)]));
  }

  protected async fetchPoolRetireCerts(hash: string): Promise<WithCertIndex<Cardano.PoolRetirementCertificate>[]> {
    const response = await this.blockfrost.txsPoolRetires(hash);
    return response.map(({ pool_id, retiring_epoch, cert_index }) => ({
      __typename: Cardano.CertificateType.PoolRetirement,
      cert_index,
      epoch: Cardano.EpochNo(retiring_epoch),
      poolId: Cardano.PoolId(pool_id)
    }));
  }

  protected async fetchPoolUpdateCerts(hash: string): Promise<WithCertIndex<Cardano.PoolRegistrationCertificate>[]> {
    const response = await this.blockfrost.txsPoolUpdates(hash);
    return response.map(({ pool_id, cert_index }) => ({
      __typename: Cardano.CertificateType.PoolRegistration,
      cert_index,
      poolId: Cardano.PoolId(pool_id),
      poolParameters: ((): Cardano.PoolParameters => {
        this.logger.warn('Omitting poolParameters for certificate in tx', hash);
        return null as unknown as Cardano.PoolParameters;
      })()
    }));
  }

  protected async fetchMirCerts(hash: string): Promise<WithCertIndex<Cardano.MirCertificate>[]> {
    const response = await this.blockfrost.txsMirs(hash);
    return response.map(({ address, amount, cert_index, pot }) => ({
      __typename: Cardano.CertificateType.MIR,
      cert_index,
      kind: Cardano.MirCertificateKind.ToStakeCreds,
      pot: pot === 'reserve' ? Cardano.MirCertificatePot.Reserves : Cardano.MirCertificatePot.Treasury,
      quantity: BigInt(amount),
      rewardAccount: Cardano.RewardAccount(address)
    }));
  }

  protected async fetchStakeCerts(hash: string): Promise<WithCertIndex<Cardano.StakeAddressCertificate>[]> {
    const response = await this.blockfrost.txsStakes(hash);
    return response.map(({ address, cert_index, registration }) => ({
      __typename: registration
        ? Cardano.CertificateType.StakeRegistration
        : Cardano.CertificateType.StakeDeregistration,
      cert_index,
      stakeCredential: {
        hash: Cardano.RewardAccount.toHash(Cardano.RewardAccount(address)) as unknown as Crypto.Hash28ByteBase16,
        type: Cardano.CredentialType.KeyHash
      }
    }));
  }

  protected async fetchDelegationCerts(hash: string): Promise<WithCertIndex<Cardano.StakeDelegationCertificate>[]> {
    const response = await this.blockfrost.txsDelegations(hash);
    return response.map(({ address, pool_id, cert_index }) => ({
      __typename: Cardano.CertificateType.StakeDelegation,
      cert_index,
      poolId: Cardano.PoolId(pool_id),
      stakeCredential: {
        hash: Cardano.RewardAccount.toHash(Cardano.RewardAccount(address)) as unknown as Crypto.Hash28ByteBase16,
        type: Cardano.CredentialType.KeyHash
      }
    }));
  }

  protected async fetchCertificates({
    pool_retire_count,
    pool_update_count,
    mir_cert_count,
    stake_cert_count,
    delegation_count,
    hash
  }: Responses['tx_content']): Promise<Cardano.Certificate[] | undefined> {
    if (pool_retire_count + pool_update_count + mir_cert_count + stake_cert_count + delegation_count === 0) return;
    return [
      ...(pool_retire_count ? await this.fetchPoolRetireCerts(hash) : []),
      ...(pool_update_count ? await this.fetchPoolUpdateCerts(hash) : []),
      ...(mir_cert_count ? await this.fetchMirCerts(hash) : []),
      ...(stake_cert_count ? await this.fetchStakeCerts(hash) : []),
      ...(delegation_count ? await this.fetchDelegationCerts(hash) : [])
    ]
      .sort((a, b) => b.cert_index - a.cert_index)
      .map((cert) => cert as Cardano.Certificate);
  }

  protected async fetchJsonMetadata(txHash: Cardano.TransactionId): Promise<Cardano.TxMetadata | null> {
    try {
      const response = await this.blockfrost.txsMetadata(txHash.toString());
      // Not sure if types are correct, missing 'label', but it's present in docs
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      return blockfrostMetadataToTxMetadata(response as any);
    } catch (error) {
      if (isBlockfrostNotFoundError(error)) {
        return null;
      }
      throw error;
    }
  }

  // eslint-disable-next-line unicorn/consistent-function-scoping
  protected parseValidityInterval = (num: string | null) => Cardano.Slot(Number.parseInt(num || '')) || undefined;

  protected async fetchTransaction(hash: Cardano.TransactionId): Promise<Cardano.HydratedTx> {
    try {
      const utxos: Responses['tx_content_utxo'] = await this.blockfrost.txsUtxos(hash.toString());
      const { inputs, outputs, collaterals } = BlockfrostToCore.transactionUtxos(utxos);

      const response = await this.blockfrost.txs(hash.toString());
      const metadata = await this.fetchJsonMetadata(hash);
      const certificates = await this.fetchCertificates(response);
      const withdrawals = await this.fetchWithdrawals(response);
      const inputSource: Cardano.InputSource = response.valid_contract
        ? Cardano.InputSource.inputs
        : Cardano.InputSource.collaterals;

      return {
        auxiliaryData: metadata
          ? {
              blob: metadata
            }
          : undefined,

        blockHeader: {
          blockNo: Cardano.BlockNo(response.block_height),
          hash: Cardano.BlockId(response.block),
          slot: Cardano.Slot(response.slot)
        },
        body: {
          certificates,
          collaterals,
          fee: BigInt(response.fees),
          inputs,
          mint: this.gatherMintsFromUtxos(response, utxos),
          outputs,
          validityInterval: {
            invalidBefore: this.parseValidityInterval(response.invalid_before),
            invalidHereafter: this.parseValidityInterval(response.invalid_hereafter)
          },
          withdrawals
        },
        id: hash,
        index: response.index,
        inputSource,
        txSize: response.size,
        witness: {
          redeemers: await this.fetchRedeemers(response),
          signatures: new Map() // not available in blockfrost
        }
      };
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }

  public async blocksByHashes({ ids }: BlocksByIdsArgs): Promise<Cardano.ExtendedBlockInfo[]> {
    try {
      const responses = await Promise.all(ids.map((id) => this.blockfrost.blocks(id.toString())));
      return responses.map((response) => {
        if (!response.epoch || !response.epoch_slot || !response.height || !response.slot || !response.block_vrf) {
          throw new ProviderError(ProviderFailure.Unknown, null, 'Queried unsupported block');
        }
        return {
          confirmations: response.confirmations,
          date: new Date(response.time * 1000),
          epoch: Cardano.EpochNo(response.epoch),
          epochSlot: response.epoch_slot,
          fees: BigInt(response.fees || '0'),
          header: {
            blockNo: Cardano.BlockNo(response.height),
            hash: Cardano.BlockId(response.hash),
            slot: Cardano.Slot(response.slot)
          },
          nextBlock: response.next_block ? Cardano.BlockId(response.next_block) : undefined,
          previousBlock: response.previous_block ? Cardano.BlockId(response.previous_block) : undefined,
          size: Cardano.BlockSize(response.size),
          slotLeader: Cardano.SlotLeader(response.slot_leader),
          totalOutput: BigInt(response.output || '0'),
          txCount: response.tx_count,
          vrf: Cardano.VrfVkBech32(response.block_vrf)
        };
      });
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }

  public async transactionsByHashes({ ids }: TransactionsByIdsArgs): Promise<Cardano.HydratedTx[]> {
    try {
      return Promise.all(ids.map((id) => this.fetchTransaction(id)));
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }

  public async transactionsByAddresses({
    addresses,
    blockRange
  }: TransactionsByAddressesArgs): Promise<Paginated<Cardano.HydratedTx>> {
    try {
      const addressTransactions = await Promise.all(
        addresses.map(async (address) =>
          fetchByAddressSequentially<
            { tx_hash: string; tx_index: number; block_height: number },
            BlockfrostTransactionContent
          >({
            address,
            haveEnoughItems: blockRange?.lowerBound
              ? (transactions) =>
                  transactions.length > 0 &&
                  transactions[transactions.length - 1].block_height < blockRange!.lowerBound!
              : undefined,
            request: (addr: Cardano.PaymentAddress, paginationOptions) =>
              this.blockfrost.addressesTransactions(addr.toString(), paginationOptions)
          })
        )
      );

      const allTransactions = addressTransactions
        .flat(1)
        .sort((a, b) => b.block_height - a.block_height || b.tx_index - a.tx_index);
      const addressTransactionsSinceBlock = blockRange?.lowerBound
        ? allTransactions.filter(({ block_height }) => block_height >= blockRange!.lowerBound!)
        : allTransactions;
      const ids = addressTransactionsSinceBlock.map(({ tx_hash }) => Cardano.TransactionId(tx_hash));
      const pageResults = await this.transactionsByHashes({ ids });

      return { pageResults, totalResultCount: allTransactions.length };
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }
}
