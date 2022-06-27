import { Observable } from 'rxjs';
import { Origin } from '@cardano-sdk/cip30';
import { RemoteApiProperties, RemoteApiPropertyType } from '@cardano-sdk/web-extension';

export const extensionId = 'lgehgfkeagjdklnanflcjoipaphegomm';

export const ownOrigin = globalThis.location.origin;

export const walletName = 'ccvault';

export const userPromptServiceChannel = `user-prompt-${walletName}`;

export const adaPriceServiceChannel = `ada-price-${walletName}`;

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
