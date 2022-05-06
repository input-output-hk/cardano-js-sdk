// only tested in ../e2e tests
/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  BindRequestHandlerOptions,
  ConsumeRemoteApiOptions,
  EmitMessage,
  ExposeApiProps,
  Messenger,
  MessengerApiDependencies,
  MethodRequest,
  RemoteApiProperty,
  RequestMessage,
  ResponseMessage,
  SubscriptionMessage
} from './types';
import {
  EMPTY,
  Observable,
  filter,
  firstValueFrom,
  isObservable,
  map,
  merge,
  mergeMap,
  take,
  takeUntil,
  tap,
  timeout
} from 'rxjs';
// Review: this import doesn't feel right - might make sense to hoist this to a shared util package.
// However I'm planning to export a utility to `exposeObservableWallet`
// from web-extension package, so this is ok in terms of dependency tree
import { TrackerSubject } from '@cardano-sdk/wallet';
import { isEmitMessage, isRequestMessage, isResponseMessage, isSubscriptionMessage, newMessageId } from './util';
import { util } from '@cardano-sdk/core';

export interface Shutdown {
  // Review: Name of this method is imposed by ObservableWallet
  // for easier implementation to reuse the same method name
  // to disconnect the observable channels.
  // Might be a good idea to hoist this interface somewhere and use it as base for ObservableWallet interface.
  shutdown: () => void;
}

const SUBSCRIPTION_TIMEOUT = 3000;
const throwIfObservableChannelDoesntExist = ({ postMessage, message$ }: Messenger) => {
  const subscriptionMessageId = newMessageId();
  return merge(
    postMessage({
      messageId: subscriptionMessageId,
      subscribe: true
    } as SubscriptionMessage),
    // timeout if the other end didn't acknowledge the subscription with a ResponseMessage
    message$.pipe(
      map(({ data }) => data),
      filter(isResponseMessage),
      filter(({ messageId }) => messageId === subscriptionMessageId),
      timeout({ first: SUBSCRIPTION_TIMEOUT }),
      take(1)
    )
  ).pipe(mergeMap(() => EMPTY));
};

/**
 * Creates a proxy to a remote api object
 *
 * @throws Observable subscriptions might error with rxjs TimeoutError if the remote observable doesnt exist
 */
export const consumeMessengerRemoteApi = <T extends object>(
  { properties, getErrorPrototype }: ConsumeRemoteApiOptions<T>,
  { messenger: { message$, postMessage, deriveChannel: derive, destroy } }: MessengerApiDependencies
) =>
  new Proxy<T & Shutdown>(
    {
      shutdown: destroy
    } as T & Shutdown,
    {
      get(target, prop) {
        if (prop in target) return (target as any)[prop];
        const propType = properties[prop as keyof T];
        const propName = prop.toString();
        if (propType === RemoteApiProperty.MethodReturningPromise) {
          return async (...args: unknown[]) => {
            const requestMessage: RequestMessage = {
              messageId: newMessageId(),
              request: {
                args: args.map(util.toSerializableObject),
                method: propName
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
        } else if (propType === RemoteApiProperty.Observable) {
          const observableMessenger = derive(propName);
          const messageData$ = observableMessenger.message$.pipe(map(({ data }) => data));
          const unsubscribe$ = messageData$.pipe(
            filter(isSubscriptionMessage),
            filter(({ subscribe }) => !subscribe),
            tap(({ error }) => {
              if (error) throw error;
            })
          );
          return merge(
            throwIfObservableChannelDoesntExist(observableMessenger),
            messageData$.pipe(
              filter(isEmitMessage),
              map(({ emit }) => emit)
            )
          ).pipe(takeUntil(unsubscribe$));
        }
      },
      has(_, p) {
        return p in properties;
      }
    }
  );

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

    const responseMessage: ResponseMessage = {
      messageId: data.messageId,
      response: util.toSerializableObject(response)
    };

    // TODO: can this throw if port is closed?
    port.postMessage(responseMessage);
  });

export const bindObservableChannels = <API extends object>(api: API, { messenger }: MessengerApiDependencies) => {
  const subscriptions = Object.keys(api)
    .filter((method) => isObservable((api as any)[method]))
    .map((observableProperty) => {
      const observable$ = new TrackerSubject((api as any)[observableProperty] as Observable<unknown>);
      const observableMessenger = messenger.deriveChannel(observableProperty);
      const ackSubscription = observableMessenger.message$.subscribe(({ data, port }) => {
        if (isSubscriptionMessage(data) && data.subscribe) {
          port.postMessage({ messageId: data.messageId, response: true } as ResponseMessage);
          if (observable$.value !== null) {
            port.postMessage({ emit: observable$.value, messageId: newMessageId() } as EmitMessage);
          }
        }
      });
      const broadcastMessage = (message: Partial<SubscriptionMessage | EmitMessage>) =>
        observableMessenger
          .postMessage({
            messageId: newMessageId(),
            ...message
          })
          .subscribe();
      const observableSubscription = observable$.subscribe({
        complete: () => broadcastMessage({ subscribe: false }),
        error: (error: Error) => broadcastMessage({ error, subscribe: false }),
        next: (emit: unknown) => broadcastMessage({ emit })
      });
      return () => {
        ackSubscription.unsubscribe();
        observableSubscription.unsubscribe();
        observable$.complete();
      };
    });
  return {
    unsubscribe: () => {
      for (const unsubscribe of subscriptions) unsubscribe();
    }
  };
};

/**
 * Bind an API object to handle messages from other parts of the extension.
 * This can only used once per channelName per process.
 *
 * NOTE: All Observables are subscribed when this function is called.
 * Caches and replays (1) last emission upon remote subscription (unless item === null).
 *
 * In addition to errors thrown by the underlying API, methods can throw TypeError
 */
export const exposeMessengerApi = <API extends object>(
  {
    api,
    methodRequestOptions: { validate = async () => void 0, transform = (request: MethodRequest) => request } = {}
  }: ExposeApiProps<API>,
  dependencies: MessengerApiDependencies
) => {
  const observableChannelsSubscription = bindObservableChannels(api, dependencies);
  const methodHandlerSubscription = bindMessengerRequestHandler(
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
  return {
    unsubscribe: () => {
      observableChannelsSubscription.unsubscribe();
      methodHandlerSubscription.unsubscribe();
    }
  };
};
