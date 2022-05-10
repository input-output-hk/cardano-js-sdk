/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  PersistentAuthenticator,
  RequestAccess,
  createPersistentAuthenticatorStorage,
  initializeBackgroundScript
} from '@cardano-sdk/cip30';
import { RemoteApiPropertyType, consumeRemoteApi } from '@cardano-sdk/web-extension';
import { Tabs, runtime, storage, tabs } from 'webextension-polyfill';
import { UserPromptService, userPromptServiceChannel, walletName } from './util';
import { stubWalletApi } from './stubWalletApi';

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
const userPromptService = consumeRemoteApi<UserPromptService>(
  {
    baseChannel: userPromptServiceChannel,
    properties: {
      allowOrigin: RemoteApiPropertyType.MethodReturningPromise
    }
  },
  { logger, runtime }
);
const requestAccess: RequestAccess = async (origin) => {
  await ensureUiIsOpenAndLoaded();
  return await userPromptService.allowOrigin(origin);
};

void (async () => {
  // TODO: test with real wallet once blockfrost load issue is resolved
  // const confirmationCallback: cip30.CallbackConfirmation = async () => true;
  // const wallet = new SingleAddressWallet(
  //   { name: walletName },
  //   {
  //     assetProvider: await assetProvider,
  //     keyAgent: await keyAgentReady,
  //     logger,
  //     networkInfoProvider: await networkInfoProvider,
  //     stakePoolSearchProvider: await stakePoolSearchProvider,
  //     stores: walletStorage.createPouchdbWalletStores(walletName),
  //     txSubmitProvider: await txSubmitProvider,
  //     walletProvider: await walletProvider
  //   }
  // );
  // const walletApi = cip30.createWalletApi(wallet, confirmationCallback, { logger });
  const walletApi = stubWalletApi;
  const authenticatorStorage = createPersistentAuthenticatorStorage(`${walletName}Origins`, storage.local);
  const authenticator = await PersistentAuthenticator.create(
    { requestAccess },
    { logger, storage: authenticatorStorage }
  );
  await authenticator.clear();
  initializeBackgroundScript({ walletName }, { authenticator, logger, runtime, walletApi });
})();
