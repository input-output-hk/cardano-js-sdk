// tested in web-extension/e2e tests
import { APIErrorCode, ApiError } from '../errors';
import { AuthenticatorApi } from '../AuthenticatorApi';
import {
  MessengerDependencies,
  RemoteApiMethod,
  RemoteApiProperties,
  RemoteApiPropertyType,
  exposeApi,
  senderOrigin
} from '@cardano-sdk/web-extension';
import { WalletApi } from '.';
import { WalletApiMethodNames } from './Cip30Wallet';
import { walletApiChannel } from './util';

export interface BackgroundWalletApiOptions {
  walletName: string;
}

export interface BackgroundWalletDependencies extends MessengerDependencies {
  authenticator: AuthenticatorApi;
  walletApi: WalletApi;
}

export const exposeWalletApi = (
  { walletName }: BackgroundWalletApiOptions,
  dependencies: BackgroundWalletDependencies
) =>
  exposeApi(
    {
      api: dependencies.walletApi,
      baseChannel: walletApiChannel(walletName),
      properties: Object.fromEntries(
        WalletApiMethodNames.map((prop) => [
          prop,
          {
            propType: RemoteApiPropertyType.MethodReturningPromise,
            requestOptions: {
              validate: async (_, sender) => {
                const origin = sender && senderOrigin(sender);
                const haveAccess = origin && (await dependencies.authenticator.haveAccess(origin));
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
