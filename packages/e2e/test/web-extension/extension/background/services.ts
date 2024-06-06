// Expose any additional services to be shared with UIs
import { Cardano } from '@cardano-sdk/core';
import { Subject, of } from 'rxjs';
import { adaPriceProperties, disconnectPortTestObjProperties, env, logger } from '../util.js';
import { adaPriceServiceChannel, walletName } from '../const.js';
import { authenticator } from './authenticator.js';
import { consumeRemoteApi, exposeApi, exposeSupplyDistributionTracker } from '@cardano-sdk/web-extension';
import { runtime } from 'webextension-polyfill';
import { stakePoolProviderFactory } from '../../../../src/index.js';
import { supplyDistributionTrackerReady } from './supplyDistributionTracker.js';
import type { BackgroundServices } from '../util.js';

const apiDisconnectResult$ = new Subject<string>();
const priceService: BackgroundServices = {
  adaUsd$: of(2.99),
  apiDisconnectResult$,
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

// Dummy exposeApi object that closes the port as soon as it gets a message.
// UI promise call should reject as a result of this
// UI consumes API -> BG exposes fake API that closes port
runtime.onConnect.addListener((port) => {
  if (port.name === 'ui-to-bg-port-disconnect-channel') {
    port.onMessage.addListener((_msg, p) => {
      p.disconnect();
    });
  }
});

// Code below tests that a disconnected port in UI script will result in the consumed API method call promise to reject
// BG consumes API -> UI exposes fake API that closes port
const disconnectPortTestObj = consumeRemoteApi(
  { baseChannel: 'bg-to-ui-port-disconnect-channel', properties: disconnectPortTestObjProperties },
  { logger, runtime }
);
disconnectPortTestObj
  .promiseMethod()
  .then(() => apiDisconnectResult$.next('UI script port disconnect -> Promise resolves'))
  .catch(() => apiDisconnectResult$.next('UI script port disconnect -> Promise rejects'));

/* eslint-disable @typescript-eslint/no-floating-promises */
(async () => {
  const supplyDistributionTracker = await supplyDistributionTrackerReady;
  exposeSupplyDistributionTracker({ supplyDistributionTracker, walletName }, { logger, runtime });
})();
