import { Cip30Wallet, WalletProperties, injectGlobal } from '@cardano-sdk/cip30';
import { Logger } from 'ts-log';
import { MessengerDependencies, injectedRuntime } from '../messaging';
import { consumeRemoteAuthenticatorApi } from './consumeRemoteAuthenticatorApi';
import { consumeRemoteWalletApi } from './consumeRemoteWalletApi';

export interface InitializeInjectedDependencies {
  logger: Logger;
}

// tested in e2e tests
export const initializeInjectedScript = (props: WalletProperties, { logger }: InitializeInjectedDependencies) => {
  const dependencies: MessengerDependencies = {
    logger,
    runtime: injectedRuntime
  };

  const authenticator = consumeRemoteAuthenticatorApi(props, dependencies);
  const walletApi = consumeRemoteWalletApi(props, dependencies);
  const wallet = new Cip30Wallet(props, { api: walletApi, authenticator });

  injectGlobal(window, wallet);
};
