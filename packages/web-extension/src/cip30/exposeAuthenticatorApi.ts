import { AuthenticatorApi, RemoteAuthenticator } from '@cardano-sdk/dapp-connector';
import {
  MessengerDependencies,
  RemoteApiMethod,
  RemoteApiProperties,
  RemoteApiPropertyType,
  exposeApi
} from '../messaging';
import { RemoteAuthenticatorMethodNames } from './consumeRemoteAuthenticatorApi';
import { cloneSender } from './util';
import { of } from 'rxjs';

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
      api$: of(dependencies.authenticator),
      baseChannel: authenticatorChannel(walletName),
      properties: Object.fromEntries(
        RemoteAuthenticatorMethodNames.map((prop) => [
          prop,
          {
            propType: RemoteApiPropertyType.MethodReturningPromise,
            requestOptions: {
              transform: ({ method }, sender) => {
                if (!sender) throw new Error('Unknown sender');
                return {
                  args: [cloneSender(sender)],
                  method
                };
              }
            }
          } as RemoteApiMethod
        ])
      ) as RemoteApiProperties<RemoteAuthenticator>
    },
    dependencies
  );
