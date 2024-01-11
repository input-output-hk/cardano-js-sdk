import { Cardano } from '@cardano-sdk/core';
import { Observable } from 'rxjs';
import { Origin } from '@cardano-sdk/dapp-connector';
import { RemoteApiProperties, RemoteApiPropertyType } from '@cardano-sdk/web-extension';
// eslint-disable-next-line import/no-extraneous-dependencies
import { getEnv, walletVariables } from '@cardano-sdk/e2e';

export interface UserPromptService {
  allowOrigin(origin: Origin): Promise<boolean>;
}

export interface BackgroundServices {
  adaUsd$: Observable<number>;
  /** BG script will use this observable to send the result of consumedApi promise api call while port is disconnected by UI side */
  apiDisconnectResult$: Observable<string>;
  clearAllowList(): Promise<void>;
  getPoolIds(count: number): Promise<Cardano.StakePool[]>;
}

export const adaPriceProperties: RemoteApiProperties<BackgroundServices> = {
  adaUsd$: RemoteApiPropertyType.HotObservable,
  apiDisconnectResult$: RemoteApiPropertyType.HotObservable,
  clearAllowList: RemoteApiPropertyType.MethodReturningPromise,
  getPoolIds: RemoteApiPropertyType.MethodReturningPromise
};

// Dummy object to be used with remoteApi to test that promise rejects in case of disconnected port
export interface DisconnectPortTestObj {
  promiseMethod(): Promise<void>;
}
export const disconnectPortTestObjProperties: RemoteApiProperties<DisconnectPortTestObj> = {
  promiseMethod: RemoteApiPropertyType.MethodReturningPromise
};

export const logger = console;

export const env = getEnv(walletVariables);

export type Metadata = { name: string };
