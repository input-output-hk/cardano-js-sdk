import { cip30 } from '@cardano-sdk/web-extension';
import { runtime } from 'webextension-polyfill';
import { cip30 as walletCip30 } from '@cardano-sdk/wallet';

import { NEVER } from 'rxjs';
import { authenticator } from './authenticator';
import { logger } from '../util';
import { wallet$ } from './walletManager';
import { walletName } from '../const';

// this should come from remote api
const confirmationCallback: walletCip30.CallbackConfirmation = {
  signData: async ({ sender }) => {
    if (!sender) throw new Error('No sender context');
    logger.info('signData request from', sender);
    return { cancel$: NEVER };
  },
  signTx: async ({ sender }) => {
    if (!sender) throw new Error('No sender context');
    logger.info('signTx request', sender);
    return { cancel$: NEVER };
  },
  submitTx: async () => true
};

const walletApi = walletCip30.createWalletApi(wallet$, confirmationCallback, { logger });
cip30.initializeBackgroundScript({ walletName }, { authenticator, logger, runtime, walletApi });
