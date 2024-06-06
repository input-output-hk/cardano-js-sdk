import { runtime, tabs } from 'webextension-polyfill';
import type { Tabs } from 'webextension-polyfill';

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

export const ensureUiIsOpenAndLoaded = async () => {
  const uiUrl = runtime.getURL('ui.html');
  const uiTabs = await tabs.query({ url: uiUrl });
  const tab = uiTabs.length > 0 ? uiTabs[0] : await tabs.create({ url: uiUrl });
  if (tab.status !== 'complete') {
    await waitForTabLoad(tab);
  }
  return tab;
};
