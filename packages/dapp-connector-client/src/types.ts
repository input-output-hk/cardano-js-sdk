import type { Asset } from '@cardano-sdk/core';
import type { PersonalWalletDependencies } from '@cardano-sdk/wallet';
import type { WalletApiExtension } from '@cardano-sdk/dapp-connector';

export type WalletName = string;
export type WalletId = string;
export type ApiVersion = string;

export type InstalledWallet = {
  apiVersion: ApiVersion;
  supportedExtensions: WalletApiExtension[];
  name: WalletName;
  /** `walletName` in cip30 (window.cardano.[id]) */
  id: WalletId;
  icon: Asset.Uri;
  isEnabled(): Promise<boolean>;
};

export type ConnectWalletDependencies = Omit<
  PersonalWalletDependencies,
  | 'bip32Account'
  | 'witnesser'
  | 'txSubmitProvider'
  | 'utxoProvider'
  | 'addressDiscovery'
  | 'connectionStatusTracker$'
  | 'inputSelector'
  | 'stores'
>;
