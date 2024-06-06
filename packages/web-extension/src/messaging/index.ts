import { FinalizationRegistryDestructor } from './util.js';
import { consumeMessengerRemoteApi, exposeMessengerApi } from './remoteApi.js';
import { createBackgroundMessenger, generalizeBackgroundMessenger } from './BackgroundMessenger.js';
import { createNonBackgroundMessenger } from './NonBackgroundMessenger.js';
import type { BackgroundMessenger } from './BackgroundMessenger.js';
import type { ChannelName, ConsumeRemoteApiOptions, ExposeApiProps, MessengerDependencies } from './types.js';

export * from './BackgroundMessenger.js';
export * from './NonBackgroundMessenger.js';
export * from './remoteApi.js';
export * from './runContentScriptMessageProxy.js';
export * from './types.js';
export * from './util.js';
export * from './injectedRuntime.js';
export * from './errors.js';

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
  const messenger = generalizeBackgroundMessenger(
    props.baseChannel,
    getBackgroundMessenger(dependencies),
    dependencies.logger
  );
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
    destructor: new FinalizationRegistryDestructor(dependencies.logger),
    messenger: createNonBackgroundMessenger(props, dependencies),
    ...dependencies
  });

export type ConsumeApi = typeof _nonBackgroundConsumeRemoteApi;

const _backgroundConsumeRemoteApi: ConsumeApi = <T extends object>(
  props: ConsumeRemoteApiOptions<T> & BaseChannel,
  dependencies: MessengerDependencies
) => {
  const messenger = generalizeBackgroundMessenger(
    props.baseChannel,
    getBackgroundMessenger(dependencies),
    dependencies.logger
  );
  return consumeMessengerRemoteApi(props, {
    destructor: new FinalizationRegistryDestructor(dependencies.logger),
    messenger,
    ...dependencies
  });
};

/**
 * Bind an API object to handle messages from other parts of extension.
 * Only compatible with interfaces where all members are either:
 * - Methods that return a Promise
 * - Observable
 *
 * This can only used once per channelName per process.
 */
export const exposeApi: ExposeApi = isInBackgroundProcess ? _backgroundExposeApi : _nonBackgroundExposeApi;

/**
 * Create a client to remote api, exposed via `exposeApi`.
 * Only compatible with interfaces where all members are either:
 * - Methods that return a Promise
 * - Observable
 */
export const consumeRemoteApi: ConsumeApi = isInBackgroundProcess
  ? _backgroundConsumeRemoteApi
  : _nonBackgroundConsumeRemoteApi;
