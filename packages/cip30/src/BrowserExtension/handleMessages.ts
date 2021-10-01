import { dummyLogger, Logger } from 'ts-log';
import browser from 'webextension-polyfill';
import { Message } from './types';
import { WalletApi } from '../Wallet';

export const handleMessages = (walletApi: WalletApi, logger: Logger = dummyLogger): void => {
  browser.runtime.onMessage.addListener(async (msg: Message) => {
    logger.debug('new message received: ', msg);

    const walletMethod = walletApi[msg.method];

    if (!walletMethod) {
      logger.error(`No method implemented for ${msg.method}`);

      return;
    }

    return walletMethod(...msg.arguments);
  });
};
