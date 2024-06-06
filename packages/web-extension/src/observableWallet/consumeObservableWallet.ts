import { consumeRemoteApi } from '../messaging/index.js';
import { observableWalletChannel, observableWalletProperties } from './util.js';
import type { MessengerDependencies } from '../messaging/index.js';

export interface ConsumeObservableWalletProps {
  walletName: string;
}

export const consumeObservableWallet = (
  { walletName }: ConsumeObservableWalletProps,
  dependencies: MessengerDependencies
) =>
  consumeRemoteApi(
    {
      baseChannel: observableWalletChannel(walletName),
      properties: observableWalletProperties
    },
    dependencies
  );
