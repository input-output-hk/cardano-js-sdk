import { authenticator } from './authenticator';
import { cip30 } from '@cardano-sdk/web-extension';
import { logger, walletName } from '../util';
import { runtime } from 'webextension-polyfill';
import { cip30 as walletCip30 } from '@cardano-sdk/wallet';
import { walletReady } from './wallet';

// this should come from remote api
const confirmationCallback: walletCip30.CallbackConfirmation = async () => true;

const walletApi = walletCip30.createWalletApi(walletReady, confirmationCallback, { logger });
cip30.initializeBackgroundScript({ walletName }, { authenticator, logger, runtime, walletApi });
