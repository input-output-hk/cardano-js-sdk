/* eslint-disable @typescript-eslint/no-explicit-any */
import { APIErrorCode, ApiError, DataSignError, PaginateError, TxSendError, TxSignError } from '../errors';
import { Logger, dummyLogger } from 'ts-log';
import { Runtime } from 'webextension-polyfill';
import { WalletApi } from '../Wallet';

const cip30errorTypes = [ApiError, DataSignError, PaginateError, TxSendError, TxSignError];

export const createListener =
  (walletName: string, walletApi: WalletApi, logger: Logger = dummyLogger) =>
  // eslint-disable-next-line complexity
  async (msg: unknown) => {
    logger.debug('new message received: ', msg);

    if (
      typeof msg !== 'object' ||
      msg === null ||
      !['method', 'arguments', 'walletName'].every((prop) => prop in msg)
    ) {
      // Probably a message that not intended to this handler
      return;
    }

    const { method, arguments: args, walletName: msgWalletName } = msg as any;
    if (walletName !== msgWalletName) return;
    if (typeof method !== 'string' || !Array.isArray(args) || !(method in walletApi)) {
      logger.error('Invalid Message', msg);
      return;
    }

    try {
      return await (walletApi as any)[method](...args);
    } catch (error) {
      if (cip30errorTypes.some((ErrorType) => error instanceof ErrorType)) {
        throw error;
      }
      logger.error('Unexpected error', error);
      const message = (typeof error === 'object' && error && (error as any).message) || 'Internal error';
      throw new ApiError(APIErrorCode.InternalError, message);
    }
  };

export const handleMessages = (
  walletName: string,
  walletApi: WalletApi,
  logger: Logger = dummyLogger,
  runtime: Runtime.Static
) => {
  const listener = createListener(walletName, walletApi, logger);
  runtime.onMessage.addListener(listener);
  return () => runtime.onMessage.removeListener(listener);
};
