/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  BindRequestHandlerOptions,
  CompletionMessage,
  ConsumeMessengerApiDependencies,
  ConsumeRemoteApiOptions,
  EmitMessage,
  ExposableRemoteApi,
  ExposeApiProps,
  FactoryCallMessage,
  MessengerApiDependencies,
  MethodRequest,
  MethodRequestOptions,
  RemoteApiFactory,
  RemoteApiMethod,
  RemoteApiProperties,
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
  Subscription,
  TeardownLogic,
  concat,
  filter,
  firstValueFrom,
  from,
  isObservable,
  map,
  merge,
  mergeMap,
  of,
  shareReplay,
  switchMap,
  takeUntil,
  tap,
  throwError
} from 'rxjs';
import { ErrorClass, Shutdown, fromSerializableObject, isPromise, toSerializableObject } from '@cardano-sdk/util';
import { NotImplementedError } from '@cardano-sdk/core';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import { WrongTargetError } from './errors';
import {
  disabledApiMsg,
  isCompletionMessage,
  isEmitMessage,
  isFactoryCallMessage,
  isNotDisabledApiMsg,
  isRequestMessage,
  isResponseMessage,
  newMessageId
} from './util';
import { v4 as uuidv4 } from 'uuid';

export class RemoteApiShutdownError extends CustomError {
  constructor(channel: string) {
    super(`Remote API with channel '${channel}' was shutdown: object can no longer be used.`);
  }
}

const consumeMethod =
  (
    { propName, errorTypes }: { propName: string; errorTypes?: ErrorClass[]; options?: MethodRequestOptions },
    { messenger: { message$, postMessage, channel, disconnect$ } }: MessengerApiDependencies
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
          map(({ data }) => fromSerializableObject(data, { errorTypes: [...(errorTypes || []), WrongTargetError] })),
          filter(isResponseMessage),
          filter(({ messageId }) => messageId === requestMessage.messageId),
          map(({ response }) => response),
          filter((response) => !(response instanceof WrongTargetError))
        ),
        disconnect$.pipe(
          filter((dc) => dc.remaining.length === 0),
          mergeMap(() => throwError(() => new EmptyError()))
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

interface ConsumeFactoryProps<T> {
  method: string;
  apiProperties: RemoteApiProperties<T>;
  errorTypes: ErrorClass[] | undefined;
}

const consumeFactory =
  <T>(
    { method, apiProperties, errorTypes }: ConsumeFactoryProps<T>,
    { logger, messenger, destructor }: ConsumeMessengerApiDependencies
  ) =>
  (...args: unknown[]) => {
    const factoryChannelNo = uuidv4();
    const channel = `${method}-${factoryChannelNo}`;
    const postSubscription = messenger
      .postMessage({
        factoryCall: { args: toSerializableObject(args), channel, method },
        messageId: newMessageId()
      } as FactoryCallMessage)
      .subscribe();
    const apiMessenger = messenger.deriveChannel(channel, { detached: true });
    // eslint-disable-next-line no-use-before-define
    const api = consumeMessengerRemoteApi(
      {
        errorTypes,
        properties: apiProperties
      },
      {
        destructor,
        logger,
        messenger: apiMessenger
      }
    );
    destructor.onGarbageCollected(api, factoryChannelNo, () => {
      if (apiMessenger.isShutdown) {
        return;
      }
      apiMessenger
        .postMessage({
          messageId: newMessageId(),
          subscribe: false
        } as CompletionMessage)
        .subscribe(() => {
          postSubscription.unsubscribe();
          apiMessenger.shutdown();
        });
    });

    // Since it returns synchronously, we can't catch potential errors.
    // If factory method throws on the remote side, it might be a good idea to "brick" the returned api object:
    // immediately reject on all method calls and error on observable subscriptions,
    return api;
  };

/** Creates a proxy to a remote api object */
export const consumeMessengerRemoteApi = <T extends object>(
  { properties, errorTypes }: ConsumeRemoteApiOptions<T>,
  { logger, messenger, destructor }: ConsumeMessengerApiDependencies
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
            switch (propMetadata.propType) {
              case RemoteApiPropertyType.MethodReturningPromise: {
                return (receiver[prop] = consumeMethod(
                  { errorTypes, options: propMetadata.requestOptions, propName },
                  { logger, messenger }
                ));
              }
              case RemoteApiPropertyType.ApiFactory: {
                return (receiver[prop] = consumeFactory(
                  { apiProperties: propMetadata.getApiProperties(), errorTypes, method: propName },
                  { destructor, logger, messenger }
                ));
              }
            }
          } else {
            return (receiver[prop] = consumeMessengerRemoteApi(
              { errorTypes, properties: propMetadata as any },
              { destructor, logger, messenger: messenger.deriveChannel(propName) }
            ));
          }
        } else if (propMetadata === RemoteApiPropertyType.MethodReturningPromise) {
          return (receiver[prop] = consumeMethod({ errorTypes, propName }, { logger, messenger }));
        } else if (propMetadata === RemoteApiPropertyType.HotObservable) {
          const observableMessenger = messenger.deriveChannel(propName);
          const messageData$ = observableMessenger.message$.pipe(map(({ data }) => fromSerializableObject(data)));
          const unsubscribe$ = messageData$.pipe(
            filter(isCompletionMessage),
            filter(({ subscribe }) => !subscribe),
            tap(({ error }) => {
              if (error) throw error;
            })
          );
          return (receiver[prop] = messageData$.pipe(
            takeUntil(unsubscribe$),
            filter(isEmitMessage),
            map(({ emit }) => emit),
            shareReplay(1),
            filter(isNotDisabledApiMsg) // Do not replay values from an api object that was disabled
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
  { logger, messenger: { message$, postMessage } }: MessengerApiDependencies
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

    postMessage(responseMessage).subscribe();
  });
  return {
    shutdown: () => subscription.unsubscribe()
  };
};

