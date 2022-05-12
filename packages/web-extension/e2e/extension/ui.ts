/* eslint-disable no-use-before-define */
import {
  AdaPriceService,
  UserPromptService,
  adaPriceProperties,
  adaPriceServiceChannel,
  userPromptServiceChannel
} from './util';
import { RemoteApiPropertyType, consumeRemoteApi, exposeApi } from '@cardano-sdk/web-extension';
import { runtime } from 'webextension-polyfill';

const api: UserPromptService = {
  allowOrigin(origin) {
    const container = document.querySelector<HTMLDivElement>('#requestAccess')!;
    container.style.display = 'block';
    document.querySelector<HTMLSpanElement>('#requestAccessOrigin')!.textContent = origin;
    const btnGrant = document.querySelector<HTMLButtonElement>('#requestAccessGrant')!;
    const btnDeny = document.querySelector<HTMLButtonElement>('#requestAccessDeny')!;
    return new Promise((resolve) => {
      const done = async (grant: boolean) => {
        btnGrant.removeEventListener('click', grantListener);
        btnDeny.removeEventListener('click', denyListener);
        container.style.display = 'none';
        resolve(grant);
      };
      const grantListener = () => done(true);
      const denyListener = () => done(false);
      btnGrant.addEventListener('click', grantListener);
      btnDeny.addEventListener('click', denyListener);
    });
  }
};

const logger = console;
exposeApi<UserPromptService>(
  {
    api,
    baseChannel: userPromptServiceChannel,
    properties: { allowOrigin: RemoteApiPropertyType.MethodReturningPromise }
  },
  { logger, runtime }
);

// Consume background services

const priceService = consumeRemoteApi<AdaPriceService>(
  {
    baseChannel: adaPriceServiceChannel,
    properties: adaPriceProperties
  },
  { logger, runtime }
);

priceService.adaUsd$.subscribe((price) => (document.querySelector('#adaPrice')!.textContent = price.toFixed(2)));

// To use observable wallet from UI:
// const wallet = consumeObservableWallet({ walletName }, { logger, runtime });
