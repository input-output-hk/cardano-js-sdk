import { Enable, IsEnabled, WalletProperties } from './Wallet';

export interface WalletPublic extends WalletProperties {
  enable: Enable;

  isEnabled: IsEnabled;
}
