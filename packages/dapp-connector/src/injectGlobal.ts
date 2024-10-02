import { Cip30Wallet } from './WalletApi';
import { Logger } from 'ts-log';

export type WindowMaybeWithCardano = Window & { cardano?: { [k: string]: Cip30Wallet } };

export const injectGlobal = (
  window: WindowMaybeWithCardano,
  wallet: Cip30Wallet,
  logger: Logger,
  injectKey?: string
): void => {
  injectKey = injectKey ?? wallet.name;
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
  window.cardano[injectKey] = window.cardano[injectKey] || wallet;
  logger.debug(
    {
      module: 'injectWindow',
      wallet: { apiVersion: wallet.apiVersion, icon: wallet.icon, name: wallet.name },
      windowCardano: window.cardano
    },
    'Injected'
  );
};
