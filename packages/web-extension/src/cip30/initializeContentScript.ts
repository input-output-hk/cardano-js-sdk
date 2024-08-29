import { MessengerDependencies, runContentScriptMessageProxy } from '../messaging';
import { consumeRemoteAuthenticatorApi } from './consumeRemoteAuthenticatorApi';
import { consumeRemoteWalletApi } from './consumeRemoteWalletApi';

export interface InitializeContentScriptProps {
  walletName: string;
  injectedScriptSrc: string;
}

// tested in e2e tests
export const initializeContentScript = (
  { injectedScriptSrc, walletName }: InitializeContentScriptProps,
  dependencies: MessengerDependencies
) => {
  // TODO: How to pass both with the channelName as apis {[channelName]: ApiObject}
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
