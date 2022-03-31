import { Logger, dummyLogger } from 'ts-log';
import { Message } from './types';
import { WalletApi } from '../Wallet';
import browser from 'webextension-polyfill';

export interface MessengerProps {
  extensionId?: string;
  logger?: Logger;
}

export const createMessenger =
  ({ logger = dummyLogger, extensionId }: MessengerProps = {}) =>
  async (msg: Message): Promise<WalletApi[keyof WalletApi]> => {
    logger.debug('sendMessage', msg);
    try {
      if (extensionId) {
        return browser.runtime.sendMessage(extensionId, msg);
      }
      return browser.runtime.sendMessage(msg);
    } catch (error) {
      logger.error('sendMessage', error);
      throw error;
    }
  };
