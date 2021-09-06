import { WalletApi } from '..';
import { dummyLogger, Logger } from 'ts-log';
import { sendMessage } from './sendMessage';
import { Message } from './types';

export const createUiWallet = (logger: Logger = dummyLogger): WalletApi => {
  const methodNames = [
    'getUtxos',
    'getBalance',
    'getUsedAddresses',
    'getUnusedAddresses',
    'getChangeAddress',
    'getRewardAddresses',
    'signTx',
    'signData',
    'submitTx'
  ] as (keyof WalletApi)[];
  return <WalletApi>(
    (<unknown>(
      Object.fromEntries(
        methodNames.map((method) => [
          method,
          (...args: Message['arguments']) => sendMessage({ method, arguments: args }, logger)
        ])
      )
    ))
  );
};
