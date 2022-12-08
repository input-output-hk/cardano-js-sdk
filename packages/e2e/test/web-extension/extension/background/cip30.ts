import { cip30 } from '@cardano-sdk/web-extension';
import { runtime } from 'webextension-polyfill';
import { cip30 as walletCip30 } from '@cardano-sdk/wallet';

import { authenticator } from './authenticator';
import { logger } from '../util';
import { wallet$ } from './walletManager';
import { walletName } from '../const';

// this should come from remote api
const confirmationCallback: walletCip30.CallbackConfirmation = async () => true;

const walletApi = walletCip30.createWalletApi(wallet$, confirmationCallback, { logger });
cip30.initializeBackgroundScript({ walletName }, { authenticator, logger, runtime, walletApi });
