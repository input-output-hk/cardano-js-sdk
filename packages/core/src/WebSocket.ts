import * as Cardano from './Cardano';
import { NetworkInfoProvider } from './Provider';

export type AsyncReturnType<F extends () => unknown> = F extends () => Promise<infer R> ? R : never;

export type RequestMethods = Exclude<keyof NetworkInfoProvider, 'healthCheck' | 'ledgerTip'>;

export interface WSMessage {
  /** The client id assigned by the server. */
  clientId?: string;

  error?: Error;

  /** If present, this message is in response to request with the same `messageId`. */
  responseTo?: number;

  /** Progressive message id from the client. */
  messageId?: number;

  request?: { [k in RequestMethods]?: Parameters<NetworkInfoProvider[k]> };

  response?: { [k in RequestMethods]?: AsyncReturnType<NetworkInfoProvider[k]> };

  /** Latest known tip. */
  tip?: Cardano.Tip;
}

export type WSRequest = Exclude<WSMessage['request'], undefined>;
