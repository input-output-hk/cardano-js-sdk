import { AuthenticatorApi, WalletApi, WalletName } from '@cardano-sdk/dapp-connector';
import { Logger } from 'ts-log';
import { Runtime } from 'webextension-polyfill';
import { exposeAuthenticatorApi } from './exposeAuthenticatorApi';
import { exposeWalletApi } from './exposeWalletApi';

export interface InitializeBackgroundScriptProps {
  walletName: WalletName;
}

export interface InitializeBackgroundScriptDependencies {
  logger: Logger;
  runtime: Runtime.Static;
  authenticator: AuthenticatorApi;
  walletApi: WalletApi;
}

// tested in e2e tests
export const initializeBackgroundScript = (
  props: InitializeBackgroundScriptProps,
  dependencies: InitializeBackgroundScriptDependencies
) => {
  const authenticator = exposeAuthenticatorApi(props, dependencies);
  const wallet = exposeWalletApi(props, dependencies);
  return () => {
    wallet.shutdown();
    authenticator.shutdown();
  };
};
