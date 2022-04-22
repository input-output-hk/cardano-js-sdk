import { initializeContentScript } from '@cardano-sdk/cip30';
import { runtime } from 'webextension-polyfill';
import { walletName } from './util';

initializeContentScript(
  { injectedScriptSrc: runtime.getURL('injectedScript.js'), walletName },
  { logger: console, runtime }
);
