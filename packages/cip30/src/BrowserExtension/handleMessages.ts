/* eslint-disable @typescript-eslint/no-explicit-any */
import { Logger, dummyLogger } from 'ts-log';
import { WalletApi } from '../Wallet';
import browser from 'webextension-polyfill';

export const handleMessages = (walletApi: WalletApi, logger: Logger = dummyLogger) => {
  const listener = async (msg: unknown) => {
    logger.debug('new message received: ', msg);

    if (typeof msg !== 'object' || msg === null || !['method', 'arguments'].every((prop) => prop in msg)) {
      // Probably a message that not intended to this handler
      return;
    }

    const { method, arguments: args } = msg as any;
    if (typeof method !== 'string' || !Array.isArray(args) || !(method in walletApi)) {
      logger.error('Invalid Message', msg);
      return;
    }

    return (walletApi as any)[method](...args);
  };
  browser.runtime.onMessage.addListener(listener);
  return () => browser.runtime.onMessage.removeListener(listener);
};
