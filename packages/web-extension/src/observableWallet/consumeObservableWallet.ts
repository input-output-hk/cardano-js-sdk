import '@cardano-sdk/util';
import '@cardano-sdk/wallet';
import { MessengerDependencies, consumeRemoteApi } from '../messaging';
import { observableWalletChannel, observableWalletProperties } from './util';

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
