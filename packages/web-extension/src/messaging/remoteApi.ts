/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  BindRequestHandlerOptions,
  ConsumeRemoteApiOptions,
  EmitMessage,
  ExposableRemoteApi,
  ExposeApiProps,
  MessengerApiDependencies,
  MethodRequest,
  MethodRequestOptions,
  ObservableCompletionMessage,
  RemoteApiMethod,
  RemoteApiPropertyType,
  RequestMessage,
  ResponseMessage
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
  shareReplay,
  takeUntil,
  tap
} from 'rxjs';
import { GetErrorPrototype, Shutdown, fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';
import { NotImplementedError } from '@cardano-sdk/core';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import {
  isEmitMessage,
  isObservableCompletionMessage,
  isRequestMessage,
  isResponseMessage,
  newMessageId
} from './util';

const consumeMethod =
  (
    {
      propName,
      getErrorPrototype
    }: { propName: string; getErrorPrototype?: GetErrorPrototype; options?: MethodRequestOptions },
    { messenger: { message$, postMessage } }: MessengerApiDependencies
  ) =>
  async (...args: unknown[]) => {
    const requestMessage: RequestMessage = {
      messageId: newMessageId(),
      request: {
        args: args.map((arg) => toSerializableObject(arg)),
        method: propName
      }
    };

    const result = await firstValueFrom(
      merge(
        postMessage(requestMessage).pipe(mergeMap(() => EMPTY)),
        message$.pipe(
          map(({ data }) => fromSerializableObject(data, { getErrorPrototype })),
          filter(isResponseMessage),
          filter(({ messageId }) => messageId === requestMessage.messageId),
          map(({ response }) => response)
        )
      )
    );

    if (result instanceof Error) {
      throw result;
    }
    return result;
  };

/**
 * Creates a proxy to a remote api object
 */
export const consumeMessengerRemoteApi = <T extends object>(
  { properties, getErrorPrototype }: ConsumeRemoteApiOptions<T>,
  { logger, messenger }: MessengerApiDependencies
): T & Shutdown =>
  new Proxy<T & Shutdown>(
    {
      shutdown: messenger.destroy
    } as T & Shutdown,
    {
      get(target, prop, receiver) {
        if (prop in target) return (target as any)[prop];
        const propMetadata = properties[prop as keyof ExposableRemoteApi<T>];
        const propName = prop.toString();
        if (typeof propMetadata === 'object') {
          if ('propType' in propMetadata) {
            if (propMetadata.propType === RemoteApiPropertyType.MethodReturningPromise) {
              return (receiver[prop] = consumeMethod(
                { getErrorPrototype, options: propMetadata.requestOptions, propName },
                { logger, messenger }
              ));
            }
            throw new NotImplementedError('Only MethodReturningPromise prop type can be specified as object');
          } else {
            return (receiver[prop] = consumeMessengerRemoteApi(
              { getErrorPrototype, properties: propMetadata as any },
              { logger, messenger: messenger.deriveChannel(propName) }
            ));
          }
        } else if (propMetadata === RemoteApiPropertyType.MethodReturningPromise) {
          return (receiver[prop] = consumeMethod({ getErrorPrototype, propName }, { logger, messenger }));
        } else if (propMetadata === RemoteApiPropertyType.Observable) {
          const observableMessenger = messenger.deriveChannel(propName);
          const messageData$ = observableMessenger.message$.pipe(map(({ data }) => fromSerializableObject(data)));
          const unsubscribe$ = messageData$.pipe(
            filter(isObservableCompletionMessage),
            filter(({ subscribe }) => !subscribe),
            tap(({ error }) => {
              if (error) throw error;
            })
          );
          return (receiver[prop] = messageData$
            .pipe(
              filter(isEmitMessage),
              map(({ emit }) => emit),
              shareReplay(1)
            )
            .pipe(takeUntil(unsubscribe$)));
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
      const request = fromSerializableObject<MethodRequest>(data.request);
      response = await handler(request, port.sender);
    } catch (error) {
      logger.debug('[MessengerRequestHandler] Error processing message', data, error);
      response = error instanceof Error ? error : new Error('Unknown error');
    }

    const responseMessage: ResponseMessage = {
      messageId: data.messageId,
      response: toSerializableObject(response)
    };

    // TODO: can this throw if port is closed?
    port.postMessage(responseMessage);
  });

const isRemoteApiMethod = (prop: unknown): prop is RemoteApiMethod =>
  typeof prop === 'object' && prop !== null && 'propType' in prop;

export const bindNestedObjChannels = <API extends object>(
  { api, properties }: ExposeApiProps<API>,
  { messenger, logger }: MessengerApiDependencies
) => {
  const subscriptions = Object.entries(properties)
    .filter(([_, type]) => typeof type === 'object' && !isRemoteApiMethod(type))
    .map(([prop]) => {
      if (typeof (api as any)[prop] !== 'object' || isObservable((api as any)[prop])) {
        throw new NotImplementedError(`Trying to expose non-implemented nested object ${prop}`);
      }
      // eslint-disable-next-line no-use-before-define
      return exposeMessengerApi(
        { api: (api as any)[prop], properties: (properties as any)[prop] },
        { logger, messenger: messenger.deriveChannel(prop) }
      );
    });
  return {
    unsubscribe: () => {
      for (const subscription of subscriptions) {
        subscription.unsubscribe();
      }
    }
  };
};

export const bindObservableChannels = <API extends object>(
  { api, properties }: ExposeApiProps<API>,
  { messenger }: MessengerApiDependencies
) => {
  const subscriptions = Object.entries(properties)
    .filter(([, propType]) => propType === RemoteApiPropertyType.Observable)
    .map(([observableProperty]) => {
      if (!isObservable(api[observableProperty as keyof API])) {
        throw new NotImplementedError(`Trying to expose non-implemented observable ${observableProperty}`);
      }
      const observable$ = new TrackerSubject((api as any)[observableProperty] as Observable<unknown>);
      const observableMessenger = messenger.deriveChannel(observableProperty);
      const connectSubscription = observableMessenger.connect$.subscribe((port) => {
        if (observable$.value !== null) {
          port.postMessage(toSerializableObject({ emit: observable$.value, messageId: newMessageId() } as EmitMessage));
        }
      });
      const broadcastMessage = (message: Partial<ObservableCompletionMessage | EmitMessage>) =>
        observableMessenger
          .postMessage({
            messageId: newMessageId(),
            ...(toSerializableObject(message) as object)
          })
          .subscribe();
      const observableSubscription = observable$.subscribe({
        complete: () => broadcastMessage({ subscribe: false }),
        error: (error: Error) => broadcastMessage({ error, subscribe: false }),
        next: (emit: unknown) => broadcastMessage({ emit })
      });
      return () => {
        connectSubscription.unsubscribe();
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
  { api, properties }: ExposeApiProps<API>,
  dependencies: MessengerApiDependencies
) => {
  const observableChannelsSubscription = bindObservableChannels({ api, properties }, dependencies);
  const nestedObjChannelsSubscription = bindNestedObjChannels({ api, properties }, dependencies);
  const methodHandlerSubscription = bindMessengerRequestHandler(
    {
      handler: async (originalRequest, sender) => {
        const property = properties[originalRequest.method as keyof ExposableRemoteApi<API>];
        if (
          typeof property === 'undefined' ||
          (property !== RemoteApiPropertyType.MethodReturningPromise &&
            isRemoteApiMethod(property) &&
            property.propType !== RemoteApiPropertyType.MethodReturningPromise)
        ) {
          throw new Error(`Attempted to call a method that was not explicitly exposed: ${originalRequest.method}`);
        }
        const { validate = async () => void 0, transform = (req) => req } = isRemoteApiMethod(property)
          ? property.requestOptions
          : ({} as MethodRequestOptions);
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
      nestedObjChannelsSubscription.unsubscribe();
      observableChannelsSubscription.unsubscribe();
      methodHandlerSubscription.unsubscribe();
    }
  };
};
