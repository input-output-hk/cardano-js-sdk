import { AsyncKeyAgent } from '@cardano-sdk/key-management';
import { RemoteApiProperties, RemoteApiPropertyType } from '../messaging';

export const keyAgentChannel = (walletName: string) => `${walletName}$-keyAgent`;

export const keyAgentProperties: RemoteApiProperties<AsyncKeyAgent> = {
  deriveAddress: RemoteApiPropertyType.MethodReturningPromise,
  derivePublicKey: RemoteApiPropertyType.MethodReturningPromise,
  getBip32Ed25519: RemoteApiPropertyType.MethodReturningPromise,
  getChainId: RemoteApiPropertyType.MethodReturningPromise,
  getExtendedAccountPublicKey: RemoteApiPropertyType.MethodReturningPromise,
  knownAddresses$: RemoteApiPropertyType.HotObservable,
  setKnownAddresses: RemoteApiPropertyType.MethodReturningPromise,
  signBlob: RemoteApiPropertyType.MethodReturningPromise,
  signTransaction: RemoteApiPropertyType.MethodReturningPromise
};
