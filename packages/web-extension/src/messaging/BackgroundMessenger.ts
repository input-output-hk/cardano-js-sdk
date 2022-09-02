// only tested in ../e2e tests
import { BehaviorSubject, ReplaySubject, Subject, bufferCount, filter, first, from, map, mergeMap, tap } from 'rxjs';
import { ChannelName, Messenger, MessengerDependencies, MessengerPort, PortMessage } from './types';
import { Logger } from 'ts-log';
import { deriveChannelName } from './util';

interface Channel {
  message$: Subject<PortMessage>;
  ports$: BehaviorSubject<Set<MessengerPort>>;
  hasMethodRequestHandler?: boolean;
}

/**
 * Intended to be used in service worker background process.
 * Manages connections with different parts of the extension.
 * Connections are managed through ports.
 * All other parts of extension are expected use NonBackgroundMessenger.
 * You won't be able to add any additional 'runtime.onConnect' listeners in background process once this is called.
 */
export const createBackgroundMessenger = ({ logger, runtime }: MessengerDependencies) => {
  const channels = new Map<ChannelName, Channel>();
  const getChannel = (channelName: ChannelName) => {
    let channel = channels.get(channelName);
    if (!channel) {
      // Originally message$ was a 'new Subject()', but there seems to be a race between
      // - when it receives a value from 'onMessage'
      // - when message$ is subscribed to through `remoteApi`
      // It is most likely because event listener to onMessage is added during
      // createBackgroundMessenger and messenger on the other end emits immediately upon connection.
      channels.set(channelName, (channel = { message$: new ReplaySubject(1), ports$: new BehaviorSubject(new Set()) }));
    }
    return channel;
  };
  const onPortMessage = (data: unknown, port: MessengerPort) => {
    logger.debug(`[BackgroundMessenger(${port.name})] message`, data);
    const { message$ } = channels.get(port.name)!;
    message$.next({ data, port });
  };
  const onPortDisconnected = (port: MessengerPort) => {
    port.onMessage.removeListener(onPortMessage);
    port.onDisconnect.removeListener(onPortDisconnected);
    const { ports$ } = channels.get(port.name)!;
    const newPorts = new Set(ports$.value);
    newPorts.delete(port);
    ports$.next(newPorts);
    logger.debug(`[BackgroundMessenger(${port.name})] disconnected`, port);
  };
  const onConnect = (port: MessengerPort) => {
    const { ports$ } = getChannel(port.name);
    const newPorts = new Set(ports$.value);
    newPorts.add(port);
    port.onMessage.addListener(onPortMessage);
    port.onDisconnect.addListener(onPortDisconnected);
    ports$.next(newPorts);
    logger.debug(`[BackgroundMessenger(${port.name})] connected`);
  };
  runtime.onConnect.addListener(onConnect);
  return {
    /**
     * Disconnect all existing ports and stop listening for new ones.
     */
    destroy() {
      // eslint-disable-next-line unicorn/no-useless-spread
      for (const channelName of [...channels.keys()]) {
        this.destroyChannel(channelName);
      }
      runtime.onConnect.removeListener(onConnect);
      logger.warn('[BackgroundMessenger] destroyed');
    },
    destroyChannel(channelName: string) {
      const channel = channels.get(channelName);
      if (!channel) return;
      channel.message$.complete();
      for (const port of channel.ports$.value) {
        port.disconnect();
      }
      channels.delete(channelName);
    },
    getChannel
  };
};

export type BackgroundMessenger = ReturnType<typeof createBackgroundMessenger>;

export interface BackgroundMessengerApiDependencies {
  messenger: BackgroundMessenger;
  logger: Logger;
}

export const generalizeBackgroundMessenger = (channel: ChannelName, messenger: BackgroundMessenger): Messenger => ({
  channel,
  connect$: messenger.getChannel(channel).ports$.pipe(
    bufferCount(2, 1),
    mergeMap(([portsBefore, ports]) => {
      const diff = [...ports].filter((port) => !portsBefore.has(port));
      return from(diff);
    })
  ),
  deriveChannel(path) {
    return generalizeBackgroundMessenger(deriveChannelName(channel, path), messenger);
  },
  destroy() {
    messenger.destroyChannel(channel);
  },
  message$: messenger.getChannel(channel).message$,
  /**
   * @throws RxJS EmptyError if messenger is destroyed
   */
  postMessage: (message) => {
    const { ports$ } = messenger.getChannel(channel);
    return ports$.pipe(
      // wait for at least 1 port to be connected
      // to be able to post messages even before the other end comes alive
      filter((ports) => ports.size > 0),
      first(),
      tap((ports) => {
        for (const port of ports) port.postMessage(message);
      }),
      map(() => void 0)
    );
  }
});
