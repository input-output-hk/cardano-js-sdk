// eslint-disable-next-line jsdoc/check-param-names
import {
  BlockfrostClient,
  BlockfrostProvider,
  BlockfrostToCore,
  BlockfrostTransactionContent,
  blockfrostMetadataToTxMetadata,
  fetchSequentially,
  isBlockfrostNotFoundError
} from '../blockfrost';
import {
  BlocksByIdsArgs,
  Cardano,
  ChainHistoryProvider,
  NetworkInfoProvider,
  Paginated,
  ProviderError,
  ProviderFailure,
  Serialization,
  TransactionsByAddressesArgs,
  TransactionsByIdsArgs,
  createSlotEpochCalc
} from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { extractCredentials, minimizeCredentialSet } from '../credentialUtils';
import omit from 'lodash/omit.js';
import uniq from 'lodash/uniq.js';
import type { Cache } from '@cardano-sdk/util';
import type { Responses } from '@blockfrost/blockfrost-js';
import type { Schemas } from '@blockfrost/blockfrost-js/lib/types/open-api';

type WithCertIndex<T> = T & { cert_index: number };
export const DB_MAX_SAFE_INTEGER = 2_147_483_647;

type BlockfrostTx = Pick<Responses['address_transactions_content'][0], 'block_height' | 'tx_index'>;
const compareTx = (a: BlockfrostTx, b: BlockfrostTx) => a.block_height - b.block_height || a.tx_index - b.tx_index;

interface BlockfrostChainHistoryProviderOptions {
  queryTxsByCredentials?: boolean;
}

interface BlockfrostChainHistoryProviderDependencies {
  cache: Cache<Cardano.HydratedTx>;
  client: BlockfrostClient;
  networkInfoProvider: NetworkInfoProvider;
  logger: Logger;
}

export class BlockfrostChainHistoryProvider extends BlockfrostProvider implements ChainHistoryProvider {
  private readonly cache: Cache<Cardano.HydratedTx>;
  private networkInfoProvider: NetworkInfoProvider;
  // Feature flag to enable credential-based transaction fetching (used in transactionsByAddresses)
  protected readonly queryTxsByCredentials: boolean;

  // Overload 1: Old signature (backward compatibility)
  constructor(dependencies: BlockfrostChainHistoryProviderDependencies);

  // Overload 2: New signature with options
  constructor(options: BlockfrostChainHistoryProviderOptions, dependencies: BlockfrostChainHistoryProviderDependencies);

  // Implementation signature
  constructor(
    optionsOrDependencies: BlockfrostChainHistoryProviderOptions | BlockfrostChainHistoryProviderDependencies,
    maybeDependencies?: BlockfrostChainHistoryProviderDependencies
  ) {
    // Detect which overload was used
    const isOldSignature = 'cache' in optionsOrDependencies;
    const options = isOldSignature ? {} : (optionsOrDependencies as BlockfrostChainHistoryProviderOptions);
    const dependencies = isOldSignature
      ? (optionsOrDependencies as BlockfrostChainHistoryProviderDependencies)
      : maybeDependencies!;

    super(dependencies.client, dependencies.logger);
    this.cache = dependencies.cache;
    this.networkInfoProvider = dependencies.networkInfoProvider;
    this.queryTxsByCredentials = options.queryTxsByCredentials ?? false;
  }

