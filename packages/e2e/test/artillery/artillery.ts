import type { Agent, IncomingMessage } from 'http';
import type { Agent as HttpsAgent } from 'https';

/** Artillery context */
export interface ArtilleryContext<T> {
  /** The unique Id of the virtual user */
  _uid: string;

  /** The variables of the virtual user session */
  vars: T;
}

interface ArtilleryEvents {
  counter: (name: string, value: number) => void;
  histogram: (name: string, value: number) => void;
  rate: (name: string) => void;
}

interface ArtilleryEventEmitter extends EventEmitter {
  addListener<Event extends keyof ArtilleryEvents>(event: Event, listener: ArtilleryEvents[Event]): this;
  emit<Event extends keyof ArtilleryEvents>(event: Event, ...args: Parameters<ArtilleryEvents[Event]>): boolean;
  on<Event extends keyof ArtilleryEvents>(event: Event, listener: ArtilleryEvents[Event]): this;
  once<Event extends keyof ArtilleryEvents>(event: Event, listener: ArtilleryEvents[Event]): this;
  prependListener<Event extends keyof ArtilleryEvents>(event: Event, listener: ArtilleryEvents[Event]): this;
  prependOnceListener<Event extends keyof ArtilleryEvents>(event: Event, listener: ArtilleryEvents[Event]): this;
  removeListener<Event extends keyof ArtilleryEvents>(event: Event, listener: ArtilleryEvents[Event]): this;
}

/** Parameters of an Artillery request */
export interface Params {
  /** Name of the afterResponse hook */
  afterResponse?: string;

  /** The agent used to for the request */
  agent?: { http: Agent; https: HttpsAgent };

  /** Name of the beforeRequest hook */
  beforeRequest?: string;

  /** The variables to capture from the response */
  capture: { as: string; json: string }[];

  /** Unknown */
  decompress?: boolean;

  /** Not yet tested in IOG */
  followRedirect?: boolean;

  /** Not yet tested in IOG */
  followAllRedirects?: boolean;

  /** The HTTP headers of the request */
  headers?: Record<string, string>;

  /** Unknown */
  https?: unknown;

  /** The json body for POST. Its value is the raw configured one in beforeRequest and the evaluated one in afterResponse */
  json?: unknown;

  /** Unknown */
  match?: unknown[];

  /** The HTTP method of the request */
  method: 'DELETE' | 'GET' | 'POST' | 'PUT';

  /** Unknown */
  retry: number;

  /** Unknown */
  throwHttpErrors?: boolean;

  /** The time out of the request in ms */
  timeout: number;

  /** URL of the request */
  url: string;
}

export type AfterResponseHook<T> = (
  params: Params,
  response: IncomingMessage,
  ctx: ArtilleryContext<T>,
  ee: ArtilleryEventEmitter,
  done: () => void
) => void;

export type BeforeRequestHook<T> = (
  params: Params,
  ctx: ArtilleryContext<T>,
  ee: ArtilleryEventEmitter,
  done: () => void
) => void;

export type FunctionHook<T> = (ctx: ArtilleryContext<T>, ee: ArtilleryEventEmitter, done: () => void) => void;

export type WhileTrueHook<T> = (ctx: ArtilleryContext<T>, done: (result: boolean) => void) => void;
