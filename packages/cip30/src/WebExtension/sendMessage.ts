import { Message } from './types';
import { WalletApi } from '../Wallet';
import { dummyLogger } from 'ts-log';
import browser from 'webextension-polyfill';

export const createMessenger =
  (extensionId: string, logger = dummyLogger) =>
  async (msg: Message): Promise<WalletApi[keyof WalletApi]> => {
    logger.debug('sendMessage', msg);
    try {
      return browser.runtime.sendMessage(extensionId, msg);
    } catch (error) {
      logger.error('sendMessage', error);
      throw error;
    }
  };
