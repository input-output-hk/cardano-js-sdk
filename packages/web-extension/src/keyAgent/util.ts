import { KeyManagement } from '@cardano-sdk/wallet';
import { RemoteApiProperties, RemoteApiPropertyType } from '../messaging';

export const keyAgentChannel = (walletName: string) => `${walletName}$-keyAgent`;

export const keyAgentProperties: RemoteApiProperties<KeyManagement.AsyncKeyAgent> = {
  deriveAddress: RemoteApiPropertyType.MethodReturningPromise,
  knownAddresses$: RemoteApiPropertyType.Observable,
  signBlob: RemoteApiPropertyType.MethodReturningPromise,
  signTransaction: RemoteApiPropertyType.MethodReturningPromise
};
