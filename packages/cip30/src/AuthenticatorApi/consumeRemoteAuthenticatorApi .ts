// tested in web-extension/e2e tests
import {
  MessengerDependencies,
  RemoteApiProperties,
  RemoteApiPropertyType,
  consumeRemoteApi
} from '@cardano-sdk/web-extension';
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
  consumeRemoteApi<RemoteAuthenticator>(
    {
      baseChannel: authenticatorChannel(walletName),
      properties: Object.fromEntries(
        RemoteAuthenticatorMethodNames.map((prop) => [prop, RemoteApiPropertyType.MethodReturningPromise])
      ) as RemoteApiProperties<RemoteAuthenticator>
    },
    dependencies
  );
