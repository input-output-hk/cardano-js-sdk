import { Cip30Wallet, WalletProperties, consumeRemoteWalletApi } from '../WalletApi';
import { Logger, dummyLogger } from 'ts-log';
import { MessengerDependencies, injectedRuntime } from '@cardano-sdk/web-extension';
import { consumeRemoteAuthenticatorApi } from '../AuthenticatorApi';

export interface InitializeInjectedDependencies {
  logger: Logger;
}

export type WindowMaybeWithCardano = Window & { cardano?: { [k: string]: Cip30Wallet } };

export const injectGlobal = (
  window: WindowMaybeWithCardano,
  wallet: Cip30Wallet,
  logger: Logger = dummyLogger
): void => {
  if (!window.cardano) {
    logger.debug(
      {
        module: 'injectWindow',
        wallet: { apiVersion: wallet.apiVersion, icon: wallet.icon, name: wallet.name }
      },
      'Creating cardano global scope'
    );
    window.cardano = {};
  } else {
    logger.debug(
      {
        module: 'injectWindow',
        wallet: { apiVersion: wallet.apiVersion, icon: wallet.icon, name: wallet.name }
      },
      'Cardano global scope exists'
    );
  }
  window.cardano[wallet.name] = window.cardano[wallet.name] || wallet;
  logger.debug(
    {
      module: 'injectWindow',
      wallet: { apiVersion: wallet.apiVersion, icon: wallet.icon, name: wallet.name },
      windowCardano: window.cardano
    },
    'Injected'
  );
};

// tested in web-extension/e2e tests
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
