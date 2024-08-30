import { ApiName } from './types';
import { Cip30Wallet, WalletProperties } from '../WalletApi';
import { Logger } from 'ts-log';
import { MessengerDependencies, cip30, createInjectedRuntime } from '@cardano-sdk/web-extension';
import { injectGlobal } from '../injectGlobal';

export interface InitializeInjectedDependencies {
  logger: Logger;
}

// tested in e2e tests
export const initializeInjectedScript = (
  props: Record<ApiName, WalletProperties>,
  { logger }: InitializeInjectedDependencies
) => {
  for (const [apiName, walletProps] of Object.entries(props)) {
    const dependencies: MessengerDependencies = {
      logger,
      runtime: createInjectedRuntime(apiName)
    };

    const authenticator = cip30.consumeRemoteAuthenticatorApi(walletProps, dependencies);
    const walletApi = cip30.consumeRemoteWalletApi(walletProps, dependencies);
    const wallet = new Cip30Wallet(walletProps, { api: walletApi, authenticator, logger });

    injectGlobal(window, wallet, logger);
  }
};
