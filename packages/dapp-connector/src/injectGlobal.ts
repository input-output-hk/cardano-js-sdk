import type { Cip30Wallet } from './WalletApi/index.js';
import type { Logger } from 'ts-log';

export type WindowMaybeWithCardano = Window & { cardano?: { [k: string]: Cip30Wallet } };

export const injectGlobal = (window: WindowMaybeWithCardano, wallet: Cip30Wallet, logger: Logger): void => {
  if (!window.cardano) {
    logger.debug(
      {
        module: 'injectWindow',
        wallet: { apiVersion: wallet.apiVersion, icon: wallet.icon, name: wallet.name }
      },
      'Creating cardano global scope'
    );
    window.cardano = {};
  } else {
    logger.debug(
      {
        module: 'injectWindow',
        wallet: { apiVersion: wallet.apiVersion, icon: wallet.icon, name: wallet.name }
      },
      'Cardano global scope exists'
    );
  }
  window.cardano[wallet.name] = window.cardano[wallet.name] || wallet;
  logger.debug(
    {
      module: 'injectWindow',
      wallet: { apiVersion: wallet.apiVersion, icon: wallet.icon, name: wallet.name },
      windowCardano: window.cardano
    },
    'Injected'
  );
};
