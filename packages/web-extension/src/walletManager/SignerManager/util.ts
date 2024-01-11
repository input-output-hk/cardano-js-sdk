import { RemoteApiProperties, RemoteApiPropertyType } from '../../messaging';
import { SignerManagerSignApi } from './types';

export const signerManagerApiChannel = 'signerManager';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const signerManagerApiProperties: RemoteApiProperties<SignerManagerSignApi<any>> = {
  signData: RemoteApiPropertyType.MethodReturningPromise,
  signTransaction: RemoteApiPropertyType.MethodReturningPromise
};
