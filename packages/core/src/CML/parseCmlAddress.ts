import { CML } from './CML';
import { ManagedFreeableScope } from '@cardano-sdk/util';

/**
 * Parse Cardano address from all Cardano eras and networks
 */
export const parseCmlAddress = (scope: ManagedFreeableScope, input: string): CML.Address | null => {
  try {
    return scope.manage(CML.Address.from_bech32(input));
  } catch {
    try {
      return scope.manage(scope.manage(CML.ByronAddress.from_base58(input)).to_address());
    } catch {
      return null;
    }
  }
};
