import {
  ApiError,
  DataSignError,
  PaginateError,
  TxSendError,
  TxSignError,
  WalletApiMethodNames
} from '@cardano-sdk/dapp-connector';
import { RemoteApiPropertyType, consumeRemoteApi } from '../messaging/index.js';
import { walletApiChannel } from './util.js';
import type { MessengerDependencies, RemoteApiProperties } from '../messaging/index.js';
import type { WalletApi } from '@cardano-sdk/dapp-connector';

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
