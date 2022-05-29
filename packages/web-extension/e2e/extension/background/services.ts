// Expose any additional services to be shared with UIs
import { BackgroundServices, adaPriceProperties, adaPriceServiceChannel, logger } from '../util';
import { authenticator } from './authenticator';
import { exposeApi } from '@cardano-sdk/web-extension';
import { of } from 'rxjs';
import { runtime } from 'webextension-polyfill';

const priceService: BackgroundServices = {
  adaUsd$: of(2.99),
  clearAllowList: authenticator.clear.bind(authenticator)
};

exposeApi(
  {
    api: priceService,
    baseChannel: adaPriceServiceChannel,
    properties: adaPriceProperties
  },
  { logger, runtime }
);
