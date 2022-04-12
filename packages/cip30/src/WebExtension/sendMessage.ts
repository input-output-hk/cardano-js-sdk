import { Message } from './types';
import { Runtime } from 'webextension-polyfill';
import { WalletApi } from '../Wallet';
import { dummyLogger } from 'ts-log';

export const createMessenger =
  (extensionId: string, runtime: Runtime.Static, logger = dummyLogger) =>
  async (msg: Message): Promise<WalletApi[keyof WalletApi]> => {
    logger.debug('sendMessage', msg);
    try {
      return runtime.sendMessage(extensionId, msg);
    } catch (error) {
      logger.error('sendMessage', error);
      throw error;
    }
  };
