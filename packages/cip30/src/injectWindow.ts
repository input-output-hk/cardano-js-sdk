import { Wallet, WalletPublic } from './Wallet';
import { dummyLogger, Logger } from 'ts-log';

export type WindowMaybeWithCardano = Window & { cardano?: { [k: string]: WalletPublic } };

export const injectWindow = (window: WindowMaybeWithCardano, wallet: Wallet, logger: Logger = dummyLogger): void => {
  if (!window.cardano) {
    logger.debug(
      {
        module: 'injectWindow',
        wallet: { name: wallet.name, version: wallet.version }
      },
      'Creating cardano global scope'
    );
    window.cardano = {};
  } else {
    logger.debug(
      {
        module: 'injectWindow',
        wallet: { name: wallet.name, version: wallet.version }
      },
      'Cardano global scope exists'
    );
  }
  window.cardano[wallet.name] = window.cardano[wallet.name] || wallet.getPublicApi(window);
  logger.debug(
    {
      module: 'injectWindow',
      wallet: { name: wallet.name, version: wallet.version },
      windowCardano: window.cardano
    },
    'Injected'
  );
};
