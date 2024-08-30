import { apiName, walletName } from './const';
import { initializeContentScript } from '@cardano-sdk/dapp-connector';
import { runtime } from 'webextension-polyfill';

initializeContentScript(
  { [apiName]: { injectedScriptSrc: runtime.getURL('injectedScript.js'), walletName } },
  { logger: console, runtime }
);