const isObject = (prop: unknown) => typeof prop === 'object' && prop !== null;

const hasPropType = (prop: unknown, propType: RemoteApiPropertyType) =>
  isObject(prop) && (prop as any).propType === propType;

const hasAnyPropType = (prop: unknown) => isObject(prop) && typeof (prop as any).propType === 'number';

const isRemoteApiMethod = (prop: unknown): prop is RemoteApiMethod =>
  hasPropType(prop, RemoteApiPropertyType.MethodReturningPromise);

const isRemoteApiFactory = (prop: unknown): prop is RemoteApiFactory<unknown> =>
  hasPropType(prop, RemoteApiPropertyType.ApiFactory);

export const bindNestedObjChannels = <API extends object>(
  { api$, properties }: ExposeApiProps<API>,
  { messenger, logger }: MessengerApiDependencies
): Shutdown => {
  const subscriptions = Object.entries(properties)
    .filter(([_, type]) => typeof type === 'object' && !hasAnyPropType(type))
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

export const bindFactoryMethods = <API extends object>(
  { api$, properties }: ExposeApiProps<API>,
  { messenger, logger }: MessengerApiDependencies
): Shutdown => {
  const subscription = messenger.message$.subscribe(async ({ data }) => {
    if (!isFactoryCallMessage(data)) return;
    const propertyDefinition = (properties as any)[data.factoryCall.method];
    if (!isRemoteApiFactory(propertyDefinition)) {
      logger.warn(`Invalid or missing property definition for api factory method '${data.factoryCall.method}'`);
      return;
    }
    try {
      const args = fromSerializableObject<MethodRequest>(data.factoryCall.args);
      const { method, channel } = data.factoryCall;
      const factoryMessenger = messenger.deriveChannel(channel, { detached: true });
      // eslint-disable-next-line no-use-before-define
      const api = exposeMessengerApi(
        {
          api$: api$.pipe(
            switchMap((baseApi) => {
              if (!baseApi) return NEVER;
              const apiMethod = (baseApi as any)[method];
              if (typeof apiMethod !== 'function') {
                logger.warn('No api method', method);
                return EMPTY;
              }
              const returnedApi = apiMethod.apply(baseApi, args);
              if (isPromise(returnedApi)) {
                return from(returnedApi);
              }
              return of(returnedApi);
            })
          ),
          properties: propertyDefinition.getApiProperties()
        },
        {
          logger,
          messenger: factoryMessenger
        }
      );
      let completeSubscription: Subscription | null = null;
      const teardown: TeardownLogic = () => {
        completeSubscription?.unsubscribe();
        api.shutdown();
      };
      completeSubscription = factoryMessenger.message$.subscribe((msg) => {
        if (isCompletionMessage(msg.data)) {
          teardown();
        }
      });
    } catch (error) {
      logger.debug('[bindFactoryMethods] error exposing api', data, error);
    }
  });
  return {
    shutdown: () => {
      subscription.unsubscribe();
    }
  };
};

export const bindObservableChannels = <API extends object>(
  { api$, properties }: ExposeApiProps<API>,
  { messenger, logger }: MessengerApiDependencies
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
          // Send an internal disabledApiMsg to consumerApi, so it stops replaying values from disabled api object
          switchMap((api) => (api ? ((api as any)[observableProperty] as Observable<unknown>) : of(disabledApiMsg)))
        )
      );

      const observableMessenger = messenger.deriveChannel(observableProperty);
      const connectSubscription = observableMessenger.connect$.subscribe((port) => {
        if (observable$.value !== null) {
          try {
            port.postMessage(
              toSerializableObject({ emit: observable$.value, messageId: newMessageId() } as EmitMessage)
            );
          } catch (error) {
            logger.warn('Failed to emit initial value, port immediatelly disconnected?', error);
          }
        }
      });
      const broadcastMessage = (message: Partial<CompletionMessage | EmitMessage>) =>
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
  const factoryMethodsSubscription = bindFactoryMethods({ api$: apiTracker$, properties }, dependencies);
  const methodHandlerSubscription = bindMessengerRequestHandler(
    {
      handler: async (originalRequest, sender) => {
        const property = properties[originalRequest.method as keyof ExposableRemoteApi<API>];
        if (
          typeof property === 'undefined' ||
          (property !== RemoteApiPropertyType.MethodReturningPromise && !isRemoteApiMethod(property))
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
      factoryMethodsSubscription.shutdown();
      observableChannelsSubscription.shutdown();
      methodHandlerSubscription.shutdown();
      dependencies.messenger.shutdown();
    }
  };
};
