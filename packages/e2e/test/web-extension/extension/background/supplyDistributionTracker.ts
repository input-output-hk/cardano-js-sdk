import { createSupplyDistributionTracker, storage } from '@cardano-sdk/wallet';
import { switchMap } from 'rxjs';

import { logger, walletName } from '../util';
import { networkInfoProvider } from './config';
import { wallet$ } from './walletManager';

export const supplyDistributionTrackerReady = (async () =>
  createSupplyDistributionTracker(
    { trigger$: wallet$.pipe(switchMap((wallet) => wallet.currentEpoch$)) },
    {
      logger,
      networkInfoProvider: await networkInfoProvider,
      stores: storage.createPouchDbSupplyDistributionStores(walletName, { logger })
    }
  ))();
