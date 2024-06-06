import { exposeApi } from '../messaging/index.js';
import { observableWalletChannel, observableWalletProperties } from './util.js';
import { of } from 'rxjs';
import type { MessengerDependencies } from '../messaging/index.js';
import type { ObservableWallet } from '@cardano-sdk/wallet';

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
      api$: of(wallet),
      baseChannel: observableWalletChannel(walletName),
      properties: observableWalletProperties
    },
    dependencies
  );
