import browser from 'webextension-polyfill';
import { dummyLogger, Logger } from 'ts-log';
import { Message } from './types';
import { WalletApi } from '../Wallet';

export const sendMessage = (msg: Message, logger: Logger = dummyLogger): Promise<WalletApi[keyof WalletApi]> => {
  logger.debug('sendMessage', msg);
  try {
    return browser.runtime.sendMessage(msg);
  } catch (error) {
    logger.error('sendMessage', error);
    throw error;
  }
};
