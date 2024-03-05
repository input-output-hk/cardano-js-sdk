import { Asset } from '@cardano-sdk/core';
import { InstalledWallet } from './types';
import { WithLogger, isNotNil } from '@cardano-sdk/util';
import { getCardanoNamespace } from './util';

export const listWallets = ({ logger }: WithLogger): InstalledWallet[] => {
  const cardanoNamespace = getCardanoNamespace();
  if (!cardanoNamespace) return [];
  return Object.entries(cardanoNamespace)
    .map(([id, wallet]): InstalledWallet | null => {
      if (!wallet) {
        logger.warn(`Wallet '${id}' is ${wallet}`);
        return null;
      }
      // TODO: check supported versions
      if (typeof wallet.apiVersion !== 'string') {
        logger.warn(`Unsupported api version (${wallet.apiVersion}) for wallet '${id}'`);
        return null;
      }
      let icon: Asset.Uri;
      try {
        icon = Asset.Uri(wallet.icon);
      } catch {
        logger.warn(`Missing or invalid icon (${wallet.icon}) for wallet '${id}'`);
        return null;
      }
      if (typeof wallet.isEnabled !== 'function' || typeof wallet.name !== 'string') {
        logger.warn(
          `Missing isEnabled method (${typeof wallet.isEnabled}) or invalid name (${wallet.name}) for wallet '${id}'`
        );
      }
      return {
        apiVersion: wallet.apiVersion,
        icon,
        id,
        async isEnabled() {
          const isEnabled = await wallet.isEnabled();
          return isEnabled.valueOf();
        },
        name: wallet.name,
        supportedExtensions: wallet.supportedExtensions || []
      };
    })
    .filter(isNotNil);
};
