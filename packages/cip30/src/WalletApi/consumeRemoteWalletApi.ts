// tested in web-extension/e2e tests
import { ApiError, DataSignError, PaginateError, TxSendError, TxSignError } from '../errors';
import { MessengerDependencies, consumeRemotePromiseApi } from '@cardano-sdk/web-extension';
import { WalletApi, WalletApiMethodNames } from '.';
import { util } from '@cardano-sdk/core';
import { walletApiChannel } from './util';

const cip30errorTypes = [ApiError, DataSignError, PaginateError, TxSendError, TxSignError];
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const getErrorPrototype: util.GetErrorPrototype = (err: any) =>
  cip30errorTypes.find((ErrorType) => ErrorType.prototype.name === err.name)?.prototype || Error.prototype;

export interface ConsumeRemoteWalletApiProps {
  walletName: string;
}

export const consumeRemoteWalletApi = (
  { walletName }: ConsumeRemoteWalletApiProps,
  dependencies: MessengerDependencies
): WalletApi =>
  consumeRemotePromiseApi(
    { channel: walletApiChannel(walletName), getErrorPrototype, validMethodNames: WalletApiMethodNames },
    dependencies
  );
