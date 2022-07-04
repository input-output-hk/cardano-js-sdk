import '@cardano-sdk/util';
import { MessengerDependencies, RemoteApiProperties, RemoteApiPropertyType, consumeRemoteApi } from '../messaging';
import { RemoteAuthenticator, RemoteAuthenticatorMethod } from '@cardano-sdk/cip30';
import { authenticatorChannel } from './util';

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