  protected async fetchRedeemers({
    hash,
    redeemer_count
  }: Responses['tx_content']): Promise<Cardano.Redeemer[] | undefined> {
    if (!redeemer_count) return;
    return this.request<Responses['tx_content_redeemers']>(`txs/${hash}/redeemers`).then((response) =>
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
    return this.request<Responses['tx_content_withdrawals']>(`txs/${hash}/withdrawals`).then((response) =>
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
    return this.request<Responses['tx_content_pool_retires']>(`txs/${hash}/pool_retires`).then((response) =>
      response.map(({ pool_id, retiring_epoch, cert_index }) => ({
        __typename: Cardano.CertificateType.PoolRetirement,
        cert_index,
        epoch: Cardano.EpochNo(retiring_epoch),
        poolId: Cardano.PoolId(pool_id)
      }))
    );
  }

  protected async fetchPoolUpdateCerts(hash: string): Promise<WithCertIndex<Cardano.PoolRegistrationCertificate>[]> {
    return this.request<Responses['tx_content_pool_certs']>(`txs/${hash}/pool_updates`).then((response) =>
      response.map(({ pool_id, cert_index, fixed_cost, margin_cost, pledge, reward_account, vrf_key }) => ({
        __typename: Cardano.CertificateType.PoolRegistration,
        cert_index,
        poolId: Cardano.PoolId(pool_id),
        poolParameters: {
          cost: BigInt(fixed_cost),
          id: pool_id as Cardano.PoolId,
          margin: Cardano.FractionUtils.toFraction(margin_cost),
          owners: [],
          pledge: BigInt(pledge),
          relays: [],
          rewardAccount: reward_account as Cardano.RewardAccount,
          vrf: vrf_key as Cardano.VrfVkHex
        }
      }))
    );
  }

  async fetchCBOR(hash: string): Promise<string> {
    return this.request<Responses['tx_content_cbor']>(`txs/${hash}/cbor`)
      .then((response) => {
        if (response) return response.cbor;
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
        this.logger.debug('Fetched details from CBOR for tx', hash);
        return tx;
      })
      .catch((error) => {
        this.logger.warn('Failed to fetch details from CBOR for tx', hash, error);
        return null;
      });
  }

  protected async fetchMirCerts(hash: string): Promise<WithCertIndex<Cardano.MirCertificate>[]> {
    return this.request<Responses['tx_content_mirs']>(`txs/${hash}/mirs`).then((response) =>
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
    return this.request<Responses['tx_content_stake_addr']>(`txs/${hash}/stakes`).then((response) =>
      response.map(({ address, cert_index, registration }) => ({
        __typename: registration
          ? Cardano.CertificateType.StakeRegistration
          : Cardano.CertificateType.StakeDeregistration,
        cert_index,
        stakeCredential: {
          hash: Cardano.RewardAccount.toHash(Cardano.RewardAccount(address)),
          type: Cardano.CredentialType.KeyHash
        }
      }))
    );
  }

  protected async fetchDelegationCerts(hash: string): Promise<WithCertIndex<Cardano.StakeDelegationCertificate>[]> {
    return this.request<Responses['tx_content_delegations']>(`txs/${hash}/delegations`).then((response) =>
      response.map(({ address, pool_id, cert_index }) => ({
        __typename: Cardano.CertificateType.StakeDelegation,
        cert_index,
        poolId: Cardano.PoolId(pool_id),
        stakeCredential: {
          hash: Cardano.RewardAccount.toHash(Cardano.RewardAccount(address)),
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

  protected async fetchJsonMetadataAsAuxiliaryData(txHash: string): Promise<Cardano.AuxiliaryData | undefined> {
    const UNDEFINED = undefined;
    return this.request<Responses['tx_content_metadata']>(`txs/${txHash}/metadata`)
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

  protected async fetchEpochNo(slotNo: Cardano.Slot) {
    const calc = await this.networkInfoProvider.eraSummaries().then(createSlotEpochCalc);
    return calc(slotNo);
  }

  protected async fetchEpochParameters(epochNo: Cardano.EpochNo): Promise<Schemas['epoch_param_content']> {
    return await this.request<Responses['epoch_param_content']>(`epochs/${epochNo}/parameters`);
  }

  protected async processCertificates(
    txContent: Schemas['tx_content'],
    certificates?: Cardano.Certificate[]
  ): Promise<Cardano.Certificate[] | undefined> {
    if (!certificates) return;

    const epochNo = await this.fetchEpochNo(Cardano.Slot(txContent.slot));
    const { pool_deposit, key_deposit } = await this.fetchEpochParameters(epochNo);

    return certificates.map((c) => {
      const cert = omit(c, 'cert_index') as Cardano.Certificate;
      switch (cert.__typename) {
        case Cardano.CertificateType.PoolRegistration: {
          cert.poolParameters.owners = [];
          cert.poolParameters.relays = [];
          const deposit =
            txContent.deposit === undefined || txContent.deposit === '' || txContent.deposit === '0'
              ? 0n
              : BigInt(pool_deposit);

          delete cert.poolParameters.metadataJson;

          return { ...cert, deposit };
        }
        case Cardano.CertificateType.StakeRegistration: {
          const deposit = BigInt(key_deposit);

          return { ...cert, __typename: Cardano.CertificateType.Registration, deposit };
        }
        case Cardano.CertificateType.StakeDeregistration: {
          const deposit = BigInt(key_deposit);

          return { ...cert, __typename: Cardano.CertificateType.Unregistration, deposit };
        }
        default:
          return cert;
      }
    });
  }

  protected async transactionDetailsUsingAPIs(txContent: Responses['tx_content']): Promise<Cardano.HydratedTx> {
    const id = Cardano.TransactionId(txContent.hash);

    const [certificates, withdrawals, utxos, auxiliaryData] = await Promise.all([
      this.fetchCertificates(txContent),
      this.fetchWithdrawals(txContent),
      this.fetchUtxos(id),
      this.fetchJsonMetadataAsAuxiliaryData(id)
    ]);

    const { inputs, outputs, collaterals } = this.transactionUtxos(utxos);

    const mintPreOrder = this.gatherMintsFromUtxos(txContent, utxos);
    const mint = mintPreOrder ? new Map([...mintPreOrder].sort()) : mintPreOrder;

    const inputSource: Cardano.InputSource = txContent.valid_contract
      ? Cardano.InputSource.inputs
      : Cardano.InputSource.collaterals;

    const body: Cardano.HydratedTxBody = this.mapTxBody(
      {
        certificates: await this.processCertificates(txContent, certificates),
        collateralReturn: undefined,
        collaterals,
        fee: BigInt(txContent.fees),
        inputs,
        mint,
        outputs,
        proposalProcedures: undefined,
        validityInterval: {
          invalidBefore: this.parseValidityInterval(txContent.invalid_before),
          invalidHereafter: this.parseValidityInterval(txContent.invalid_hereafter)
        },
        votingProcedures: undefined,
        withdrawals
      },
      inputSource
    );

    return {
      auxiliaryData,
      blockHeader: this.mapBlockHeader(txContent),
      body,
      id,
      index: txContent.index,
      inputSource,
      txSize: txContent.size,
      witness: this.witnessFromRedeemers(await this.fetchRedeemers(txContent))
    };
  }

  private witnessFromRedeemers(redeemers: Cardano.Redeemer[] | undefined): Cardano.Witness {
    // Although cbor has the data, this stub is used for compatibility with DbSyncChainHistoryProvider
    const stubRedeemerData = Buffer.from('not implemented');

    if (redeemers) {
      for (const redeemer of redeemers) {
        redeemer.data = stubRedeemerData;
      }
    }

    return {
      redeemers,
      signatures: new Map() // available in cbor, but skipped for compatibility with DbSyncChainHistoryProvider
    };
  }

  protected async transactionDetailsUsingCBOR(
    txContent: Responses['tx_content']
  ): Promise<Cardano.HydratedTx | undefined> {
    const id = Cardano.TransactionId(txContent.hash);

    const txFromCBOR = await this.fetchDetailsFromCBOR(id);
    if (!txFromCBOR) return;

    const utxos = await this.request<Responses['tx_content_utxo']>(`txs/${id}/utxos`);

    // We can't use txFromCBOR.body.inputs since it misses HydratedTxIn.address
    const { inputs, outputs, collaterals } = this.transactionUtxos(utxos, txFromCBOR);

    // txFromCBOR.isValid can be also be used
    const inputSource: Cardano.InputSource = txContent.valid_contract
      ? Cardano.InputSource.inputs
      : Cardano.InputSource.collaterals;

    const body: Cardano.HydratedTxBody = this.mapTxBody(
      {
        certificates: await this.processCertificates(txContent, txFromCBOR.body.certificates),
        collateralReturn: txFromCBOR.body.collateralReturn,
        collaterals,
        fee: txFromCBOR.body.fee,
        inputs,
        mint: txFromCBOR.body.mint ? new Map([...txFromCBOR.body.mint].sort()) : undefined,
        outputs,
        proposalProcedures: txFromCBOR.body.proposalProcedures,
        validityInterval: txFromCBOR.body.validityInterval
          ? txFromCBOR.body.validityInterval
          : { invalidBefore: undefined, invalidHereafter: undefined },
        votingProcedures: txFromCBOR.body.votingProcedures,
        withdrawals: txFromCBOR.body.withdrawals
      },
      inputSource
    );

    return {
      auxiliaryData: txFromCBOR.auxiliaryData,
      blockHeader: this.mapBlockHeader(txContent),
      body,
      id,
      index: txContent.index,
      inputSource,
      txSize: txContent.size,
      witness: this.witnessFromRedeemers(txFromCBOR.witness.redeemers)
    };
  }

  protected async fetchTransaction(txId: Cardano.TransactionId): Promise<Cardano.HydratedTx> {
    try {
      const txContent = await this.request<Responses['tx_content']>(`txs/${txId.toString()}`);

      return (await this.transactionDetailsUsingCBOR(txContent)) ?? (await this.transactionDetailsUsingAPIs(txContent));
    } catch (error) {
      throw this.toProviderError(error);
    }
  }

  private transactionUtxos(utxoResponse: Responses['tx_content_utxo'], txContent?: Cardano.Tx) {
    const collaterals = utxoResponse.inputs.filter((input) => input.collateral).map(BlockfrostToCore.hydratedTxIn);
    const inputs = utxoResponse.inputs
      .filter((input) => !input.collateral && !input.reference)
      .map(BlockfrostToCore.hydratedTxIn);
    const outputPromises: Cardano.TxOut[] = utxoResponse.outputs
      .filter((output) => !output.collateral)
      .map((output) => {
        const foundScript = txContent?.body.outputs.find((o) => o.address === output.address);

        return BlockfrostToCore.txOut(output, foundScript);
      });

    return { collaterals, inputs, outputs: outputPromises };
  }

  public async blocksByHashes({ ids }: BlocksByIdsArgs): Promise<Cardano.ExtendedBlockInfo[]> {
    try {
      const responses = await Promise.all(
        ids.map((id) => this.request<Responses['block_content']>(`blocks/${id.toString()}`))
      );
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
      throw this.toProviderError(error);
    }
  }

  public async transactionsByHashes({ ids }: TransactionsByIdsArgs): Promise<Cardano.HydratedTx[]> {
    return Promise.all(
      ids.map(async (id) => {
        const cached = await this.cache.get(id);
        if (cached) return cached;

        try {
          const fetchedTransaction = await this.fetchTransaction(id);
          void this.cache.set(id, fetchedTransaction);
          return fetchedTransaction;
        } catch (error) {
          throw this.toProviderError(error);
        }
      })
    );
  }

  /** Processes and filters transaction results, returning deduplicated and sorted transaction IDs. */
  private processTransactionResults(
    transactions: BlockfrostTransactionContent[],
    blockRange: { lowerBound?: number; upperBound?: number },
    order?: 'asc' | 'desc'
  ): Cardano.TransactionId[] {
    const lowerBound = blockRange.lowerBound ?? 0;
    const upperBound = blockRange.upperBound ?? DB_MAX_SAFE_INTEGER;

    return uniq(
      transactions
        .filter(({ block_height }) => block_height >= lowerBound && block_height <= upperBound)
        .sort(order === 'desc' ? (a, b) => compareTx(b, a) : compareTx)
        .map(({ tx_hash }) => Cardano.TransactionId(tx_hash))
    );
  }

  /** Executes the legacy per-address transaction fetching implementation. */
  private async fetchTransactionsPerAddress(
    addresses: Cardano.PaymentAddress[],
    pagination: TransactionsByAddressesArgs['pagination'],
    blockRange: TransactionsByAddressesArgs['blockRange']
  ): Promise<BlockfrostTransactionContent[]> {
    const paginationOptions = pagination
      ? {
          count: pagination.limit,
          order: pagination.order,
          page: (pagination.startAt + pagination.limit) / pagination.limit
        }
      : undefined;

    const limit = pagination?.limit ?? DB_MAX_SAFE_INTEGER;

    const addressTransactions = await Promise.all(
      addresses.map((address) =>
        this.fetchTransactionsByAddress(address, {
          blockRange,
          limit,
          pagination: paginationOptions
        })
      )
    );

    return addressTransactions.flat();
  }

  /** Logs information about skipped addresses. */
  private logSkippedAddresses(skippedAddresses: {
    byron: Cardano.PaymentAddress[];
    pointer: Cardano.PaymentAddress[];
  }): void {
    if (skippedAddresses.byron.length > 0) {
      this.logger.info(
        `Found ${skippedAddresses.byron.length} Byron address(es), falling back to per-address fetching`
      );
    }
    if (skippedAddresses.pointer.length > 0) {
      this.logger.info(
        `Found ${skippedAddresses.pointer.length} Pointer address(es), falling back to per-address fetching`
      );
    }
  }

  /** Logs minimization statistics. */
  private logMinimizationStats(
    totalAddresses: number,
    minimized: { paymentCredentials: Map<unknown, unknown>; rewardAccounts: Map<unknown, unknown> },
    skippedAddresses: { byron: Cardano.PaymentAddress[]; pointer: Cardano.PaymentAddress[] }
  ): void {
    const paymentCredCount = minimized.paymentCredentials.size;
    const rewardAccountCount = minimized.rewardAccounts.size;
    const skippedCount = skippedAddresses.byron.length + skippedAddresses.pointer.length;
    const totalQueries = paymentCredCount + rewardAccountCount + skippedCount;

    this.logger.debug(
      `Minimized ${totalAddresses} address(es) to ${totalQueries} query/queries: ` +
        `${paymentCredCount} payment credential(s), ${rewardAccountCount} reward account(s), ${skippedCount} skipped address(es)`
    );
  }

  /** Fetches transactions for all payment credentials in parallel. */
  private async fetchAllByPaymentCredentials(
    credentials: Map<Cardano.PaymentCredential, Cardano.PaymentAddress[]>,
    pagination?: { count: number; order?: 'asc' | 'desc'; page: number },
    blockRange?: { lowerBound?: number; upperBound?: number }
  ): Promise<BlockfrostTransactionContent[]> {
    const results = await Promise.all(
      [...credentials.keys()].map((credential) =>
        this.fetchTransactionsByPaymentCredential(credential, { blockRange, pagination })
      )
    );
    return results.flat();
  }

  /** Fetches transactions for all reward accounts in parallel. */
  private async fetchAllByRewardAccounts(
    rewardAccounts: Map<Cardano.RewardAccount, Cardano.PaymentAddress[]>,
    pagination?: { count: number; order?: 'asc' | 'desc'; page: number },
    blockRange?: { lowerBound?: number; upperBound?: number }
  ): Promise<BlockfrostTransactionContent[]> {
    const results = await Promise.all(
      [...rewardAccounts.keys()].map((rewardAccount) =>
        this.fetchTransactionsByRewardAccount(rewardAccount, { blockRange, pagination })
      )
    );
    return results.flat();
  }

  /** Fetches transactions for skipped addresses (Byron and Pointer). */
  private async fetchSkippedAddresses(
    skippedAddresses: { byron: Cardano.PaymentAddress[]; pointer: Cardano.PaymentAddress[] },
    pagination?: { count: number; order?: 'asc' | 'desc'; page: number },
    blockRange?: { lowerBound?: number; upperBound?: number },
    limit?: number
  ): Promise<BlockfrostTransactionContent[]> {
    const allSkippedAddresses = [...skippedAddresses.byron, ...skippedAddresses.pointer];
    const results = await Promise.all(
      allSkippedAddresses.map((address) => this.fetchTransactionsByAddress(address, { blockRange, limit, pagination }))
    );
    return results.flat();
  }

  /** Executes the optimized credential-based transaction fetching implementation. */
  private async fetchTransactionsByCredentials(
    addresses: Cardano.PaymentAddress[],
    pagination: TransactionsByAddressesArgs['pagination'],
    blockRange: TransactionsByAddressesArgs['blockRange']
  ): Promise<BlockfrostTransactionContent[]> {
    const addressGroups = extractCredentials(addresses);

    this.logSkippedAddresses(addressGroups.skippedAddresses);

    const minimized = minimizeCredentialSet({
      paymentCredentials: addressGroups.paymentCredentials,
      rewardAccounts: addressGroups.rewardAccounts
    });

    this.logMinimizationStats(addresses.length, minimized, addressGroups.skippedAddresses);

    const paginationOptions = pagination
      ? {
          count: pagination.limit,
          order: pagination.order ?? 'asc',
          page: (pagination.startAt + pagination.limit) / pagination.limit
        }
      : undefined;

    const blockRangeOptions = { lowerBound: blockRange?.lowerBound, upperBound: blockRange?.upperBound };
    const limit = pagination?.limit ?? DB_MAX_SAFE_INTEGER;

    const [paymentTxs, rewardAccountTxs, skippedAddressTxs] = await Promise.all([
      this.fetchAllByPaymentCredentials(minimized.paymentCredentials, paginationOptions, blockRangeOptions),
      this.fetchAllByRewardAccounts(minimized.rewardAccounts, paginationOptions, blockRangeOptions),
      this.fetchSkippedAddresses(addressGroups.skippedAddresses, paginationOptions, blockRangeOptions, limit)
    ]);

    return [...paymentTxs, ...rewardAccountTxs, ...skippedAddressTxs];
  }

  public async transactionsByAddresses({
    addresses,
    pagination,
    blockRange
  }: TransactionsByAddressesArgs): Promise<Paginated<Cardano.HydratedTx>> {
    this.logger.debug(`transactionsByAddresses: ${JSON.stringify(blockRange)} ${JSON.stringify(addresses)}`);

    try {
      const allTransactions = this.queryTxsByCredentials
        ? await this.fetchTransactionsByCredentials(addresses, pagination, blockRange)
        : await this.fetchTransactionsPerAddress(addresses, pagination, blockRange);

      const dedupedSortedTransactionsIds = this.processTransactionResults(
        allTransactions,
        { lowerBound: blockRange?.lowerBound, upperBound: blockRange?.upperBound },
        pagination?.order
      );

      const pageResults = await this.transactionsByHashes({ ids: dedupedSortedTransactionsIds });

      return { pageResults, totalResultCount: dedupedSortedTransactionsIds.length };
    } catch (error) {
      throw this.toProviderError(error);
    }
  }

  private mapTxBody(
    {
      collateralReturn,
      collaterals,
      fee,
      inputs,
      outputs,
      mint,
      proposalProcedures,
      validityInterval,
      votingProcedures,
      withdrawals,
      certificates
    }: Cardano.HydratedTxBody,
    inputSource: Cardano.InputSource
  ) {
    return {
      ...(inputSource === Cardano.InputSource.collaterals
        ? {
            collateralReturn: outputs.length > 0 ? outputs[0] : undefined,
            collaterals: inputs,
            fee: BigInt(0),
            inputs: [],
            outputs: [],
            totalCollateral: fee
          }
        : {
            collateralReturn: collateralReturn ?? undefined,
            collaterals,
            fee,
            inputs,
            outputs
          }),
      certificates,
      mint,
      proposalProcedures,
      validityInterval,
      votingProcedures,
      withdrawals
    };
  }

  private mapBlockHeader({ block, block_height, slot }: Responses['tx_content']): Cardano.PartialBlockHeader {
    return {
      blockNo: Cardano.BlockNo(block_height),
      hash: Cardano.BlockId(block),
      slot: Cardano.Slot(slot)
    };
  }

  private fetchUtxos(id: Cardano.TransactionId): Promise<Schemas['tx_content_utxo']> {
    return this.request<Responses['tx_content_utxo']>(`txs/${id}/utxos`);
  }

  /**
   * Helper to build query string with pagination and block range filters.
   *
   * @param baseEndpoint - The base endpoint (e.g., "addresses/xyz/transactions")
   * @param paginationQueryString - Pagination query string from fetchSequentially
   * @param blockRange - Optional block range filters
   * @param blockRange.lowerBound - Lower bound for block range
   * @param blockRange.upperBound - Upper bound for block range
   * @returns Complete query string with all parameters
   */
  private buildTransactionQueryString(
    baseEndpoint: string,
    paginationQueryString: string,
    blockRange?: { lowerBound?: number; upperBound?: number }
  ): string {
    let queryString = `${baseEndpoint}?${paginationQueryString}`;
    if (blockRange?.lowerBound) queryString += `&from=${blockRange.lowerBound.toString()}`;
    if (blockRange?.upperBound) queryString += `&to=${blockRange.upperBound.toString()}`;
    return queryString;
  }

  /**
   * Fetches transactions for a given address using the fetchSequentially pattern.
   *
   * @param address - The address to fetch transactions for
   * @param options - Options for pagination, block range, and limit
   * @param options.pagination - Pagination options
   * @param options.pagination.count - Number of results per page
   * @param options.pagination.order - Sort order (asc or desc)
   * @param options.pagination.page - Page number
   * @param options.blockRange - Block range filters
   * @param options.blockRange.lowerBound - Lower bound for block range
   * @param options.blockRange.upperBound - Upper bound for block range
   * @param options.limit - Maximum number of transactions to fetch
   * @returns Promise resolving to array of transaction contents
   */
  private async fetchTransactionsByAddress(
    address: Cardano.PaymentAddress,
    options: {
      pagination?: { count: number; order?: 'asc' | 'desc'; page: number };
      blockRange?: { lowerBound?: number; upperBound?: number };
      limit?: number;
    }
  ): Promise<BlockfrostTransactionContent[]> {
    const limit = options.limit ?? DB_MAX_SAFE_INTEGER;

    return fetchSequentially<{ tx_hash: string; tx_index: number; block_height: number }, BlockfrostTransactionContent>(
      {
        haveEnoughItems: options.blockRange?.lowerBound
          ? (transactions) =>
              (transactions.length > 0 &&
                transactions[transactions.length - 1].block_height < options.blockRange!.lowerBound!) ||
              transactions.length >= limit
          : (transactions) => transactions.length >= limit,
        paginationOptions: options.pagination,
        request: (paginationQueryString) => {
          const queryString = this.buildTransactionQueryString(
            `addresses/${address}/transactions`,
            paginationQueryString,
            options.blockRange
          );
          return this.request<Responses['address_transactions_content']>(queryString);
        }
      }
    );
  }

  /**
   * Fetches transactions for a payment credential (bech32: addr_vkh or script).
   *
   * @param credential - Payment credential as bech32 string
   * @param options - Pagination and block range options
   * @param options.pagination - Pagination options
   * @param options.pagination.count - Number of results per page
   * @param options.pagination.order - Sort order (asc or desc)
   * @param options.pagination.page - Page number
   * @param options.blockRange - Block range filters
   * @param options.blockRange.lowerBound - Lower bound for block range
   * @param options.blockRange.upperBound - Upper bound for block range
   * @returns Promise resolving to array of transaction contents
   */
  protected async fetchTransactionsByPaymentCredential(
    credential: Cardano.PaymentCredential,
    options: {
      pagination?: { count: number; order?: 'asc' | 'desc'; page: number };
      blockRange?: { lowerBound?: number; upperBound?: number };
    }
  ): Promise<BlockfrostTransactionContent[]> {
    return fetchSequentially<{ tx_hash: string; tx_index: number; block_height: number }, BlockfrostTransactionContent>(
      {
        haveEnoughItems: () => false, // Fetch all pages
        paginationOptions: options.pagination,
        request: (paginationQueryString) => {
          const queryString = this.buildTransactionQueryString(
            `addresses/${credential}/transactions`,
            paginationQueryString,
            options.blockRange
          );
          return this.request<Responses['address_transactions_content']>(queryString);
        }
      }
    );
  }

  /**
   * Fetches transactions for a reward account (stake address, bech32: stake or stake_test).
   *
   * @param rewardAccount - Reward account (stake address) as bech32 string
   * @param options - Pagination and block range options
   * @param options.pagination - Pagination options
   * @param options.pagination.count - Number of results per page
   * @param options.pagination.order - Sort order (asc or desc)
   * @param options.pagination.page - Page number
   * @param options.blockRange - Block range filters
   * @param options.blockRange.lowerBound - Lower bound for block range
   * @param options.blockRange.upperBound - Upper bound for block range
   * @returns Promise resolving to array of transaction contents
   */
  protected async fetchTransactionsByRewardAccount(
    rewardAccount: Cardano.RewardAccount,
    options: {
      pagination?: { count: number; order?: 'asc' | 'desc'; page: number };
      blockRange?: { lowerBound?: number; upperBound?: number };
    }
  ): Promise<BlockfrostTransactionContent[]> {
    return fetchSequentially<{ tx_hash: string; tx_index: number; block_height: number }, BlockfrostTransactionContent>(
      {
        haveEnoughItems: () => false, // Fetch all pages
        paginationOptions: options.pagination,
        request: (paginationQueryString) => {
          const queryString = this.buildTransactionQueryString(
            `accounts/${rewardAccount}/transactions`,
            paginationQueryString,
            options.blockRange
          );
          // Note: accounts/{stake_address}/transactions returns the same structure as address_transactions_content
          return this.request<Responses['address_transactions_content']>(queryString);
        }
      }
    );
  }

  /**
   * Merges and deduplicates transaction results from multiple sources (payment credentials, reward accounts, skipped addresses).
   *
   * @param paymentTxs Transactions from payment credential queries
   * @param rewardAccountTxs Transactions from reward account (stake address) queries
   * @param skippedAddressTxs Transactions from skipped address queries (Byron, Pointer)
   * @param order Sort order (asc or desc)
   * @returns Sorted and deduplicated array of transaction IDs
   */
  protected mergeAndDeduplicateTransactionResults(
    paymentTxs: BlockfrostTransactionContent[],
    rewardAccountTxs: BlockfrostTransactionContent[],
    skippedAddressTxs: BlockfrostTransactionContent[],
    order: 'asc' | 'desc' = 'asc'
  ): Cardano.TransactionId[] {
    const allTransactions = [...paymentTxs, ...rewardAccountTxs, ...skippedAddressTxs];

    const sortedTransactions = allTransactions.sort(order === 'desc' ? (a, b) => compareTx(b, a) : compareTx);

    return uniq(sortedTransactions.map(({ tx_hash }) => Cardano.TransactionId(tx_hash)));
  }
}
