import { RemoteApiProperties, RemoteApiPropertyType } from '../../messaging';
import { SigningCoordinatorSignApi } from './types';

export const signingCoordinatorApiChannel = 'signingCoordinator';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const signingCoordinatorApiProperties: RemoteApiProperties<SigningCoordinatorSignApi<any>> = {
  signData: RemoteApiPropertyType.MethodReturningPromise,
  signTransaction: RemoteApiPropertyType.MethodReturningPromise
};
