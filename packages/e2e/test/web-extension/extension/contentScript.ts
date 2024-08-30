import { ApiName, initializeContentScript } from '@cardano-sdk/dapp-connector';
import { apiName, walletName } from './const';
import { runtime } from 'webextension-polyfill';

initializeContentScript(
  { [ApiName(apiName)]: { injectedScriptSrc: runtime.getURL('injectedScript.js'), walletName } },
  { logger: console, runtime }
);
