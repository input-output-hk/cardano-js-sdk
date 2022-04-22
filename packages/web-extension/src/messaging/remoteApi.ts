// only tested in ../e2e tests
/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  BindRequestHandlerOptions,
  ConsumeRemotePromiseApiOptions,
  ExposePromiseApiProps,
  MessengerApiDependencies,
  MethodRequestMessage,
  MethodResponseMessage
} from './types';
import { EMPTY, filter, firstValueFrom, map, merge, mergeMap } from 'rxjs';
import { isRequestMessage, isResponseMessage, newMessageId } from './util';
import { util } from '@cardano-sdk/core';

/**
 * Only compatible with interfaces where all methods return a Promise.
 */
export const consumeMessengerRemotePromiseApi = <T extends object>(
  { validMethodNames, getErrorPrototype }: ConsumeRemotePromiseApiOptions<T>,
  { messenger: { message$, postMessage } }: MessengerApiDependencies
) =>
  new Proxy<T>({} as T, {
    get(_, prop, receiver) {
      if (!(prop in receiver)) return;

      return async (...args: unknown[]) => {
        const requestMessage: MethodRequestMessage = {
          messageId: newMessageId(),
          request: {
            args: args.map(util.toSerializableObject),
            method: prop.toString()
          }
        };

        const result = await firstValueFrom(
          merge(
            postMessage(requestMessage).pipe(mergeMap(() => EMPTY)),
            message$.pipe(
              map(({ data }) => data),
              filter(isResponseMessage),
              filter(({ messageId }) => messageId === requestMessage.messageId),
              map(({ response }) => util.fromSerializableObject(response, getErrorPrototype))
            )
          )
        );

        if (result instanceof Error) {
          throw result;
        }
        return result;
      };
    },
    has(_, p) {
      return validMethodNames.includes(p.toString() as keyof T);
    }
  });

export const bindMessengerRequestHandler = <Response>(
  { channelName, handler }: BindRequestHandlerOptions<Response>,
  { logger, messenger: { message$ } }: MessengerApiDependencies
) =>
  message$.subscribe(async ({ data, port }) => {
    if (!isRequestMessage(data)) return;
    let response: Response | Error;
    try {
      response = await handler(util.fromSerializableObject(data.request), port.sender);
    } catch (error) {
      logger.debug(`[BackgroundMessenger] Error processing message at channel "${channelName}"`, data, error);
      response = error instanceof Error ? error : new Error('Unknown error');
    }

    const responseMessage: MethodResponseMessage = {
      messageId: data.messageId,
      response: util.toSerializableObject(response)
    };

    // Can this throw if port is closed?
    port.postMessage(responseMessage);
  });

/**
 * Bind promise-based API object to handle messages from other parts of the extension.
 * This can only used once per channelName per process.
 *
 * In addition to errors thrown by the underlying API, methods can throw TypeError
 */
export const exposeMessengerPromiseApi = <API extends object>(
  {
    channel,
    api,
    validateRequest = async () => void 0,
    transformRequest = (request) => request
  }: ExposePromiseApiProps<API>,
  dependencies: MessengerApiDependencies
) =>
  bindMessengerRequestHandler(
    {
      channelName: channel,
      handler: async (originalRequest, sender) => {
        await validateRequest(originalRequest, sender);
        const { args, method } = transformRequest(originalRequest, sender);
        const apiMethod: unknown = method in api && (api as any)[method];
        if (typeof apiMethod !== 'function') {
          throw new TypeError(`No such API method: ${method}`);
        }
        return apiMethod.apply(
          api,
          args.map((arg) => util.fromSerializableObject(arg))
        );
      }
    },
    dependencies
  );
