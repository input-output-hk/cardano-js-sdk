import { ApiName, initializeInjectedScript } from '@cardano-sdk/dapp-connector';
import { apiName, walletName } from './const';

initializeInjectedScript({ [ApiName(apiName)]: { icon: '', walletName } }, { logger: console });
