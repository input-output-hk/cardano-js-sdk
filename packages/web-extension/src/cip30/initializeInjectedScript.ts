import { Cip30Wallet, injectGlobal } from '@cardano-sdk/dapp-connector';
import { consumeRemoteAuthenticatorApi } from './consumeRemoteAuthenticatorApi.js';
import { consumeRemoteWalletApi } from './consumeRemoteWalletApi.js';
import { injectedRuntime } from '../messaging/index.js';
import type { Logger } from 'ts-log';
import type { MessengerDependencies } from '../messaging/index.js';
import type { WalletProperties } from '@cardano-sdk/dapp-connector';

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
  const wallet = new Cip30Wallet(props, { api: walletApi, authenticator, logger });

  injectGlobal(window, wallet, logger);
};
