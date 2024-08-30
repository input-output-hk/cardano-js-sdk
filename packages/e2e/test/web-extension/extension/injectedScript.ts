import { apiName, walletName } from './const';
import { initializeInjectedScript } from '@cardano-sdk/dapp-connector';

initializeInjectedScript({ [apiName]: { icon: '', walletName } }, { logger: console });
