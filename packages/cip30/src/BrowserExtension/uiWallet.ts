import { Logger, dummyLogger } from 'ts-log';
import { Message } from './types';
import { WalletApi } from '..';
import { sendMessage } from './sendMessage';

export const createUiWallet = (logger: Logger = dummyLogger): WalletApi => {
  const methodNames: (keyof WalletApi)[] = [
    'getNetworkId',
    'getUtxos',
    'getBalance',
    'getUsedAddresses',
    'getUnusedAddresses',
    'getChangeAddress',
    'getRewardAddresses',
    'signTx',
    'signData',
    'submitTx'
  ];
  return <WalletApi>(
    (<unknown>(
      Object.fromEntries(
        methodNames.map((method) => [
          method,
          (...args: Message['arguments']) => sendMessage({ arguments: args, method }, logger)
        ])
      )
    ))
  );
};
