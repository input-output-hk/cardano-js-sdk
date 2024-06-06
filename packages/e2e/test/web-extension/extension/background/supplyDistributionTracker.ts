import { createSupplyDistributionTracker, storage } from '@cardano-sdk/wallet';
import { networkInfoProviderFactory } from '../../../../src/index.js';
import { switchMap } from 'rxjs';

import { env, logger } from '../util.js';
import { wallet$ } from './walletManager.js';
import { walletName } from '../const.js';

export const supplyDistributionTrackerReady = (async () =>
  createSupplyDistributionTracker(
    { trigger$: wallet$.pipe(switchMap((wallet) => wallet.currentEpoch$)) },
    {
      logger,
      networkInfoProvider: await networkInfoProviderFactory.create(
        env.NETWORK_INFO_PROVIDER,
        env.NETWORK_INFO_PROVIDER_PARAMS,
        logger
      ),
      stores: storage.createPouchDbSupplyDistributionStores(walletName, { logger })
    }
  ))();
