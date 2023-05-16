import { AddressDiscovery } from '../types';
import { AddressType, AsyncKeyAgent, GroupedAddress } from '@cardano-sdk/key-management';
import { ChainHistoryProvider } from '@cardano-sdk/core';
import uniqBy from 'lodash/uniqBy';

/**
 * By default, we support up to five stake keys in the multi delegation schema.
 */
const DEFAULT_STAKE_KEY_INDEX_LIMIT = 5;

/**
 * Provides a mechanism to discover addresses in Hierarchical Deterministic (HD) wallets
 * by performing a look-ahead search of a specified number of addresses in the following manner:
 *
 * - Derive base addresses with payment credential at index 0 and increasing stake credential until it reaches the given limit.
 * - Derives base addresses with increasing payment credential and stake credential at index 0.
 * - if no transactions are found, increase the gap count.
 * - if there are some transactions, increase the payment credential index and set the gap count to 0.
 * - if the gap count reaches the given lookAheadCount stop the discovery process.
 *
 * Please note that the algorithm works with the transaction history, not balances, so you can have an address with 0 total coins
 * and the algorithm will still continue with discovery if the address was previously used.
 *
 * If the wallet hits gap limit of unused addresses in a row, it expects there are
 * no used addresses beyond this point and stops searching the address chain.
 */
export class HDSequentialDiscovery implements AddressDiscovery {
  readonly #chainHistoryProvider: ChainHistoryProvider;
  readonly #stakeKeyIndexLimit: number;
  readonly #lookAheadCount: number;

  constructor(
    chainHistoryProvider: ChainHistoryProvider,
    lookAheadCount: number,
    stakeKeyIndexLimit: number = DEFAULT_STAKE_KEY_INDEX_LIMIT
  ) {
    this.#stakeKeyIndexLimit = stakeKeyIndexLimit;
    this.#chainHistoryProvider = chainHistoryProvider;
    this.#lookAheadCount = lookAheadCount;
  }

  /**
   * This method performs a look-ahead search of 'n' addresses in the HD wallet using the chain history and
   * the given key agent. The discovered addresses are returned as a list.
   *
   * @param keyAgent The key agent controlling the root key to be used to derive the addresses to be discovered.
   * @returns A promise that will be resolved into a GroupedAddress list containing the discovered addresses.
   */
  public async discover(keyAgent: AsyncKeyAgent): Promise<GroupedAddress[]> {
    let currentGap = 0;
    let currentIndex = 0;
    const addresses = new Array<GroupedAddress>();

    // Add to our known address pool, all possible stake keys combined with payment credential at index 0.
    for (let index = 0; index < this.#stakeKeyIndexLimit; ++index) {
      const address = await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, index, true);
      addresses.push(address);
    }

    // Search for all base addresses composed with the stake key at index 0. We are assuming this is
    // the use case with multi address wallets.
    while (currentGap <= this.#lookAheadCount) {
      const address = await keyAgent.deriveAddress({ index: currentIndex, type: AddressType.External }, 0, true);

      // We could fetch transactions from multiple addresses in a single query and then parse/organize the results, however, if these addresses
      // contain huge transaction history we may get stuck retrieving all the transactions for longer than we can just query each address individually.
      const txs = await this.#chainHistoryProvider.transactionsByAddresses({
        addresses: [address.address],
        pagination: {
          limit: 1,
          startAt: 0
        }
      });

      if (txs.totalResultCount > 0) {
        currentGap = 0;
        addresses.push(address);
      } else {
        ++currentGap;
      }

      ++currentIndex;
    }

    const result = uniqBy(addresses, 'address');

    // We need to make sure the addresses are sorted since the wallet assumes that the first address
    // in the list is the change address (payment cred 0 and stake cred 0).
    result.sort((a, b) => a.index - b.index || a.stakeKeyDerivationPath!.index - b.stakeKeyDerivationPath!.index);
    await keyAgent.setKnownAddresses(result);

    return result;
  }
}
