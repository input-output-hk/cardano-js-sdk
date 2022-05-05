// tested in web-extension/e2e tests
import { MessengerDependencies, runContentScriptMessageProxy } from '@cardano-sdk/web-extension';
import { consumeRemoteAuthenticatorApi } from '../AuthenticatorApi';
import { consumeRemoteWalletApi } from '../WalletApi';

export interface InitializeContentScriptProps {
  walletName: string;
  injectedScriptSrc: string;
}

export const initializeContentScript = (
  { injectedScriptSrc, walletName }: InitializeContentScriptProps,
  dependencies: MessengerDependencies
) => {
  const apis = [
    consumeRemoteAuthenticatorApi({ walletName }, dependencies),
    consumeRemoteWalletApi({ walletName }, dependencies)
  ];
  const proxy = runContentScriptMessageProxy(apis, dependencies.logger);

  const script = document.createElement('script');
  script.async = false;
  script.src = injectedScriptSrc;
  script.addEventListener('load', () => script.remove());
  (document.head || document.documentElement).append(script);

  return proxy;
};
