import { Message } from './types';
import { Runtime } from 'webextension-polyfill';
import { WalletApi, WalletMethodNames } from '../Wallet';
import { createMessenger } from './sendMessage';
import { dummyLogger } from 'ts-log';

export interface WebExtensionClientProps {
  walletName: string;
  walletExtensionId: string;
}

export const createWebExtensionWalletClient = (
  { walletName, walletExtensionId }: WebExtensionClientProps,
  runtime: Runtime.Static,
  logger = dummyLogger
): WalletApi => {
  const sendMessage = createMessenger(walletExtensionId, runtime, logger);
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
