// tested in web-extension/e2e tests
import { AuthenticatorApi, exposeAuthenticatorApi } from '../AuthenticatorApi';
import { Logger } from 'ts-log';
import { Runtime } from 'webextension-polyfill';
import { WalletApi, WalletName, exposeWalletApi } from '../WalletApi';

export interface InitializeBackgroundScriptProps {
  walletName: WalletName;
}

export interface InitializeBackgroundScriptDependencies {
  logger: Logger;
  runtime: Runtime.Static;
  authenticator: AuthenticatorApi;
  walletApi: WalletApi;
}

export const initializeBackgroundScript = (
  props: InitializeBackgroundScriptProps,
  dependencies: InitializeBackgroundScriptDependencies
) => {
  const authenticator = exposeAuthenticatorApi(props, dependencies);
  const wallet = exposeWalletApi(props, dependencies);
  return () => {
    wallet.unsubscribe();
    authenticator.unsubscribe();
  };
};
