// tested in web-extension/e2e tests
import { MessengerDependencies, consumeRemotePromiseApi } from '@cardano-sdk/web-extension';
import { RemoteAuthenticator, RemoteAuthenticatorMethod } from './types';
import { authenticatorChannel } from './util';

export const RemoteAuthenticatorMethodNames: Array<RemoteAuthenticatorMethod> = [
  'haveAccess',
  'requestAccess',
  'revokeAccess'
];

export interface RemoteAuthenticatorApiProps {
  walletName: string;
}

export const consumeRemoteAuthenticatorApi = (
  { walletName }: RemoteAuthenticatorApiProps,
  dependencies: MessengerDependencies
) =>
  consumeRemotePromiseApi<RemoteAuthenticator>(
    { channel: authenticatorChannel(walletName), validMethodNames: RemoteAuthenticatorMethodNames },
    dependencies
  );
