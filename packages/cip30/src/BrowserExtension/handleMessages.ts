import { Logger, dummyLogger } from 'ts-log';
import { Message } from './types';
import { WalletApi } from '../Wallet';
import { runtime } from 'webextension-polyfill';

export const handleMessages = (walletApi: WalletApi, logger: Logger = dummyLogger): void => {
  runtime.onMessage.addListener(async (msg: Message) => {
    logger.debug('new message received: ', msg);

    const walletMethod = walletApi[msg.method];

    if (!walletMethod) {
      logger.error(`No method implemented for ${msg.method}`);

      return;
    }

    return walletMethod(...msg.arguments);
  });
};
