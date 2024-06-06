import { APIErrorCode, ApiError, WalletApiMethodNames } from '@cardano-sdk/dapp-connector';
import { RemoteApiPropertyType, exposeApi } from '../messaging/index.js';
import { cloneSender, walletApiChannel } from './util.js';
import { of } from 'rxjs';
import type { AuthenticatorApi, WalletApi, WithSenderContext } from '@cardano-sdk/dapp-connector';
import type { MessengerDependencies, RemoteApiMethod, RemoteApiProperties } from '../messaging/index.js';

export interface BackgroundWalletApiOptions {
  walletName: string;
}

export interface BackgroundWalletDependencies extends MessengerDependencies {
  authenticator: AuthenticatorApi;
  walletApi: WithSenderContext<WalletApi>;
}

// tested in e2e tests
export const exposeWalletApi = (
  { walletName }: BackgroundWalletApiOptions,
  dependencies: BackgroundWalletDependencies
) =>
  exposeApi(
    {
      api$: of(dependencies.walletApi),
      baseChannel: walletApiChannel(walletName),
      properties: Object.fromEntries(
        WalletApiMethodNames.map((prop) => [
          prop,
          {
            propType: RemoteApiPropertyType.MethodReturningPromise,
            requestOptions: {
              transform: ({ method, args }, sender) => {
                if (!sender) throw new Error('"sender" is undefined');
                return {
                  args: [{ sender: cloneSender(sender) }, ...args],
                  method
                };
              },
              validate: async (_, sender) => {
                const haveAccess = sender && (await dependencies.authenticator.haveAccess(cloneSender(sender)));
                if (!haveAccess) {
                  throw new ApiError(APIErrorCode.Refused, 'Call cardano.{walletName}.enable() first');
                }
              }
            }
          } as RemoteApiMethod
        ])
      ) as RemoteApiProperties<WalletApi>
    },
    dependencies
  );
