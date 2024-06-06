// only tested in ../e2e tests
/* eslint-disable no-use-before-define */
import {
  BehaviorSubject,
  EmptyError,
  ReplaySubject,
  Subject,
  catchError,
  debounceTime,
  filter,
  first,
  map,
  of,
  takeWhile,
  tap
} from 'rxjs';
import { deriveChannelName } from './util.js';
import { isNotNil } from '@cardano-sdk/util';
import { retryBackoff } from 'backoff-rxjs';
import type {
  DeriveChannelOptions,
  DisconnectEvent,
  Messenger,
  MessengerDependencies,
  MessengerPort,
  PortMessage,
  ReconnectConfig
} from './types.js';
import type { Observable } from 'rxjs';

export interface NonBackgroundMessengerOptions {
  baseChannel: string;
  reconnectConfig?: ReconnectConfig;
}

/** Creates and maintains a long-running connection to background process. Attempts to reconnect the port on disconnects. */
export const createNonBackgroundMessenger = (
  {
    baseChannel: channel,
    reconnectConfig: { initialDelay, maxDelay } = { initialDelay: 10, maxDelay: 1000 }
  }: NonBackgroundMessengerOptions,
  { logger, runtime }: MessengerDependencies
): Messenger => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let reconnectTimeout: any;
  let delay = initialDelay;
  let isDestroyed = false;
  const disconnect$ = new Subject<DisconnectEvent>();
  const port$ = new BehaviorSubject<MessengerPort | null | 'shutdown'>(null);
  // Originally this was a 'new Subject()', but there seems to be a race between
  // - when it receives a value from 'onMessage'
  // - when message$ is subscribed to through `remoteApi`
  // It is most likely because event listener to onMessage is added during
  // createNonBackgroundMessenger and messenger on the other end emits immediately upon connection.
  const message$ = new ReplaySubject<PortMessage>(1);
  const connect = () => {
    if (typeof port$.value === 'string' || port$.value) return;
    // assuming this doesn't throw
    const port = runtime.connect({ name: channel });
    port$.next(port);
    port.onDisconnect.addListener(onDisconnect);
    // TODO: reset 'delay' if onDisconnect not called somewhat immediatelly?
    port.onMessage.addListener(onMessage);
  };
  const reconnect = () => {
    clearTimeout(reconnectTimeout);
    delay = Math.min(Math.pow(delay, 2), maxDelay);
    reconnectTimeout = setTimeout(connect, delay);
  };
  const onMessage = (data: unknown, port: MessengerPort) => {
    logger.debug(`[NonBackgroundMessenger(${channel})] message`, data);
    delay = initialDelay;
    message$.next({ data, port });
  };
  const onDisconnect = (port: MessengerPort) => {
    disconnect$.next({
      disconnected: port,
      remaining: []
    });
    logger.debug(`[NonBackgroundMessenger(${channel})] disconnected`);
    port!.onMessage.removeListener(onMessage);
    port!.onDisconnect.removeListener(onDisconnect);
    port$.next(isDestroyed ? 'shutdown' : null);
    if (!isDestroyed) reconnect();
  };
  connect();
  const connect$ = port$.pipe(
    debounceTime(10), // TODO: how long until onDisconnect() is called when the other end doesn't exist?
    filter(isNotNil),
    takeWhile((port): port is MessengerPort => typeof port !== 'string')
  );
  const derivedMessengers = new Set<Messenger>();
  return {
    channel,
    connect$,
    deriveChannel(path, { detached }: DeriveChannelOptions = {}) {
      const messenger = createNonBackgroundMessenger(
        {
          baseChannel: deriveChannelName(channel, path),
          reconnectConfig: { initialDelay, maxDelay }
        },
        { logger, runtime }
      );
      if (!detached) {
        derivedMessengers.add(messenger);
      }
      return messenger;
    },
    disconnect$,
    get isShutdown() {
      return isDestroyed;
    },
    message$,
    /**
     * @throws RxJS EmptyError if client is shutdown
     */
    postMessage(message: unknown): Observable<void> {
      return connect$.pipe(
        first(),
        tap((port) => port.postMessage(message)),
        retryBackoff({
          initialInterval: 10,
          maxInterval: 1000,
          shouldRetry: (err) => !(err instanceof EmptyError)
        }),
        map(() => void 0),
        catchError(() => {
          logger.warn("Couldn't postMessage: messenger shutdown");
          return of(void 0);
        })
      );
    },

    shutdown() {
      isDestroyed = true;
      const port = port$.value;
      if (typeof port !== 'string') {
        port?.disconnect();
      }
      clearTimeout(reconnectTimeout);
      for (const messenger of derivedMessengers.values()) {
        messenger.shutdown();
        derivedMessengers.delete(messenger);
      }
      port$.complete();
      disconnect$.complete();
      logger.debug(`[NonBackgroundMessenger(${channel})] shutdown`);
    }
  };
};

export type NonBackgroundMessenger = ReturnType<typeof createNonBackgroundMessenger>;
