import { Logger, dummyLogger } from 'ts-log';
import { Message } from './types';
import { WalletApi, WalletMethodNames } from '../Wallet';
import { createMessenger } from './sendMessage';

export interface CreateUiWalletProps {
  walletExtensionId?: string;
  logger?: Logger;
}

export const createUiWallet = (
  walletName: string,
  { logger = dummyLogger, walletExtensionId }: CreateUiWalletProps = {}
): WalletApi => {
  const sendMessage = createMessenger({ extensionId: walletExtensionId, logger });
  return <WalletApi>(
    (<unknown>(
      Object.fromEntries(
        WalletMethodNames.map((method) => [
          method,
          (...args: Message['arguments']) => sendMessage({ arguments: args, method, walletName })
        ])
      )
    ))
  );
};
