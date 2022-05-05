// tested in web-extension/e2e tests
import { AuthenticatorApi } from './types';
import { MessengerDependencies, exposeApi, senderOrigin } from '@cardano-sdk/web-extension';
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
      methodRequestOptions: {
        transform: ({ method }, sender) => ({
          args: [senderOrigin(sender)],
          method
        })
      }
    },
    dependencies
  );
