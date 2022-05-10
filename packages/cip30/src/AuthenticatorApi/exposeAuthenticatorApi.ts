// tested in web-extension/e2e tests
import { AuthenticatorApi, RemoteAuthenticator } from './types';
import {
  MessengerDependencies,
  RemoteApiMethod,
  RemoteApiProperties,
  RemoteApiPropertyType,
  exposeApi,
  senderOrigin
} from '@cardano-sdk/web-extension';
import { RemoteAuthenticatorMethodNames } from './consumeRemoteAuthenticatorApi ';
import { authenticatorChannel } from './util';

export interface ExposeAuthenticatorApiOptions {
  walletName: string;
}

export interface BackgroundAuthenticatorDependencies extends MessengerDependencies {
  authenticator: AuthenticatorApi;
}

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
