import { BaseWallet } from '@cardano-sdk/wallet';
import { GroupedAddress } from '@cardano-sdk/key-management';

/** The context variables shared between all the hooks. */
export interface WalletVars {
  walletLoads: number;
  addresses: GroupedAddress[];
  currentWallet: BaseWallet;
}

export interface AddressesModel {
  tx_count: number;
  address: string;
  stake_address: string;
}
