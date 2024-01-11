import {
  APIErrorCode,
  ApiError,
  AuthenticatorApi,
  WalletApi,
  WalletApiMethodNames,
  WithSenderContext
} from '@cardano-sdk/dapp-connector';
import {
  MessengerDependencies,
  RemoteApiMethod,
  RemoteApiProperties,
  RemoteApiPropertyType,
  exposeApi
} from '../messaging';
import { cloneSender, walletApiChannel } from './util';
import { of } from 'rxjs';

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
