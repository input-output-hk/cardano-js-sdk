import { BackgroundMessenger, createBackgroundMessenger, generalizeBackgroundMessenger } from './BackgroundMessenger';
import { ChannelName, ConsumeRemoteApiOptions, ExposeApiProps, MessengerDependencies } from './types';
import { FinalizationRegistryDestructor, isBackgroundProcess } from './util';
import { consumeMessengerRemoteApi, exposeMessengerApi } from './remoteApi';
import { createNonBackgroundMessenger } from './NonBackgroundMessenger';

export * from './BackgroundMessenger';
export * from './NonBackgroundMessenger';
export * from './remoteApi';
export * from './runContentScriptMessageProxy';
export * from './types';
export * from './util';
export * from './injectedRuntime';
export * from './errors';

export type BaseChannel = { baseChannel: ChannelName };

const isInBackgroundProcess = isBackgroundProcess();

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
