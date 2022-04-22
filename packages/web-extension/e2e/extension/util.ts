import { Origin } from '@cardano-sdk/cip30';

export const extensionId = 'lgehgfkeagjdklnanflcjoipaphegomm';

export const ownOrigin = globalThis.location.origin;

export const walletName = 'ccvault';

export const userPromptServiceChannel = `user-prompt-${walletName}`;

export interface UserPromptService {
  allowOrigin(origin: Origin): Promise<boolean>;
}
