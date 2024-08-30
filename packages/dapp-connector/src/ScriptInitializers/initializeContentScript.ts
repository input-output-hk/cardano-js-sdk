import { ApiName } from './types';
import { MessengerDependencies, cip30, runContentScriptMessageProxy } from '@cardano-sdk/web-extension';

export interface InitializeContentScriptProps {
  walletName: string;
  injectedScriptSrc: string;
}

// tested in e2e tests
export const initializeContentScript = (
  props: Record<ApiName, InitializeContentScriptProps>,
  dependencies: MessengerDependencies
) => {
  const proxies: any[] = [];

  for (const [apiName, { walletName, injectedScriptSrc }] of Object.entries(props)) {
    const apis = {
      [apiName]: cip30.consumeRemoteWalletApi({ walletName }, dependencies),
      [apiName]: cip30.consumeRemoteAuthenticatorApi({ walletName }, dependencies)
    };

    const proxy = runContentScriptMessageProxy(apis, dependencies.logger);

    const script = document.createElement('script');
    script.async = false;
    script.src = injectedScriptSrc;
    script.addEventListener('load', () => script.remove());
    (document.head || document.documentElement).append(script);

    proxies.push(proxy);
  }
  return proxies;
};
