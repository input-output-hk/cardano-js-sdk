import { RemoteApiProperties, RemoteApiPropertyType } from '../messaging';
import { WalletManagerApi, WalletManagerProps } from './walletManager.types';

export const walletManagerChannel = (walletName: WalletManagerProps['walletName']) => `${walletName}-wallet-manager`;
export const walletChannel = (walletName: WalletManagerProps['walletName']) =>
  `${walletManagerChannel(walletName)}-wallet`;

export const walletManagerProperties: RemoteApiProperties<WalletManagerApi> = {
  activate: RemoteApiPropertyType.MethodReturningPromise,
  clearStore: RemoteApiPropertyType.MethodReturningPromise,
  deactivate: RemoteApiPropertyType.MethodReturningPromise
};
