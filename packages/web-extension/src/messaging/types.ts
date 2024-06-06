/* eslint-disable @typescript-eslint/no-explicit-any */
import type { ErrorClass, Shutdown } from '@cardano-sdk/util';
import type { Events, Runtime } from 'webextension-polyfill';
import type { Logger } from 'ts-log';
import type { Observable } from 'rxjs';

export type MethodRequest<Method extends string = string, Args = unknown[]> = { method: Method; args: Args };

export interface AnyMessage extends Object {
  messageId: string;
}

export interface RequestMessage extends AnyMessage {
  request: MethodRequest;
}

export interface ResponseMessage<T = unknown> extends AnyMessage {
  response: T;
}

export interface CompletionMessage extends AnyMessage {
  subscribe: false;
  error?: Error;
}

export interface EmitMessage extends AnyMessage {
  emit: unknown;
}

export type SendMethodRequestMessage = <Response = unknown>(msg: MethodRequest) => Promise<Response>;

/** Corresponds to underlying port name */
export type ChannelName = string;

export interface FactoryCall<Method extends string = string> extends MethodRequest<Method> {
  channel: ChannelName;
}

export interface FactoryCallMessage<Method extends string = string> extends AnyMessage {
  factoryCall: FactoryCall<Method>;
}

export type MinimalEvent<Callback extends (...args: any[]) => any> = Pick<
  Events.Event<Callback>,
  'addListener' | 'removeListener'
>;

export interface MessengerPort {
  name: string;
  sender?: Runtime.MessageSender;
  onDisconnect: MinimalEvent<(port: MessengerPort) => void>;
  onMessage: MinimalEvent<(data: unknown, port: MessengerPort) => void>;
  disconnect(): void;
  /**
   * @throws an Error if the port is closed
   */
  postMessage(message: any): void;
}

export interface MinimalRuntime {
  connect(connectInfo: Runtime.ConnectConnectInfoType): MessengerPort;
  onConnect: MinimalEvent<(port: MessengerPort) => void>;
}

export interface MessengerDependencies {
  runtime: MinimalRuntime;
  logger: Logger;
}

export type TransformRequest = (request: MethodRequest, sender?: Runtime.MessageSender) => MethodRequest;
export type ValidateRequest = (request: MethodRequest, sender?: Runtime.MessageSender) => Promise<void>;

export interface ReconnectConfig {
  initialDelay: number;
  maxDelay: number;
}

export interface BindRequestHandlerOptions<Response> {
  handler: (request: MethodRequest, sender?: Runtime.MessageSender) => Promise<Response>;
}

export type MinimalPort = Pick<MessengerPort, 'sender' | 'postMessage'>;

export interface PortMessage<Data = unknown> {
  data: Data;
  port: MinimalPort;
}

export enum RemoteApiPropertyType {
  /**
   * Methods might throw RemoteApiShutdownError when attempting
   * to call a method on remote api object that was previously shutdown.
   */
  MethodReturningPromise,
  /**
   * Exposing this observable:
   * - subscribes immediately
   * - shares a single underlying subscription for all connections
   * - replays 1 last emitted value upon connection
   */
  HotObservable,
  /** Method that returns a new remote api object (synchronously). Should only be used for methods that cannot throw. */
  ApiFactory
}

export interface MethodRequestOptions {
  transform?: TransformRequest;
  validate?: ValidateRequest;
}

export interface RemoteApiMethod {
  propType: RemoteApiPropertyType.MethodReturningPromise;
  requestOptions: MethodRequestOptions;
}

export interface ApiFactoryOptions {
  baseChannel: ChannelName;
}

export interface RemoteApiFactory<T> {
  propType: RemoteApiPropertyType.ApiFactory;
  // eslint-disable-next-line no-use-before-define
  getApiProperties: () => T extends (...args: any) => any ? RemoteApiProperties<ReturnType<T>> : never;
}

export type RemoteApiProperty<T> =
  | RemoteApiPropertyType.HotObservable
  | RemoteApiPropertyType.MethodReturningPromise
  | RemoteApiMethod
  | RemoteApiFactory<T>;

export type ExposableRemoteApi<T> = Omit<T, 'shutdown'>;

export type RemoteApiProperties<T> = {
  [key in keyof ExposableRemoteApi<T>]:
    | RemoteApiProperty<T[key]>
    | Omit<RemoteApiProperties<T[key]>, 'propType' | 'requestOptions'>;
};

export interface ExposeApiProps<API extends object> {
  api$: Observable<API | null>;
  properties: RemoteApiProperties<API>;
}

export interface ConsumeRemoteApiOptions<T> {
  properties: RemoteApiProperties<T>;
  errorTypes?: ErrorClass[];
}

export interface DeriveChannelOptions {
  /** If true, shutting down base messenger will not shut down the derived messenger */
  detached?: boolean;
}

export interface DisconnectEvent {
  disconnected: MinimalPort;
  remaining: MinimalPort[];
}

export interface Messenger extends Shutdown {
  channel: ChannelName;
  connect$: Observable<MinimalPort>;
  postMessage(message: unknown): Observable<void>;
  message$: Observable<PortMessage>;
  disconnect$: Observable<DisconnectEvent>;
  isShutdown: boolean;
  deriveChannel(path: string, options?: DeriveChannelOptions): Messenger;
}

export interface MessengerApiDependencies {
  messenger: Messenger;
  logger: Logger;
}

export interface Destructor {
  onGarbageCollected(obj: object, objectId: unknown, callback: () => void): void;
}

export interface ConsumeMessengerApiDependencies extends MessengerApiDependencies {
  destructor: Destructor;
}

export type InternalMsgType = 'apiObjDisabled';
export type InternalMsg = { remoteApiInternalMsg: InternalMsgType };
