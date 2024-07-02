import { NetworkInfoProvider } from './Provider';

export type AsyncReturnType<F extends () => unknown> = F extends () => Promise<infer R> ? R : never;

export type NetworkInfoMethods = Exclude<keyof NetworkInfoProvider, 'healthCheck'>;
export type NetworkInfoResponses = { [m in NetworkInfoMethods]: AsyncReturnType<NetworkInfoProvider[m]> };

export interface WSMessage {
  /** The client id assigned by the server. */
  clientId?: string;

  /** The error occurred server side. */
  error?: Error;

  /** Latest value(s) for the `NetworkInfoProvider` methods.*/
  networkInfo?: Partial<NetworkInfoResponses>;
}
