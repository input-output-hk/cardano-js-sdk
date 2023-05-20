import { GroupedAddress } from '@cardano-sdk/key-management';
import { PersonalWallet } from '@cardano-sdk/wallet';

/**
 * The context variables shared between all the hooks.
 */
export interface WalletVars {
  walletLoads: number;
  addresses: GroupedAddress[];
  currentWallet: PersonalWallet;
}

export interface AddressesModel {
  tx_count: number;
  address: string;
  stake_address: string;
}
