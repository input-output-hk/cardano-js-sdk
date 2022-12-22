import { RemoteApiPropertyType, consumeRemoteApi } from '@cardano-sdk/web-extension';
import { RequestAccess } from '@cardano-sdk/dapp-connector';
import { UserPromptService, logger } from '../util';
import { ensureUiIsOpenAndLoaded } from './windowManager';
import { runtime } from 'webextension-polyfill';
import { userPromptServiceChannel } from '../const';

const userPromptService = consumeRemoteApi<UserPromptService>(
  {
    baseChannel: userPromptServiceChannel,
    properties: {
      allowOrigin: RemoteApiPropertyType.MethodReturningPromise
    }
  },
  { logger, runtime }
);

export const requestAccess: RequestAccess = async (origin) => {
  await ensureUiIsOpenAndLoaded();
  return await userPromptService.allowOrigin(origin);
};
