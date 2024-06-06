import { cip30 } from '@cardano-sdk/web-extension';
import { runtime } from 'webextension-polyfill';
import { cip30 as walletCip30 } from '@cardano-sdk/wallet';

import { authenticator } from './authenticator.js';
import { logger } from '../util.js';
import { wallet$ } from './walletManager.js';
import { walletName } from '../const.js';

// this should come from remote api
const confirmationCallback: walletCip30.CallbackConfirmation = {
  signData: async ({ sender }) => {
    if (!sender) throw new Error('No sender context');
    logger.info('signData request from', sender);
    return true;
  },
  signTx: async ({ sender }) => {
    if (!sender) throw new Error('No sender context');
    logger.info('signTx request', sender);
    return true;
  },
  submitTx: async () => true
};

const walletApi = walletCip30.createWalletApi(wallet$, confirmationCallback, { logger });
cip30.initializeBackgroundScript({ walletName }, { authenticator, logger, runtime, walletApi });
