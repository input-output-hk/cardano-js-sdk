// only tested in ../e2e tests
/* eslint-disable @typescript-eslint/no-explicit-any */
import { Logger } from 'ts-log';
import { MethodRequest, ResponseMessage } from './types';
import { isRequestMessage } from './util';
import { toSerializableObject } from '@cardano-sdk/util';

export type AnyApi = any;

export interface MessagingApi {
  isApiMethod<T extends AnyApi>(method: string | symbol | number): method is keyof T;
  callApiMethod(request: MethodRequest): Promise<unknown>;
}

interface ChannelMessageEvent {
  channelName: string;
  request: MethodRequest;
  messageId: string;
}

/**
 * Intended to be run in web extension content script.
 * Forwards messages dispatched via window.postMessage from the website to the extension (background page).
 */
export const runContentScriptMessageProxy = (apis: Record<string, AnyApi>, logger: Logger) => {
  const listener = async ({ data, source }: MessageEvent<ChannelMessageEvent>) => {
    // eslint-disable-next-line eqeqeq
    if (source !== window || !isRequestMessage(data)) return;
    logger.debug('[MessageProxy] from window', data);

    const { channelName, request, messageId } = data;
    const api = apis[channelName];
    if (!api) return;

    // const apiFunction = apis.find((api: any) => typeof api[data.request.method] === 'function')?.[data.request.method];
    const apiFunction = api[request.method];
    if (!apiFunction) return;

    let response;
    try {
      response = await apiFunction(...request.args);
    } catch (error) {
      response = error;
    }

    const responseMessage: ResponseMessage = {
      messageId,
      response: toSerializableObject(response)
    };

    window.postMessage(responseMessage, source.origin);
  };
  window.addEventListener('message', listener);
  return () => window.removeEventListener('message', listener);
};
