import { AccountAddressDerivationPath, AddressType, Bip32Account, GroupedAddress } from '@cardano-sdk/key-management';
import { AddressDiscovery } from '../types';
import { ChainHistoryProvider } from '@cardano-sdk/core';
import uniqBy from 'lodash/uniqBy';

const STAKE_KEY_INDEX_LOOKAHEAD = 5;

/**
 * Gets whether the given address has a transaction history.
 *
 * @param address The address to query.
 * @param chainHistoryProvider The chain history provider where to fetch the history from.
 */
const addressHasTx = async (address: GroupedAddress, chainHistoryProvider: ChainHistoryProvider): Promise<boolean> => {
  const txs = await chainHistoryProvider.transactionsByAddresses({
    addresses: [address.address],
    pagination: {
      limit: 1,
      startAt: 0
    }
  });

  return txs.totalResultCount > 0;
};

/**
 * Search for all base addresses composed with the given payment and stake credentials.
 *
 * @param account The bip32 account to be used to derive the addresses to be discovered.
 * @param chainHistoryProvider The chain history provider.
 * @param lookAheadCount Number down the derivation chain to be searched for.
 * @param getDeriveAddressArgs Callback that retrieves the derivation path arguments.
 * @returns A promise that will be resolved into a GroupedAddress list containing the discovered addresses.
 */
const discoverAddresses = async (
  account: Bip32Account,
  chainHistoryProvider: ChainHistoryProvider,
  lookAheadCount: number,
  getDeriveAddressArgs: (
    index: number,
    type: AddressType
  ) => {
    paymentKeyDerivationPath: AccountAddressDerivationPath;
    stakeKeyDerivationIndex: number;
  }
): Promise<GroupedAddress[]> => {
  let currentGap = 0;
  let currentIndex = 0;
  const addresses = new Array<GroupedAddress>();

  while (currentGap <= lookAheadCount) {
    const externalAddressArgs = getDeriveAddressArgs(currentIndex, AddressType.External);
    const internalAddressArgs = getDeriveAddressArgs(currentIndex, AddressType.Internal);

    const externalAddress = await account.deriveAddress(
      externalAddressArgs.paymentKeyDerivationPath,
      externalAddressArgs.stakeKeyDerivationIndex
    );

    const internalAddress = await account.deriveAddress(
      internalAddressArgs.paymentKeyDerivationPath,
      internalAddressArgs.stakeKeyDerivationIndex
    );

    const externalHasTx = await addressHasTx(externalAddress, chainHistoryProvider);
    const internalHasTx = await addressHasTx(internalAddress, chainHistoryProvider);

    if (externalHasTx) addresses.push(externalAddress);
    if (internalHasTx) addresses.push(internalAddress);

    if (externalHasTx || internalHasTx) {
      currentGap = 0;
    } else {
      ++currentGap;
    }

    ++currentIndex;
  }

  return addresses;
};

/**
 * Provides a mechanism to discover addresses in Hierarchical Deterministic (HD) wallets
 * by performing a look-ahead search of a specified number of addresses in the following manner:
 *
 * - Derive base addresses with payment credential at index 0 and increasing stake credential until it reaches the given limit.
 * - Derives base addresses with increasing payment credential and stake credential at index 0.
 * - if no transactions are found for both internal and external address type, increase the gap count.
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
  readonly #lookAheadCount: number;

  constructor(chainHistoryProvider: ChainHistoryProvider, lookAheadCount: number) {
    this.#chainHistoryProvider = chainHistoryProvider;
    this.#lookAheadCount = lookAheadCount;
  }

  /**
   * This method performs a look-ahead search of 'n' addresses in the HD wallet using the chain history and
   * the given key agent. The discovered addresses are returned as a list.
   *
   * @param manager The address manager be used to derive the addresses to be discovered.
   * @returns A promise that will be resolved into a GroupedAddress list containing the discovered addresses.
   */
  public async discover(manager: Bip32Account): Promise<GroupedAddress[]> {
    const firstAddresses = [await manager.deriveAddress({ index: 0, type: AddressType.External }, 0)];
    const firstInternalAddress = await manager.deriveAddress({ index: 0, type: AddressType.Internal }, 0);
    if (await addressHasTx(firstInternalAddress, this.#chainHistoryProvider)) {
      firstAddresses.push(firstInternalAddress);
    }

    const stakeKeyAddresses = await discoverAddresses(
      manager,
      this.#chainHistoryProvider,
      STAKE_KEY_INDEX_LOOKAHEAD,
      (currentIndex, type) => ({
        paymentKeyDerivationPath: {
          index: 0,
          type
        },
        // We are going to offset this by 1, since we already know about the first address.
        stakeKeyDerivationIndex: currentIndex + 1
      })
    );

    const paymentKeyAddresses = await discoverAddresses(
      manager,
      this.#chainHistoryProvider,
      this.#lookAheadCount,
      (currentIndex, type) => ({
        paymentKeyDerivationPath: {
          // We are going to offset this by 1, since we already know about the first address.
          index: currentIndex + 1,
          type
        },
        stakeKeyDerivationIndex: 0
      })
    );

    const addresses = uniqBy([...firstAddresses, ...stakeKeyAddresses, ...paymentKeyAddresses], 'address');

    // We need to make sure the addresses are sorted since the wallet assumes that the first address
    // in the list is the change address (payment cred 0 and stake cred 0).
    return addresses.sort(
      (a, b) => a.index - b.index || a.stakeKeyDerivationPath!.index - b.stakeKeyDerivationPath!.index
    );
  }
}
