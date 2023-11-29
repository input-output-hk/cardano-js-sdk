import { AddressDiscovery } from '../types';
import { AddressType, GroupedAddress, util } from '@cardano-sdk/key-management';

/**
 * Discovers the first address in the derivation chain (both payment and stake credentials) without looking at the
 * chain history.
 */
export class SingleAddressDiscovery implements AddressDiscovery {
  public async discover(manager: util.Bip32Ed25519AddressManager): Promise<GroupedAddress[]> {
    const address = await manager.deriveAddress({ index: 0, type: AddressType.External }, 0);
    return [address];
  }
}
