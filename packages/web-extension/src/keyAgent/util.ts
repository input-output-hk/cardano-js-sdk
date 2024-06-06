import { RemoteApiPropertyType } from '../messaging/index.js';
import type { AsyncKeyAgent } from '@cardano-sdk/key-management';
import type { RemoteApiProperties } from '../messaging/index.js';

export const keyAgentChannel = (walletName: string) => `${walletName}$-keyAgent`;

export const keyAgentProperties: RemoteApiProperties<AsyncKeyAgent> = {
  deriveAddress: RemoteApiPropertyType.MethodReturningPromise,
  derivePublicKey: RemoteApiPropertyType.MethodReturningPromise,
  getAccountIndex: RemoteApiPropertyType.MethodReturningPromise,
  getBip32Ed25519: RemoteApiPropertyType.MethodReturningPromise,
  getChainId: RemoteApiPropertyType.MethodReturningPromise,
  getExtendedAccountPublicKey: RemoteApiPropertyType.MethodReturningPromise,
  signBlob: RemoteApiPropertyType.MethodReturningPromise,
  signTransaction: RemoteApiPropertyType.MethodReturningPromise
};
