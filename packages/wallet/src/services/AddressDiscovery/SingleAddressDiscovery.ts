import { AddressType } from '@cardano-sdk/key-management';
import type { AddressDiscovery } from '../types.js';
import type { Bip32Account, GroupedAddress } from '@cardano-sdk/key-management';

/**
 * Discovers the first address in the derivation chain (both payment and stake credentials) without looking at the
 * chain history.
 */
export class SingleAddressDiscovery implements AddressDiscovery {
  public async discover(manager: Bip32Account): Promise<GroupedAddress[]> {
    const address = await manager.deriveAddress({ index: 0, type: AddressType.External }, 0);
    return [address];
  }
}
