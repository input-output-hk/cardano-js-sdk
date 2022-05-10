import { MessengerDependencies, exposeApi } from '../messaging';
import { ObservableWallet } from '@cardano-sdk/wallet';
import { observableWalletChannel, observableWalletProperties } from './util';

export interface ExposeObservableWalletProps {
  wallet: ObservableWallet;
  walletName: string;
}

export const exposeObservableWallet = (
  { wallet, walletName }: ExposeObservableWalletProps,
  dependencies: MessengerDependencies
) =>
  exposeApi(
    {
      api: wallet,
      baseChannel: observableWalletChannel(walletName),
      properties: observableWalletProperties
    },
    dependencies
  );
