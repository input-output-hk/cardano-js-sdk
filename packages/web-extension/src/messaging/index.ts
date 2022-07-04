import '@cardano-sdk/util';
import { BackgroundMessenger, createBackgroundMessenger, generalizeBackgroundMessenger } from './BackgroundMessenger';
import { ChannelName, ConsumeRemoteApiOptions, ExposeApiProps, MessengerDependencies } from './types';
import { consumeMessengerRemoteApi, exposeMessengerApi } from './remoteApi';
import { createNonBackgroundMessenger } from './NonBackgroundMessenger';

export * from './BackgroundMessenger';
export * from './NonBackgroundMessenger';
export * from './remoteApi';
export * from './runContentScriptMessageProxy';
export * from './types';
export * from './util';
export * from './injectedRuntime';

export type BaseChannel = { baseChannel: ChannelName };

const isInBackgroundProcess = typeof window === 'undefined';

const getBackgroundMessenger = (() => {
  let backgroundMessenger: BackgroundMessenger | null = null;
  return (dependencies: MessengerDependencies) => (backgroundMessenger ||= createBackgroundMessenger(dependencies));
})();

const _backgroundExposeApi = <T extends object>(
  props: ExposeApiProps<T> & BaseChannel,
  dependencies: MessengerDependencies
) => {
  const messenger = generalizeBackgroundMessenger(props.baseChannel, getBackgroundMessenger(dependencies));
  return exposeMessengerApi(props, {
    messenger,
    ...dependencies
  });
};

export type ExposeApi = typeof _backgroundExposeApi;

const _nonBackgroundExposeApi: ExposeApi = <T extends object>(
  props: ExposeApiProps<T> & BaseChannel,
  dependencies: MessengerDependencies
) =>
  exposeMessengerApi(props, {
    messenger: createNonBackgroundMessenger(props, dependencies),
    ...dependencies
  });

const _nonBackgroundConsumeRemoteApi = <T extends object>(
  props: ConsumeRemoteApiOptions<T> & BaseChannel,
  dependencies: MessengerDependencies
) =>
  consumeMessengerRemoteApi(props, {
    messenger: createNonBackgroundMessenger(props, dependencies),
    ...dependencies
  });

export type ConsumeApi = typeof _nonBackgroundConsumeRemoteApi;

const _backgroundConsumeRemoteApi: ConsumeApi = <T extends object>(
  props: ConsumeRemoteApiOptions<T> & BaseChannel,
  dependencies: MessengerDependencies
) => {
  const messenger = generalizeBackgroundMessenger(props.baseChannel, getBackgroundMessenger(dependencies));
  return consumeMessengerRemoteApi(props, { messenger, ...dependencies });
};

/**
 * Bind an API object to handle messages from other parts of extension.
 * Only compatible with interfaces where all methods return a Promise.
 * This can only used once per channelName per process.
 */
export const exposeApi: ExposeApi = isInBackgroundProcess ? _backgroundExposeApi : _nonBackgroundExposeApi;

/**
 * Create a client to remote api, exposed via `exposeApi`.
 * Only compatible with interfaces where all methods return a Promise.
 */
export const consumeRemoteApi: ConsumeApi = isInBackgroundProcess
  ? _backgroundConsumeRemoteApi
  : _nonBackgroundConsumeRemoteApi;
