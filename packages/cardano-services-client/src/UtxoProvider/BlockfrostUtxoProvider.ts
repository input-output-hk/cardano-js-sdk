import { BlockfrostClient, BlockfrostProvider, BlockfrostToCore, fetchSequentially } from '../blockfrost';
import { Cardano, Serialization, UtxoByAddressesArgs, UtxoProvider } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { createPaymentCredentialFilter, extractCredentials, minimizeCredentialSet } from '../credentialUtils';
import uniqBy from 'lodash/uniqBy.js';
import type { Cache } from '@cardano-sdk/util';
import type { Responses } from '@blockfrost/blockfrost-js';

interface BlockfrostUtxoProviderOptions {
  queryUtxosByCredentials?: boolean;
}

interface BlockfrostUtxoProviderDependencies {
  client: BlockfrostClient;
  cache: Cache<Cardano.Tx>;
  logger: Logger;
}

export class BlockfrostUtxoProvider extends BlockfrostProvider implements UtxoProvider {
  private readonly cache: Cache<Cardano.Tx>;
  // Feature flag to enable credential-based UTXO fetching (used in utxoByAddresses)
  protected readonly queryUtxosByCredentials: boolean;

  // Overload 1: Old signature (backward compatibility)
  constructor(dependencies: BlockfrostUtxoProviderDependencies);

  // Overload 2: New signature with options
  constructor(options: BlockfrostUtxoProviderOptions, dependencies: BlockfrostUtxoProviderDependencies);

  // Implementation signature
  constructor(
    optionsOrDependencies: BlockfrostUtxoProviderOptions | BlockfrostUtxoProviderDependencies,
    maybeDependencies?: BlockfrostUtxoProviderDependencies
  ) {
    // Detect which overload was used
    const isOldSignature = 'cache' in optionsOrDependencies;
    const options = isOldSignature ? {} : (optionsOrDependencies as BlockfrostUtxoProviderOptions);
    const dependencies = isOldSignature
      ? (optionsOrDependencies as BlockfrostUtxoProviderDependencies)
      : maybeDependencies!;

    super(dependencies.client, dependencies.logger);
    this.cache = dependencies.cache;
    this.queryUtxosByCredentials = options.queryUtxosByCredentials ?? false;
  }

  protected async fetchUtxos(addr: Cardano.PaymentAddress, paginationQueryString: string): Promise<Cardano.Utxo[]> {
    const queryString = `addresses/${addr.toString()}/utxos?${paginationQueryString}`;
    const utxos = await this.request<Responses['address_utxo_content']>(queryString);

    const utxoPromises = utxos.map((utxo) =>
      this.fetchDetailsFromCBOR(utxo.tx_hash).then((tx) => {
        const txOut = tx ? tx.body.outputs.find((output) => output.address === utxo.address) : undefined;
        return BlockfrostToCore.addressUtxoContent(addr.toString(), utxo, txOut);
      })
    );
    return Promise.all(utxoPromises);
  }

  private async processUtxoContents(utxoContents: Responses['address_utxo_content']): Promise<Cardano.Utxo[]> {
    const utxoPromises = utxoContents.map((utxo) =>
      this.fetchDetailsFromCBOR(utxo.tx_hash).then((tx) => {
        const txOut = tx ? tx.body.outputs.find((output) => output.address === utxo.address) : undefined;
        return BlockfrostToCore.addressUtxoContent(utxo.address, utxo, txOut);
      })
    );
    return Promise.all(utxoPromises);
  }

  protected async fetchUtxosByPaymentCredential(credential: Cardano.PaymentCredential): Promise<Cardano.Utxo[]> {
    const utxoContents = await fetchSequentially<
      Responses['address_utxo_content'][0],
      Responses['address_utxo_content'][0]
    >({
      haveEnoughItems: () => false, // Fetch all pages
      request: async (paginationQueryString) => {
        const queryString = `addresses/${credential}/utxos?${paginationQueryString}`;
        return this.request<Responses['address_utxo_content']>(queryString);
      }
    });

    return this.processUtxoContents(utxoContents);
  }

  protected async fetchUtxosByRewardAccount(
    rewardAccount: Cardano.RewardAccount,
    paymentCredentialFilter: (address: Cardano.PaymentAddress) => boolean
  ): Promise<Cardano.Utxo[]> {
    const utxoContents = await fetchSequentially<
      Responses['address_utxo_content'][0],
      Responses['address_utxo_content'][0]
    >({
      haveEnoughItems: () => false, // Fetch all pages
      request: async (paginationQueryString) => {
        const queryString = `accounts/${rewardAccount}/utxos?${paginationQueryString}`;
        return this.request<Responses['address_utxo_content']>(queryString);
      }
    });

    // Filter UTXOs by payment credential before processing
    const filteredUtxos = utxoContents.filter((utxo) => paymentCredentialFilter(Cardano.PaymentAddress(utxo.address)));

    // Log debug message about filtering
    if (filteredUtxos.length < utxoContents.length) {
      this.logger.debug(
        `Filtered ${utxoContents.length - filteredUtxos.length} UTXO(s) from reward account query, kept ${
          filteredUtxos.length
        }`
      );
    }

    return this.processUtxoContents(filteredUtxos);
  }

