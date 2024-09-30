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
  Serialization,
  TransactionsByAddressesArgs,
  TransactionsByIdsArgs
} from '@cardano-sdk/core';
import { DB_MAX_SAFE_INTEGER } from '../DbSyncChainHistory/queries';
import { HydratedTxBody } from '@cardano-sdk/core/dist/cjs/Cardano';
import { Responses } from '@blockfrost/blockfrost-js';
import { Schemas } from '@blockfrost/blockfrost-js/lib/types/open-api';
import { removeUndefinedFields } from '@cardano-sdk/util';

type WithCertIndex<T> = T & { cert_index: number };

export class BlockfrostChainHistoryProvider extends BlockfrostProvider implements ChainHistoryProvider {
  protected async fetchRedeemers({
    hash,
    redeemer_count
  }: Responses['tx_content']): Promise<Cardano.Redeemer[] | undefined> {
    if (!redeemer_count) return;
    return this.blockfrost.txsRedeemers(hash).then((response) =>
      response.map(
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
      )
    );
  }

  protected async fetchWithdrawals({
    withdrawal_count,
    hash
  }: Responses['tx_content']): Promise<Cardano.Withdrawal[] | undefined> {
    if (!withdrawal_count) return;
    return this.blockfrost.txsWithdrawals(hash).then((response) =>
      response.map(
        ({ address, amount }): Cardano.Withdrawal => ({
          quantity: BigInt(amount),
          stakeAddress: Cardano.RewardAccount(address)
        })
      )
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
    return this.blockfrost.txsPoolRetires(hash).then((response) =>
      response.map(({ pool_id, retiring_epoch, cert_index }) => ({
        __typename: Cardano.CertificateType.PoolRetirement,
        cert_index,
        epoch: Cardano.EpochNo(retiring_epoch),
        poolId: Cardano.PoolId(pool_id)
      }))
    );
  }

  protected async fetchPoolUpdateCerts(hash: string): Promise<WithCertIndex<Cardano.PoolRegistrationCertificate>[]> {
    return this.blockfrost.txsPoolUpdates(hash).then((response) =>
      response.map(({ pool_id, cert_index }) => ({
        __typename: Cardano.CertificateType.PoolRegistration,
        cert_index,
        poolId: Cardano.PoolId(pool_id),
        poolParameters: ((): Cardano.PoolParameters => {
          this.logger.warn('Omitting poolParameters for certificate in tx', hash);
          return null as unknown as Cardano.PoolParameters;
        })()
      }))
    );
  }
  async fetchCBOR(hash: string): Promise<string> {
    return this.blockfrost
      .instance<Schemas['script_cbor']>(`/txs/${hash}/cbor`)
      .then((response) => {
        if (response.body.cbor) return response.body.cbor;
        throw new Error('CBOR is null');
      })
      .catch((_error) => {
        throw new Error('CBOR fetch failed');
      });
  }
  protected async fetchDetailsFromCBOR(hash: string) {
    return this.fetchCBOR(hash)
      .then((cbor) => {
        const tx = Serialization.Transaction.fromCbor(Serialization.TxCBOR(cbor)).toCore();
        this.logger.info('Fetched details from CBOR for tx', hash);
        return tx;
      })
      .catch((error) => {
        this.logger.warn('Failed to fetch details from CBOR for tx', hash, error);
        return null;
      });
  }

  protected async fetchMirCerts(hash: string): Promise<WithCertIndex<Cardano.MirCertificate>[]> {
    return this.blockfrost.txsMirs(hash).then((response) =>
      response.map(({ address, amount, cert_index, pot }) => ({
        __typename: Cardano.CertificateType.MIR,
        cert_index,
        kind: Cardano.MirCertificateKind.ToStakeCreds,
        pot: pot === 'reserve' ? Cardano.MirCertificatePot.Reserves : Cardano.MirCertificatePot.Treasury,
        quantity: BigInt(amount),
        rewardAccount: Cardano.RewardAccount(address)
      }))
    );
  }

  protected async fetchStakeCerts(hash: string): Promise<WithCertIndex<Cardano.StakeAddressCertificate>[]> {
    return this.blockfrost.txsStakes(hash).then((response) =>
      response.map(({ address, cert_index, registration }) => ({
        __typename: registration
          ? Cardano.CertificateType.StakeRegistration
          : Cardano.CertificateType.StakeDeregistration,
        cert_index,
        stakeCredential: {
          hash: Cardano.RewardAccount.toHash(Cardano.RewardAccount(address)) as unknown as Crypto.Hash28ByteBase16,
          type: Cardano.CredentialType.KeyHash
        }
      }))
    );
  }

  protected async fetchDelegationCerts(hash: string): Promise<WithCertIndex<Cardano.StakeDelegationCertificate>[]> {
    return this.blockfrost.txsDelegations(hash).then((response) =>
      response.map(({ address, pool_id, cert_index }) => ({
        __typename: Cardano.CertificateType.StakeDelegation,
        cert_index,
        poolId: Cardano.PoolId(pool_id),
        stakeCredential: {
          hash: Cardano.RewardAccount.toHash(Cardano.RewardAccount(address)) as unknown as Crypto.Hash28ByteBase16,
          type: Cardano.CredentialType.KeyHash
        }
      }))
    );
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

    return Promise.all([
      pool_retire_count ? this.fetchPoolRetireCerts(hash) : [],
      pool_update_count ? this.fetchPoolUpdateCerts(hash) : [],
      mir_cert_count ? this.fetchMirCerts(hash) : [],
      stake_cert_count ? this.fetchStakeCerts(hash) : [],
      delegation_count ? this.fetchDelegationCerts(hash) : []
    ]).then((results) =>
      results
        .flat()
        .sort((a, b) => b.cert_index - a.cert_index)
        .map((cert) => cert as Cardano.Certificate)
    );
  }

  protected async fetchJsonMetadataAsAuxiliaryData(
    txHash: Cardano.TransactionId
  ): Promise<Cardano.AuxiliaryData | undefined> {
    const UNDEFINED = undefined;
    return this.blockfrost
      .txsMetadata(txHash.toString())
      .then((m) => {
        const metadata = blockfrostMetadataToTxMetadata(m);
        return metadata && metadata.size > 0
          ? {
              blob: metadata
            }
          : UNDEFINED;
      })
      .catch((error) => {
        if (isBlockfrostNotFoundError(error)) {
          return UNDEFINED;
        }
        throw error;
      });
  }

  // eslint-disable-next-line unicorn/consistent-function-scoping
  protected parseValidityInterval = (num: string | null) => Cardano.Slot(Number.parseInt(num || '')) || undefined;

  protected async fetchTransaction(hash: Cardano.TransactionId): Promise<Cardano.HydratedTx> {
    try {
      const txContent = await this.blockfrost.txs(hash.toString());

      const txFromCBOR = await this.fetchDetailsFromCBOR(hash.toString());

      const [certificates, withdrawals, utxos, auxiliaryData] = await Promise.all([
        txFromCBOR ? txFromCBOR.body.certificates : this.fetchCertificates(txContent),
        txFromCBOR ? txFromCBOR.body.withdrawals : this.fetchWithdrawals(txContent),
        this.blockfrost.txsUtxos(hash.toString()),
        txFromCBOR ? txFromCBOR.auxiliaryData : this.fetchJsonMetadataAsAuxiliaryData(hash)
      ]);

      // We can't use txFromCBOR.body.inputs since it misses HydratedTxIn.address
      const { inputs, outputs, collaterals } = BlockfrostToCore.transactionUtxos(utxos);

      const fee = txFromCBOR ? txFromCBOR.body.fee : BigInt(txContent.fees);
      const mint = txFromCBOR ? txFromCBOR.body.mint : this.gatherMintsFromUtxos(txContent, utxos);
      const validityInterval = txFromCBOR
        ? txFromCBOR.body.validityInterval
        : {
            invalidBefore: this.parseValidityInterval(txContent.invalid_before),
            invalidHereafter: this.parseValidityInterval(txContent.invalid_hereafter)
          };

      const witness = removeUndefinedFields(
        txFromCBOR
          ? txFromCBOR.witness
          : {
              redeemers: await this.fetchRedeemers(txContent),
              signatures: new Map() // not available in blockfrost
            }
      );

      // can txFromCBOR.isValid also be used?
      const valid_contract = txContent.valid_contract;

      const inputSource: Cardano.InputSource = valid_contract
        ? Cardano.InputSource.inputs
        : Cardano.InputSource.collaterals;

      // can we get these from cbor?
      const index = txContent.index;
      const txSize = txContent.size;
      const blockHeader = {
        blockNo: Cardano.BlockNo(txContent.block_height),
        hash: Cardano.BlockId(txContent.block),
        slot: Cardano.Slot(txContent.slot)
      };

      const body: HydratedTxBody = removeUndefinedFields({
        certificates,
        collaterals,
        fee,
        inputs,
        mint,
        outputs,
        validityInterval,
        withdrawals
      });

      return {
        auxiliaryData,
        blockHeader,
        body,
        id: hash,
        index,
        inputSource,
        txSize,
        witness
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

  // eslint-disable-next-line sonarjs/cognitive-complexity
  public async transactionsByAddresses({
    addresses,
    pagination,
    blockRange
  }: TransactionsByAddressesArgs): Promise<Paginated<Cardano.HydratedTx>> {
    this.logger.info(`transactionsByAddresses: ${JSON.stringify(blockRange)} ${JSON.stringify(addresses)}`);
    try {
      const lowerBound = blockRange?.lowerBound ?? 0;
      const upperBound = blockRange?.upperBound ?? DB_MAX_SAFE_INTEGER;

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
              this.blockfrost.addressesTransactions(addr.toString(), paginationOptions, {
                from: blockRange?.lowerBound ? blockRange?.lowerBound.toString() : undefined,
                to: blockRange?.upperBound ? blockRange?.upperBound.toString() : undefined
              })
          })
        )
      );

      const allTransactions = addressTransactions.flat(1);

      const ids = allTransactions
        .filter(({ block_height }) => block_height >= lowerBound && block_height <= upperBound)
        .sort((a, b) => a.block_height - b.block_height || a.tx_index - b.tx_index)
        .map(({ tx_hash }) => Cardano.TransactionId(tx_hash))
        .splice(pagination.startAt, pagination.limit);

      const pageResults = await this.transactionsByHashes({ ids });

      return { pageResults, totalResultCount: allTransactions.length };
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }
}
