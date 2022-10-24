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
import { CustomError } from 'ts-custom-error';
import {
  EMPTY,
  EmptyError,
  NEVER,
  Observable,
  concat,
  filter,
  firstValueFrom,
  isObservable,
  map,
  merge,
  mergeMap,
  shareReplay,
  switchMap,
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

export class RemoteApiShutdownError extends CustomError {
  constructor(channel: string) {
    super(`Remote API with channel '${channel}' was shutdown: object can no longer be used.`);
  }
}

const consumeMethod =
  (
    {
      propName,
      getErrorPrototype
    }: { propName: string; getErrorPrototype?: GetErrorPrototype; options?: MethodRequestOptions },
    { messenger: { message$, postMessage, channel } }: MessengerApiDependencies
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
    ).catch((error) => {
      if (error instanceof EmptyError) {
        throw new RemoteApiShutdownError(channel);
      }
      throw error;
    });

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
      shutdown: messenger.shutdown
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
        } else if (propMetadata === RemoteApiPropertyType.HotObservable) {
          const observableMessenger = messenger.deriveChannel(propName);
          const messageData$ = observableMessenger.message$.pipe(map(({ data }) => fromSerializableObject(data)));
          const unsubscribe$ = messageData$.pipe(
            filter(isObservableCompletionMessage),
            filter(({ subscribe }) => !subscribe),
            tap(({ error }) => {
              if (error) throw error;
            })
          );
          return (receiver[prop] = messageData$.pipe(
            takeUntil(unsubscribe$),
            filter(isEmitMessage),
            map(({ emit }) => emit),
            shareReplay(1)
          ));
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
): Shutdown => {
  const subscription = message$.subscribe(async ({ data, port }) => {
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
  return {
    shutdown: () => subscription.unsubscribe()
  };
};

const isRemoteApiMethod = (prop: unknown): prop is RemoteApiMethod =>
  typeof prop === 'object' && prop !== null && 'propType' in prop;

export const bindNestedObjChannels = <API extends object>(
  { api$, properties }: ExposeApiProps<API>,
  { messenger, logger }: MessengerApiDependencies
): Shutdown => {
  const subscriptions = Object.entries(properties)
    .filter(([_, type]) => typeof type === 'object' && !isRemoteApiMethod(type))
    .map(([prop]) =>
      // eslint-disable-next-line no-use-before-define
      exposeMessengerApi(
        {
          api$: api$.pipe(
            tap((api) => {
              // Do not stop for null api. We must unsubscribe the existing subscriptions from nested props
              if (api && (typeof (api as any)[prop] !== 'object' || isObservable((api as any)[prop]))) {
                throw new NotImplementedError(`Trying to expose non-implemented nested object ${prop}`);
              }
            }),
            map((api) => (api ? (api as any)[prop] : api))
          ),
          properties: (properties as any)[prop]
        },
        { logger, messenger: messenger.deriveChannel(prop) }
      )
    );
  return {
    shutdown: () => {
      for (const subscription of subscriptions) {
        subscription.shutdown();
      }
    }
  };
};

export const bindObservableChannels = <API extends object>(
  { api$, properties }: ExposeApiProps<API>,
  { messenger }: MessengerApiDependencies
): Shutdown => {
  const subscriptions = Object.entries(properties)
    .filter(([, propType]) => propType === RemoteApiPropertyType.HotObservable)
    .map(([observableProperty]) => {
      const observable$ = new TrackerSubject(
        api$.pipe(
          tap((api) => {
            if (api && !isObservable(api[observableProperty as keyof API])) {
              throw new NotImplementedError(`Trying to expose non-implemented observable ${observableProperty}`);
            }
          }),
          // Null api (aka stop using the object).
          // Unsubscribe its properties but leave the wrapping subscription open, waiting for a new api object
          switchMap((api) => (api ? ((api as any)[observableProperty] as Observable<unknown>) : NEVER))
        )
      );

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
        observable$.complete();
        connectSubscription.unsubscribe();
        observableSubscription.unsubscribe();
      };
    });
  return {
    shutdown: () => {
      for (const unsubscribe of subscriptions) unsubscribe();
    }
  };
};

/**
 * Bind an API object emitted by `api$` observable to handle messages from other parts of the extension.
 * - This can only used once per channelName per process.
 * - Changing source `api` object is possible by emitting it from the `api$` observable.
 * - Before destroying/disabling an exposed `api` object, emit a `null` on api$ to stop monitoring it.
 * - Methods returning `Promises` will await until the first `api` object is emitted.
 * - Subscriptions to observable properties are kept active until `shutdown()` method is called.
 *   This allows changing the observed `api` object without having to resubscribe the properties.
 * - Observable properties are completed only on calling `shutdown()`.
 *
 * NOTE: All Observables are subscribed when this function is called and an `api` object is emitted by `api$`.
 * Caches and replays (1) last emission upon remote subscription (unless item === null).
 *
 * In addition to errors thrown by the underlying API, methods can throw TypeError
 *
 * @returns object that can be used to shutdown all ports (shuts down 'messenger' dependency)
 */
export const exposeMessengerApi = <API extends object>(
  { api$, properties }: ExposeApiProps<API>,
  dependencies: MessengerApiDependencies
): Shutdown => {
  // keep apiTracker$ alive even if api$ completes. Only shutdown() can complete it
  const apiTracker$ = new TrackerSubject(concat(api$, NEVER));
  const observableChannelsSubscription = bindObservableChannels({ api$: apiTracker$, properties }, dependencies);
  const nestedObjChannelsSubscription = bindNestedObjChannels({ api$: apiTracker$, properties }, dependencies);
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
        // Calling the promise method after `null` api was emitted (aka stop using the object),
        // awaits for a new valid api object.
        const api = await firstValueFrom(apiTracker$.pipe(filter((v) => !!v)));
        const apiTarget: unknown = method in api! && (api as any)[method];
        if (typeof apiTarget !== 'function') {
          throw new TypeError(`No such API method: ${method}`);
        }
        return apiTarget.apply(api, args);
      }
    },
    dependencies
  );
  return {
    shutdown: () => {
      apiTracker$.complete();
      nestedObjChannelsSubscription.shutdown();
      observableChannelsSubscription.shutdown();
      methodHandlerSubscription.shutdown();
      dependencies.messenger.shutdown();
    }
  };
};
