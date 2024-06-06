import { cip30 } from '@cardano-sdk/web-extension';
import { walletName } from './const.js';

cip30.initializeInjectedScript({ icon: '', walletName }, { logger: console });
