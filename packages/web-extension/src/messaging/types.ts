/* eslint-disable @typescript-eslint/no-explicit-any */
import { Events, Runtime } from 'webextension-polyfill';
import { GetErrorPrototype } from '@cardano-sdk/util';
import { Logger } from 'ts-log';
import { Observable } from 'rxjs';

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

export interface ObservableCompletionMessage extends AnyMessage {
  subscribe: false;
  error?: Error;
}

export interface EmitMessage extends AnyMessage {
  emit: unknown;
}

export type SendMethodRequestMessage = <Response = unknown>(msg: MethodRequest) => Promise<Response>;

/**
 * Corresponds to underlying port name
 */
export type ChannelName = string;

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
  MethodReturningPromise,
  // eslint-disable-next-line @typescript-eslint/no-shadow
  Observable
}

export interface MethodRequestOptions {
  transform?: TransformRequest;
  validate?: ValidateRequest;
}

export interface RemoteApiMethod {
  propType: RemoteApiPropertyType.MethodReturningPromise;
  requestOptions: MethodRequestOptions;
}

export type RemoteApiProperty = RemoteApiPropertyType | RemoteApiMethod;

export type RemoteApiProperties<T> = {
  [key in keyof T]: RemoteApiProperty | Omit<RemoteApiProperties<T[key]>, 'propType' | 'requestOptions'>;
};

export interface ExposeApiProps<API extends object> {
  api: API;
  properties: RemoteApiProperties<API>;
}

export interface ConsumeRemoteApiOptions<T> {
  properties: RemoteApiProperties<T>;
  getErrorPrototype?: GetErrorPrototype;
}

export interface Messenger {
  channel: ChannelName;
  connect$: Observable<MinimalPort>;
  postMessage(message: unknown): Observable<void>;
  message$: Observable<PortMessage>;
  deriveChannel(path: string): Messenger;
  destroy(): void;
}

export interface MessengerApiDependencies {
  messenger: Messenger;
  logger: Logger;
}
