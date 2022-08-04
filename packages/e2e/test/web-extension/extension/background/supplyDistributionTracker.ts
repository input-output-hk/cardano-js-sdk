import { createSupplyDistributionTracker, storage } from '@cardano-sdk/wallet';
import { logger, walletName } from '../util';
import { networkInfoProvider } from './config';
import { walletReady } from './wallet';

export const supplyDistributionTrackerReady = (async () => {
  const wallet = await walletReady;
  return createSupplyDistributionTracker(
    { trigger$: wallet.currentEpoch$ },
    {
      logger,
      networkInfoProvider: await networkInfoProvider,
      stores: storage.createPouchDbSupplyDistributionStores(walletName, { logger })
    }
  );
})();
