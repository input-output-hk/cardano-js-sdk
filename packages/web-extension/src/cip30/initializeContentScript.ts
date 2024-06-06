import { consumeRemoteAuthenticatorApi } from './consumeRemoteAuthenticatorApi.js';
import { consumeRemoteWalletApi } from './consumeRemoteWalletApi.js';
import { runContentScriptMessageProxy } from '../messaging/index.js';
import type { MessengerDependencies } from '../messaging/index.js';

export interface InitializeContentScriptProps {
  walletName: string;
  injectedScriptSrc: string;
}

// tested in e2e tests
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
