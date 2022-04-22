import { initializeInjectedScript } from '@cardano-sdk/cip30';
import { walletName } from './util';

initializeInjectedScript({ icon: '', walletName }, { logger: console });
