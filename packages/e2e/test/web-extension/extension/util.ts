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
  clearAllowList(): Promise<void>;
}

export const adaPriceProperties: RemoteApiProperties<BackgroundServices> = {
  adaUsd$: RemoteApiPropertyType.HotObservable,
  clearAllowList: RemoteApiPropertyType.MethodReturningPromise
};

export const logger = console;

export const env = getEnv(walletVariables);
