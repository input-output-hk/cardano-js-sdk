import { RemoteApiPropertyType, consumeRemoteApi } from '@cardano-sdk/web-extension';
import { ensureUiIsOpenAndLoaded } from './windowManager.js';
import { logger } from '../util.js';
import { runtime } from 'webextension-polyfill';
import { senderOrigin } from '@cardano-sdk/dapp-connector';
import { userPromptServiceChannel } from '../const.js';
import type { RequestAccess } from '@cardano-sdk/dapp-connector';
import type { UserPromptService } from '../util.js';

const userPromptService = consumeRemoteApi<UserPromptService>(
  {
    baseChannel: userPromptServiceChannel,
    properties: {
      allowOrigin: RemoteApiPropertyType.MethodReturningPromise
    }
  },
  { logger, runtime }
);

export const requestAccess: RequestAccess = async (sender) => {
  const origin = senderOrigin(sender);
  if (!origin) throw new Error('Invalid requestAccess request: unknown sender origin');
  await ensureUiIsOpenAndLoaded();
  return await userPromptService.allowOrigin(origin);
};
