import { AuthenticatorApi, RemoteAuthenticator } from '@cardano-sdk/cip30';
import {
  MessengerDependencies,
  RemoteApiMethod,
  RemoteApiProperties,
  RemoteApiPropertyType,
  exposeApi,
  senderOrigin
} from '../messaging';
import { RemoteAuthenticatorMethodNames } from './consumeRemoteAuthenticatorApi';

export interface ExposeAuthenticatorApiOptions {
  walletName: string;
}

export interface BackgroundAuthenticatorDependencies extends MessengerDependencies {
  authenticator: AuthenticatorApi;
}

export const authenticatorChannel = (walletName: string) => `authenticator-${walletName}`;

// tested in e2e tests
export const exposeAuthenticatorApi = (
  { walletName }: ExposeAuthenticatorApiOptions,
  dependencies: BackgroundAuthenticatorDependencies
) =>
  exposeApi(
    {
      api: dependencies.authenticator,
      baseChannel: authenticatorChannel(walletName),
      properties: Object.fromEntries(
        RemoteAuthenticatorMethodNames.map((prop) => [
          prop,
          {
            propType: RemoteApiPropertyType.MethodReturningPromise,
            requestOptions: {
              transform: ({ method }, sender) => ({
                args: [senderOrigin(sender)],
                method
              })
            }
          } as RemoteApiMethod
        ])
      ) as RemoteApiProperties<RemoteAuthenticator>
    },
    dependencies
  );
