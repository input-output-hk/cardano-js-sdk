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

export interface AdaPriceService {
  adaUsd$: Observable<number>;
}

export const adaPriceProperties: RemoteApiProperties<AdaPriceService> = {
  adaUsd$: RemoteApiPropertyType.Observable
};
