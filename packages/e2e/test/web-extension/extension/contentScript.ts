import { cip30 } from '@cardano-sdk/web-extension';
import { runtime } from 'webextension-polyfill';
import { walletName } from './const.js';

cip30.initializeContentScript(
  { injectedScriptSrc: runtime.getURL('injectedScript.js'), walletName },
  { logger: console, runtime }
);
