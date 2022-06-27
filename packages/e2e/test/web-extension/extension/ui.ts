/* eslint-disable no-use-before-define */
import {
  BackgroundServices,
  UserPromptService,
  adaPriceProperties,
  adaPriceServiceChannel,
  logger,
  userPromptServiceChannel,
  walletName
} from './util';
import { Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '@cardano-sdk/wallet';
import {
  RemoteApiPropertyType,
  consumeObservableWallet,
  consumeRemoteApi,
  exposeApi,
  exposeKeyAgent
} from '@cardano-sdk/web-extension';
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

exposeApi<UserPromptService>(
  {
    api,
    baseChannel: userPromptServiceChannel,
    properties: { allowOrigin: RemoteApiPropertyType.MethodReturningPromise }
  },
  { logger, runtime }
);

// Consume background services
const backgroundServices = consumeRemoteApi<BackgroundServices>(
  {
    baseChannel: adaPriceServiceChannel,
    properties: adaPriceProperties
  },
  { logger, runtime }
);
backgroundServices.adaUsd$.subscribe((price) => (document.querySelector('#adaPrice')!.textContent = price.toFixed(2)));
document
  .querySelector<HTMLButtonElement>('#clearAllowList')!
  .addEventListener('click', backgroundServices.clearAllowList);

// Use observable wallet from UI:
const wallet = consumeObservableWallet({ walletName }, { logger, runtime });
wallet.addresses$.subscribe(([{ address }]) => (document.querySelector('#address')!.textContent = address.toString()));
wallet.balance.utxo.available$.subscribe(
  ({ coins }) => (document.querySelector('#balance')!.textContent = coins.toString())
);

document.querySelector('#createLedgerKeyAgent')!.addEventListener('click', async () => {
  // restoreKeyAgent or create a new one and expose it
  exposeKeyAgent(
    {
      keyAgent: KeyManagement.util.createAsyncKeyAgent(
        await KeyManagement.LedgerKeyAgent.createWithDevice({
          communicationType: KeyManagement.CommunicationType.Web,
          networkId: Cardano.NetworkId.testnet,
          protocolMagic: 1_097_911_063
        })
      ),
      walletName
    },
    { logger, runtime }
  );
});
