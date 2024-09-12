import { GroupedAddress } from '@cardano-sdk/key-management';

/**
 * Sorts an array of addresses by their primary index and, if available, by the
 * index of their stakeKeyDerivationPath.
 *
 * @param addresses - The array of addresses to sort.
 * @returns A new sorted array of addresses.
 */
export const sortAddresses = (addresses: GroupedAddress[]): GroupedAddress[] =>
  [...addresses].sort((a, b) => {
    if (a.index !== b.index) {
      return a.index - b.index;
    }

    if (a.stakeKeyDerivationPath && b.stakeKeyDerivationPath) {
      return a.stakeKeyDerivationPath.index - b.stakeKeyDerivationPath.index;
    }

    if (a.stakeKeyDerivationPath && !b.stakeKeyDerivationPath) {
      return -1;
    }

    if (!a.stakeKeyDerivationPath && b.stakeKeyDerivationPath) {
      return 1;
    }

    return 0;
  });
