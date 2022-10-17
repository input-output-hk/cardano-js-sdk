import { CSL } from './CSL';
import { ManagedFreeableScope } from '@cardano-sdk/util';

/**
 * Parse Cardano address from all Cardano eras and networks
 */
export const parseCslAddress = (scope: ManagedFreeableScope, input: string): CSL.Address | null => {
  try {
    return scope.manage(CSL.Address.from_bech32(input));
  } catch {
    try {
      return scope.manage(CSL.ByronAddress.from_base58(input).to_address());
    } catch {
      return null;
    }
  }
};