  protected mergeAndDeduplicateUtxos(
    paymentUtxos: Cardano.Utxo[],
    rewardAccountUtxos: Cardano.Utxo[],
    skippedAddressUtxos: Cardano.Utxo[]
  ): Cardano.Utxo[] {
    const allUtxos = [...paymentUtxos, ...rewardAccountUtxos, ...skippedAddressUtxos];

    // Deduplicate by txId + index combination
    const deduplicated = uniqBy(allUtxos, (utxo: Cardano.Utxo) => `${utxo[0].txId}#${utxo[0].index}`);

    // Sort by txId and index for deterministic ordering
    return deduplicated.sort((a, b) => {
      const txIdCompare = a[0].txId.localeCompare(b[0].txId);
      if (txIdCompare !== 0) return txIdCompare;
      return a[0].index - b[0].index;
    });
  }

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

  private async fetchAllByPaymentCredentials(
    credentials: Map<Cardano.PaymentCredential, Cardano.PaymentAddress[]>
  ): Promise<Cardano.Utxo[]> {
    const results = await Promise.all(
      [...credentials.keys()].map((credential) => this.fetchUtxosByPaymentCredential(credential))
    );
    return results.flat();
  }

  private async fetchAllByRewardAccounts(
    rewardAccounts: Map<Cardano.RewardAccount, Cardano.PaymentAddress[]>,
    paymentCredentialFilter: (address: Cardano.PaymentAddress) => boolean
  ): Promise<Cardano.Utxo[]> {
    const results = await Promise.all(
      [...rewardAccounts.keys()].map((rewardAccount) =>
        this.fetchUtxosByRewardAccount(rewardAccount, paymentCredentialFilter)
      )
    );
    return results.flat();
  }

  private async fetchUtxosForAddresses(addresses: Cardano.PaymentAddress[]): Promise<Cardano.Utxo[]> {
    const results = await Promise.all(
      addresses.map((address) =>
        fetchSequentially<Cardano.Utxo, Cardano.Utxo>({
          request: async (paginationQueryString) => await this.fetchUtxos(address, paginationQueryString)
        })
      )
    );
    return results.flat();
  }

  private async fetchSkippedAddresses(skippedAddresses: {
    byron: Cardano.PaymentAddress[];
    pointer: Cardano.PaymentAddress[];
  }): Promise<Cardano.Utxo[]> {
    const allSkippedAddresses = [...skippedAddresses.byron, ...skippedAddresses.pointer];
    return this.fetchUtxosForAddresses(allSkippedAddresses);
  }

  private async fetchUtxosByCredentials(addresses: Cardano.PaymentAddress[]): Promise<Cardano.Utxo[]> {
    const addressGroups = extractCredentials(addresses);

    this.logSkippedAddresses(addressGroups.skippedAddresses);

    const minimized = minimizeCredentialSet({
      paymentCredentials: addressGroups.paymentCredentials,
      rewardAccounts: addressGroups.rewardAccounts
    });

    this.logMinimizationStats(addresses.length, minimized, addressGroups.skippedAddresses);

    const paymentCredentialFilter = createPaymentCredentialFilter(addresses);

    this.logger.debug(
      `Fetching UTXOs for ${minimized.paymentCredentials.size} payment credential(s) and ${minimized.rewardAccounts.size} reward account(s)`
    );

    const [paymentUtxos, rewardAccountUtxos, skippedAddressUtxos] = await Promise.all([
      this.fetchAllByPaymentCredentials(minimized.paymentCredentials),
      this.fetchAllByRewardAccounts(minimized.rewardAccounts, paymentCredentialFilter),
      this.fetchSkippedAddresses(addressGroups.skippedAddresses)
    ]);

    const result = this.mergeAndDeduplicateUtxos(paymentUtxos, rewardAccountUtxos, skippedAddressUtxos);

    this.logger.debug(`Merged results: ${result.length} UTXO(s)`);

    return result;
  }

  async fetchCBOR(hash: string): Promise<string> {
    return this.request<Responses['tx_content_cbor']>(`txs/${hash}/cbor`)
      .then((response) => {
        if (response.cbor) return response.cbor;
        throw new Error('CBOR is null');
      })
      .catch((_error) => {
        throw new Error('CBOR fetch failed');
      });
  }
  protected async fetchDetailsFromCBOR(hash: string) {
    const cached = await this.cache.get(hash);
    if (cached) return cached;

    const result = await this.fetchCBOR(hash)
      .then((cbor) => {
        const tx = Serialization.Transaction.fromCbor(Serialization.TxCBOR(cbor)).toCore();
        this.logger.debug('Fetched details from CBOR for tx', hash);
        return tx;
      })
      .catch((error) => {
        this.logger.warn('Failed to fetch details from CBOR for tx', hash, error);
        return null;
      });

    if (!result) {
      return null;
    }

    void this.cache.set(hash, result);
    return result;
  }

  /**
   * Retrieves UTXOs for the given addresses.
   *
   * Important assumption: All addresses provided must be addresses where the caller
   * controls the payment credential. When queryUtxosByCredentials is enabled, this
   * provider queries by reward accounts (stake addresses) and filters results to only
   * include UTXOs with payment credentials extracted from the input addresses. UTXOs
   * with payment credentials not present in the input will be excluded.
   */
  public async utxoByAddresses({ addresses }: UtxoByAddressesArgs): Promise<Cardano.Utxo[]> {
    try {
      // If feature flag is disabled, use original implementation
      if (!this.queryUtxosByCredentials) {
        return this.fetchUtxosForAddresses(addresses);
      }

      // Use credential-based fetching
      return await this.fetchUtxosByCredentials(addresses);
    } catch (error) {
      throw this.toProviderError(error);
    }
  }
}
