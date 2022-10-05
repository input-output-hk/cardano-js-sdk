import {
  ApiError,
  DataSignError,
  PaginateError,
  TxSendError,
  TxSignError,
  WalletApi,
  WalletApiMethodNames
} from '@cardano-sdk/dapp-connector';
import { GetErrorPrototype } from '@cardano-sdk/util';
import { MessengerDependencies, RemoteApiProperties, RemoteApiPropertyType, consumeRemoteApi } from '../messaging';
import { walletApiChannel } from './util';

const cip30errorTypes = [ApiError, DataSignError, PaginateError, TxSendError, TxSignError];
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const getErrorPrototype: GetErrorPrototype = (err: any) =>
  cip30errorTypes.find((ErrorType) => ErrorType.prototype.name === err.name)?.prototype || Error.prototype;

export interface ConsumeRemoteWalletApiProps {
  walletName: string;
}

// tested in e2e tests
export const consumeRemoteWalletApi = (
  { walletName }: ConsumeRemoteWalletApiProps,
  dependencies: MessengerDependencies
): WalletApi =>
  consumeRemoteApi(
    {
      baseChannel: walletApiChannel(walletName),
      getErrorPrototype,
      properties: Object.fromEntries(
        WalletApiMethodNames.map((prop) => [prop, RemoteApiPropertyType.MethodReturningPromise])
      ) as RemoteApiProperties<WalletApi>
    },
    dependencies
  );
