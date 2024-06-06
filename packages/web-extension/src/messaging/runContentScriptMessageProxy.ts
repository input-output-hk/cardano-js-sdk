// only tested in ../e2e tests
/* eslint-disable @typescript-eslint/no-explicit-any */
import { isRequestMessage } from './util.js';
import { toSerializableObject } from '@cardano-sdk/util';
import type { Logger } from 'ts-log';
import type { MethodRequest, ResponseMessage } from './types.js';

export type AnyApi = any;

export interface MessagingApi {
  isApiMethod<T extends AnyApi>(method: string | symbol | number): method is keyof T;
  callApiMethod(request: MethodRequest): Promise<unknown>;
}

/**
 * Intended to be run in web extension content script.
 * Forwards messages dispatched via window.postMessage from the website to the extension (background page).
 */
export const runContentScriptMessageProxy = (apis: AnyApi[], logger: Logger) => {
  const listener = async ({ data, source }: MessageEvent) => {
    // eslint-disable-next-line eqeqeq
    if (source !== window || !isRequestMessage(data)) return;
    logger.debug('[MessageProxy] from window', data);
    const apiFunction = apis.find((api: any) => typeof api[data.request.method] === 'function')?.[data.request.method];
    if (!apiFunction) return;

    let response;
    try {
      response = await apiFunction(...data.request.args);
    } catch (error) {
      response = error;
    }

    const responseMessage: ResponseMessage = {
      messageId: data.messageId,
      response: toSerializableObject(response)
    };

    window.postMessage(responseMessage, source.origin);
  };
  window.addEventListener('message', listener);
  return () => window.removeEventListener('message', listener);
};
