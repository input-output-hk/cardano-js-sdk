// only tested in ../e2e tests
/* eslint-disable no-use-before-define */
import { BehaviorSubject, Observable, ReplaySubject, debounceTime, filter, first, map, takeWhile, tap } from 'rxjs';
import { Messenger, MessengerDependencies, MessengerPort, PortMessage, ReconnectConfig } from './types';
import { deriveChannelName } from './util';
import { isNotNil } from '@cardano-sdk/util';

export interface NonBackgroundMessengerOptions {
  baseChannel: string;
  reconnectConfig?: ReconnectConfig;
}

/**
 * Creates and maintains a long-running connection to background process.
 * Attempts to reconnect the port on disconnects.
 */
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
  const port$ = new BehaviorSubject<MessengerPort | null | 'destroyed'>(null);
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
    logger.debug(`[NonBackgroundMessenger(${channel})] disconnected`);
    port!.onMessage.removeListener(onMessage);
    port!.onDisconnect.removeListener(onDisconnect);
    port$.next(isDestroyed ? 'destroyed' : null);
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
    deriveChannel(path) {
      const messenger = createNonBackgroundMessenger(
        {
          baseChannel: deriveChannelName(channel, path),
          reconnectConfig: { initialDelay, maxDelay }
        },
        { logger, runtime }
      );
      derivedMessengers.add(messenger);
      return messenger;
    },
    destroy() {
      isDestroyed = true;
      const port = port$.value;
      if (typeof port !== 'string') {
        port?.disconnect();
      }
      clearTimeout(reconnectTimeout);
      for (const messenger of derivedMessengers.values()) {
        messenger.destroy();
        derivedMessengers.delete(messenger);
      }
      port$.complete();
      logger.warn(`[NonBackgroundMessenger(${channel})] destroyed`);
    },
    message$,
    /**
     * @throws RxJS EmptyError if client is destroyed
     */
    postMessage(message: unknown): Observable<void> {
      return connect$.pipe(
        first(),
        // TODO: find if this can throw
        tap((port) => port.postMessage(message)),
        map(() => void 0)
      );
    }
  };
};

export type NonBackgroundMessenger = ReturnType<typeof createNonBackgroundMessenger>;
