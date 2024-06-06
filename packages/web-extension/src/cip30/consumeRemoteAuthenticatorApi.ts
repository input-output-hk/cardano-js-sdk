import { RemoteApiPropertyType, consumeRemoteApi } from '../messaging/index.js';
import { authenticatorChannel } from './util.js';
import type { MessengerDependencies, RemoteApiProperties } from '../messaging/index.js';
import type { RemoteAuthenticator, RemoteAuthenticatorMethod } from '@cardano-sdk/dapp-connector';

export const RemoteAuthenticatorMethodNames: Array<RemoteAuthenticatorMethod> = [
  'haveAccess',
  'requestAccess',
  'revokeAccess'
];

export interface RemoteAuthenticatorApiProps {
  walletName: string;
}

// tested in e2e tests
export const consumeRemoteAuthenticatorApi = (
  { walletName }: RemoteAuthenticatorApiProps,
  dependencies: MessengerDependencies
) =>
  consumeRemoteApi<RemoteAuthenticator>(
    {
      baseChannel: authenticatorChannel(walletName),
      properties: Object.fromEntries(
        RemoteAuthenticatorMethodNames.map((prop) => [prop, RemoteApiPropertyType.MethodReturningPromise])
      ) as RemoteApiProperties<RemoteAuthenticator>
    },
    dependencies
  );
