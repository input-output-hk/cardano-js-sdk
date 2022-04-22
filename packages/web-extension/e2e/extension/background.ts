/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  PersistentAuthenticator,
  RequestAccess,
  createPersistentAuthenticatorStorage,
  initializeBackgroundScript
} from '@cardano-sdk/cip30';
import { SingleAddressWallet, cip30, storage as walletStorage } from '@cardano-sdk/wallet';
import { Tabs, runtime, storage, tabs } from 'webextension-polyfill';
import { UserPromptService, userPromptServiceChannel, walletName } from './util';
import {
  assetProvider,
  keyAgentReady,
  networkInfoProvider,
  stakePoolSearchProvider,
  txSubmitProvider,
  walletProvider
} from './config';
import { consumeRemotePromiseApi } from '@cardano-sdk/web-extension';

const waitForTabLoad = (tab: Tabs.Tab) =>
  new Promise<void>((resolve) => {
    const listener = (tabId: number, changeInfo: Tabs.OnUpdatedChangeInfoType) => {
      // make sure the status is 'complete' and it's the right tab
      if (tabId === tab.id && changeInfo.status === 'complete') {
        tabs.onUpdated.removeListener(listener);
        resolve();
      }
    };
    tabs.onUpdated.addListener(listener);
  });
const uiUrl = runtime.getURL('ui.html');
const openUi = async () => await tabs.create({ url: uiUrl });
const ensureUiIsOpenAndLoaded = async () => {
  const uiTabs = await tabs.query({ url: uiUrl });
  const tab = uiTabs.length > 0 ? uiTabs[0] : await openUi();
  if (tab.status !== 'complete') {
    await waitForTabLoad(tab);
  }
  return tab;
};

const logger = console;
const userPromptService = consumeRemotePromiseApi<UserPromptService>(
  {
    channel: userPromptServiceChannel,
    validMethodNames: ['allowOrigin']
  },
  { logger, runtime }
);
const requestAccess: RequestAccess = async (origin) => {
  await ensureUiIsOpenAndLoaded();
  return await userPromptService.allowOrigin(origin);
};
const confirmationCallback: cip30.CallbackConfirmation = async () => true;

void (async () => {
  const wallet = new SingleAddressWallet(
    { name: walletName },
    {
      assetProvider: await assetProvider,
      keyAgent: await keyAgentReady,
      logger,
      networkInfoProvider: await networkInfoProvider,
      stakePoolSearchProvider: await stakePoolSearchProvider,
      stores: walletStorage.createPouchdbWalletStores(walletName),
      txSubmitProvider: await txSubmitProvider,
      walletProvider: await walletProvider
    }
  );
  const walletApi = cip30.createWalletApi(wallet, confirmationCallback, { logger });
  const authenticatorStorage = createPersistentAuthenticatorStorage(`${walletName}Origins`, storage.local);
  const authenticator = await PersistentAuthenticator.create(
    { requestAccess },
    { logger, storage: authenticatorStorage }
  );
  await authenticator.clear();
  initializeBackgroundScript({ walletName }, { authenticator, logger, runtime, walletApi });
})();
