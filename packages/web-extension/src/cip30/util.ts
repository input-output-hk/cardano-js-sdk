import type { MessageSender } from '@cardano-sdk/key-management';

export const walletApiChannel = (walletName: string) => `wallet-api-${walletName}`;

export const authenticatorChannel = (walletName: string) => `authenticator-${walletName}`;

/**
 * sender object is intended to be used as a parameter in APIs exposed via extension messaging.
 * This function clones the sender object provided by the browser in order to ensure it's a pojo.
 */
export const cloneSender = ({ frameId, id, tab, url }: MessageSender): MessageSender => ({
  frameId,
  id,
  tab: tab
    ? {
        active: tab.active,
        attention: tab.attention,
        audible: tab.audible,
        autoDiscardable: tab.autoDiscardable,
        cookieStoreId: tab.cookieStoreId,
        discarded: tab.discarded,
        favIconUrl: tab.favIconUrl,
        height: tab.height,
        hidden: tab.hidden,
        highlighted: tab.highlighted,
        id: tab.id,
        incognito: tab.incognito,
        index: tab.index,
        isArticle: tab.isArticle,
        isInReaderMode: tab.isInReaderMode,
        lastAccessed: tab.lastAccessed,
        mutedInfo: tab.mutedInfo ? { ...tab.mutedInfo } : void 0,
        openerTabId: tab.openerTabId,
        pendingUrl: tab.pendingUrl,
        pinned: tab.pinned,
        sessionId: tab.sessionId,
        sharingState: tab.sharingState ? { ...tab.sharingState } : void 0,
        status: tab.status,
        successorTabId: tab.successorTabId,
        title: tab.title,
        url: tab.url,
        width: tab.width,
        windowId: tab.windowId
      }
    : void 0,
  url
});
