/* eslint-disable @typescript-eslint/no-explicit-any */
import { v4 as uuidv4 } from 'uuid';
import type {
  AnyMessage,
  ChannelName,
  CompletionMessage,
  Destructor,
  EmitMessage,
  FactoryCall,
  FactoryCallMessage,
  InternalMsg,
  MethodRequest,
  RequestMessage,
  ResponseMessage
} from './types.js';
import type { Logger } from 'ts-log';

const isRequestLike = (message: any): message is MethodRequest & Partial<Record<string, unknown>> =>
  typeof message === 'object' && message !== null && Array.isArray(message.args) && typeof message.method === 'string';

export const isRequest = (message: any): message is MethodRequest =>
  isRequestLike(message) && typeof message.channel === 'undefined';

export const isFactoryCall = (message: any): message is FactoryCall =>
  isRequestLike(message) && typeof message.channel === 'string';

const looksLikeMessage = (message: any): message is AnyMessage & Record<string, unknown> =>
  typeof message === 'object' && message !== null && typeof message.messageId === 'string';

export const isRequestMessage = (message: any): message is RequestMessage =>
  looksLikeMessage(message) && isRequest(message.request);

export const isFactoryCallMessage = (message: any): message is FactoryCallMessage =>
  looksLikeMessage(message) && isFactoryCall(message.factoryCall);

export const isResponseMessage = (message: any): message is ResponseMessage =>
  looksLikeMessage(message) && message.hasOwnProperty('response');

export const isCompletionMessage = (message: any): message is CompletionMessage =>
  looksLikeMessage(message) && typeof message.subscribe === 'boolean';

export const isEmitMessage = (message: any): message is EmitMessage =>
  looksLikeMessage(message) && message.hasOwnProperty('emit');

export const newMessageId = uuidv4;

export const deriveChannelName = (channel: ChannelName, path: string): ChannelName => `${channel}-${path}`;

const isInternalMsg = (msg: unknown): msg is InternalMsg => (msg as InternalMsg)?.remoteApiInternalMsg !== undefined;
export const disabledApiMsg: InternalMsg = {
  remoteApiInternalMsg: 'apiObjDisabled'
};
export const isNotDisabledApiMsg = (msg: unknown) =>
  !isInternalMsg(msg) || msg.remoteApiInternalMsg !== disabledApiMsg.remoteApiInternalMsg;

export class FinalizationRegistryDestructor implements Destructor {
  readonly #registry: FinalizationRegistry<unknown>;
  readonly #logger: Logger;
  readonly callbacks: Map<unknown, () => void> = new Map();

  constructor(logger: Logger) {
    this.#registry = new FinalizationRegistry((heldValue) => this.#callback(heldValue));
    this.#logger = logger;
  }

  #callback(heldValue: unknown) {
    const callback = this.callbacks.get(heldValue);
    if (!callback) {
      return this.#logger.error('heldValue not found in FinalizationRegistryDestructor');
    }
    this.callbacks.delete(heldValue);
    callback();
  }

  onGarbageCollected(obj: object, objectId: unknown, callback: () => void) {
    this.callbacks.set(objectId, callback);
    this.#registry.register(obj, objectId);
  }
}
