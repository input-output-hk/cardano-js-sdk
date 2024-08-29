import { Cip30Wallet, WalletProperties, injectGlobal } from '@cardano-sdk/dapp-connector';
import { Logger } from 'ts-log';
import { MessengerDependencies, createInjectedRuntime } from '../messaging';
import { consumeRemoteAuthenticatorApi } from './consumeRemoteAuthenticatorApi';
import { consumeRemoteWalletApi } from './consumeRemoteWalletApi';

export interface InitializeInjectedDependencies {
  logger: Logger;
}

// tested in e2e tests
// TODO: Should I create two different initialize Injected script functions? One for single API and another for multi-api
export const initializeInjectedScript = (
  props: Record<string, WalletProperties>,
  { logger }: InitializeInjectedDependencies
) => {
  for (const [channelName, walletProps] of Object.entries(props)) {
    const dependencies: MessengerDependencies = {
      logger,
      runtime: createInjectedRuntime(channelName)
    };

    const authenticator = consumeRemoteAuthenticatorApi(walletProps, dependencies);
    const walletApi = consumeRemoteWalletApi(walletProps, dependencies);
    const wallet = new Cip30Wallet(walletProps, { api: walletApi, authenticator, logger });

    injectGlobal(window, wallet, logger);
  }
};
