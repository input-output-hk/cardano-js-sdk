import { BackgroundMessenger, createBackgroundMessenger, generalizeBackgroundMessenger } from './BackgroundMessenger';
import { ChannelName, ConsumeRemotePromiseApiOptions, ExposePromiseApiProps, MessengerDependencies } from './types';
import { consumeMessengerRemotePromiseApi, exposeMessengerPromiseApi } from './remoteApi';
import { createNonBackgroundMessenger } from './NonBackgroundMessenger';

export * from './BackgroundMessenger';
export * from './NonBackgroundMessenger';
export * from './remoteApi';
export * from './runContentScriptMessageProxy';
export * from './types';
export * from './util';
export * from './injectedRuntime';

const isInBackgroundProcess = typeof window === 'undefined';

const getBackgroundMessenger = (() => {
  let backgroundMessenger: BackgroundMessenger | null = null;
  return (dependencies: MessengerDependencies) => (backgroundMessenger ||= createBackgroundMessenger(dependencies));
})();

const _backgroundExposePromiseApi = <T extends object>(
  props: ExposePromiseApiProps<T>,
  dependencies: MessengerDependencies
) => {
  const messenger = generalizeBackgroundMessenger(props.channel, getBackgroundMessenger(dependencies));
  return exposeMessengerPromiseApi(props, {
    messenger,
    ...dependencies
  });
};

export type ExposePromiseApi = typeof _backgroundExposePromiseApi;

const _nonBackgroundExposePromiseApi: ExposePromiseApi = <T extends object>(
  props: ExposePromiseApiProps<T>,
  dependencies: MessengerDependencies
) =>
  exposeMessengerPromiseApi(props, {
    messenger: createNonBackgroundMessenger(props, dependencies),
    ...dependencies
  });

const _nonBackgroundConsumeRemotePromiseApi = <T extends object>(
  props: ConsumeRemotePromiseApiOptions<T> & { channel: ChannelName },
  dependencies: MessengerDependencies
) =>
  consumeMessengerRemotePromiseApi(props, {
    messenger: createNonBackgroundMessenger(props, dependencies),
    ...dependencies
  });

export type ConsumePromiseApi = typeof _nonBackgroundConsumeRemotePromiseApi;

const _backgroundConsumeRemotePromiseApi: ConsumePromiseApi = <T extends object>(
  props: ConsumeRemotePromiseApiOptions<T> & { channel: ChannelName },
  dependencies: MessengerDependencies
) => {
  const messenger = generalizeBackgroundMessenger(props.channel, getBackgroundMessenger(dependencies));
  return consumeMessengerRemotePromiseApi(props, { messenger, ...dependencies });
};

/**
 * Bind promise-based API object to handle messages from other parts of extension.
 * Only compatible with interfaces where all methods return a Promise.
 * This can only used once per channelName per process.
 *
 * In addition to errors thrown by the underlying API, methods can throw TypeError
 */
export const exposePromiseApi: ExposePromiseApi = isInBackgroundProcess
  ? _backgroundExposePromiseApi
  : _nonBackgroundExposePromiseApi;

/**
 * Create a client to remote api, exposed via `exposePromiseApi`.
 * Only compatible with interfaces where all methods return a Promise.
 */
export const consumeRemotePromiseApi: ConsumePromiseApi = isInBackgroundProcess
  ? _backgroundConsumeRemotePromiseApi
  : _nonBackgroundConsumeRemotePromiseApi;
