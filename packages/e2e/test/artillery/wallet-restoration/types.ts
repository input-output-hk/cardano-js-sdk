import { GroupedAddress } from '@cardano-sdk/key-management';
import { SingleAddressWallet } from '@cardano-sdk/wallet';

/**
 * The context variables shared between all the hooks.
 */
export interface WalletVars {
  walletsCount: number;
  addresses: GroupedAddress[];
  currentWallet: SingleAddressWallet;
}

export interface AddressesModel {
  address: string;
  stake_address: string;
}
