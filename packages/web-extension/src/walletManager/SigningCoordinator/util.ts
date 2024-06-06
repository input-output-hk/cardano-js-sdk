import { RemoteApiPropertyType } from '../../messaging/index.js';
import type { RemoteApiProperties } from '../../messaging/index.js';
import type { SigningCoordinatorSignApi } from './types.js';

export const signingCoordinatorApiChannel = 'signingCoordinator';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const signingCoordinatorApiProperties: RemoteApiProperties<SigningCoordinatorSignApi<any, any>> = {
  signData: RemoteApiPropertyType.MethodReturningPromise,
  signTransaction: RemoteApiPropertyType.MethodReturningPromise
};
