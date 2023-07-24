// Expose any additional services to be shared with UIs
import { BackgroundServices, adaPriceProperties, env, logger } from '../util';
import { Cardano } from '@cardano-sdk/core';
import { adaPriceServiceChannel, walletName } from '../const';
import { authenticator } from './authenticator';
import { exposeApi, exposeSupplyDistributionTracker } from '@cardano-sdk/web-extension';
import { of } from 'rxjs';
import { runtime } from 'webextension-polyfill';
import { stakePoolProviderFactory } from '../../../../src';
import { supplyDistributionTrackerReady } from './supplyDistributionTracker';

const priceService: BackgroundServices = {
  adaUsd$: of(2.99),
  clearAllowList: authenticator.clear.bind(authenticator),
  getPoolIds: async (count: number): Promise<Cardano.StakePool[]> => {
    const stakePoolProvider = await stakePoolProviderFactory.create(
      env.STAKE_POOL_PROVIDER,
      env.STAKE_POOL_PROVIDER_PARAMS,
      logger
    );

    const activePools = await stakePoolProvider.queryStakePools({
      filters: { status: [Cardano.StakePoolStatus.Active] },
      pagination: { limit: count, startAt: 0 }
    });
    return activePools.pageResults.slice(0, count);
  }
};

exposeApi(
  {
    api$: of(priceService),
    baseChannel: adaPriceServiceChannel,
    properties: adaPriceProperties
  },
  { logger, runtime }
);

/* eslint-disable @typescript-eslint/no-floating-promises */
(async () => {
  const supplyDistributionTracker = await supplyDistributionTrackerReady;
  exposeSupplyDistributionTracker({ supplyDistributionTracker, walletName }, { logger, runtime });
})();
