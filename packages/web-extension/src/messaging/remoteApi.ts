// only tested in ../e2e tests
/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  BindRequestHandlerOptions,
  ConsumeRemoteApiOptions,
  ExposeApiProps,
  MessengerApiDependencies,
  MethodRequest,
  MethodRequestMessage,
  MethodResponseMessage,
  RemoteApiProperty
} from './types';
import { EMPTY, filter, firstValueFrom, map, merge, mergeMap } from 'rxjs';
import { isRequestMessage, isResponseMessage, newMessageId } from './util';
import { util } from '@cardano-sdk/core';

/**
 * Creates a proxy to a remote api object
 */
export const consumeMessengerRemoteApi = <T extends object>(
  { properties: validProperties, getErrorPrototype }: ConsumeRemoteApiOptions<T>,
  { messenger: { message$, postMessage } }: MessengerApiDependencies
) =>
  new Proxy<T>({} as T, {
    get(_, prop) {
      if (validProperties[prop as keyof T] === RemoteApiProperty.MethodReturningPromise) {
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
      }
    },
    has(_, p) {
      return p in validProperties;
    }
  });

export const bindMessengerRequestHandler = <Response>(
  { handler }: BindRequestHandlerOptions<Response>,
  { logger, messenger: { message$ } }: MessengerApiDependencies
) =>
  message$.subscribe(async ({ data, port }) => {
    if (!isRequestMessage(data)) return;
    let response: Response | Error;
    try {
      const request = util.fromSerializableObject<MethodRequest>(data.request);
      response = await handler(request, port.sender);
    } catch (error) {
      logger.debug('[MessengerRequestHandler] Error processing message', data, error);
      response = error instanceof Error ? error : new Error('Unknown error');
    }

    const responseMessage: MethodResponseMessage = {
      messageId: data.messageId,
      response: util.toSerializableObject(response)
    };

    // TODO: can this throw if port is closed?
    port.postMessage(responseMessage);
  });

/**
 * Bind an API object to handle messages from other parts of the extension.
 * This can only used once per channelName per process.
 *
 * In addition to errors thrown by the underlying API, methods can throw TypeError
 */
export const exposeMessengerApi = <API extends object>(
  {
    api,
    methodRequestOptions: { validate = async () => void 0, transform = (request: MethodRequest) => request } = {}
  }: ExposeApiProps<API>,
  dependencies: MessengerApiDependencies
) =>
  bindMessengerRequestHandler(
    {
      handler: async (originalRequest, sender) => {
        await validate(originalRequest, sender);
        const { args, method } = transform(originalRequest, sender);
        const apiTarget: unknown = method in api && (api as any)[method];
        if (typeof apiTarget !== 'function') {
          throw new TypeError(`No such API method: ${method}`);
        }
        return apiTarget.apply(api, args);
      }
    },
    dependencies
  );
