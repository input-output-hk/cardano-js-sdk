import {
  ApiError,
  DataSignError,
  PaginateError,
  TxSendError,
  TxSignError,
  WalletApi,
  WalletApiMethodNames
} from '@cardano-sdk/dapp-connector';
import { MessengerDependencies, RemoteApiProperties, RemoteApiPropertyType, consumeRemoteApi } from '../messaging';
import { walletApiChannel } from './util';

const cip30errorTypes = [ApiError, DataSignError, PaginateError, TxSendError, TxSignError];
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
      errorTypes: cip30errorTypes,
      properties: Object.fromEntries(
        WalletApiMethodNames.map((prop) => [prop, RemoteApiPropertyType.MethodReturningPromise])
      ) as RemoteApiProperties<WalletApi>
    },
    dependencies
  );
