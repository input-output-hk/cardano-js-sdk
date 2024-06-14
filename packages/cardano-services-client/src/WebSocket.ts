/* eslint-disable unicorn/prefer-add-event-listener */
// cSpell:ignore njson

import { AsyncReturnType, Cardano, NetworkInfoProvider, RequestMethods, WSMessage } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Observable, ReplaySubject, firstValueFrom } from 'rxjs';

import { NJSON } from 'next-json';
import WebSocket from 'isomorphic-ws';

type WSStatus = 'connecting' | 'connected' | 'idle' | 'stop';

export type WSHandler = (message: WSMessage) => void;
type WSPerform = () => boolean;

export interface WsClientConfiguration {
  /** The interval in seconds between two heartbeat messages. Default 55". */
  heartbeatInterval?: number;

  /** The interval in seconds after which a request must timeout. Default 60". */
  requestTimeout?: number;

  /** The WebSocket server URL. */
  url: URL;
}

export interface WsClientDependencies {
  /** The logger. */
  logger: Logger;
}

const isEventError = (error: unknown): error is { error: Error } =>
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  typeof error === 'object' && !!error && (error as any).error instanceof Error;

export class CardanoWsClient {
  /** The client id, assigned by the server. */
  clientId = 'not-connected';

  /** WebSocket based `NetworkInfoProvider` implementation. */
  networkInfo: NetworkInfoProvider;

  /** Emits the tip. */
  tip$: Observable<Cardano.Tip>;

  private handlers = new Map<number, WSHandler>();
  private heartbeatInterval: number;
  private heartbeatTimeout: NodeJS.Timeout;
  private logger: Logger;
  private messageId = 0;
  private pending = new Map<number, WSPerform>();
  private requestId = 0;
  private requestTimeout: number;
  private status: WSStatus = 'idle';
  private tipSubject$ = new ReplaySubject<Cardano.Tip>(1);
  private url: URL;
  private ws: WebSocket;

  constructor(deps: WsClientDependencies, cfg: WsClientConfiguration) {
    this.heartbeatInterval = (cfg.heartbeatInterval || 55) * 1000;
    this.logger = deps.logger;
    this.requestTimeout = (cfg.requestTimeout || 60) * 1000;
    this.url = cfg.url;

    this.networkInfo = {
      eraSummaries: this.createProviderMethod('eraSummaries'),
      genesisParameters: this.createProviderMethod('genesisParameters'),
      healthCheck: () => Promise.resolve({ ok: this.status === 'connected' }),
      ledgerTip: () => firstValueFrom(this.tipSubject$),
      lovelaceSupply: this.createProviderMethod('lovelaceSupply'),
      protocolParameters: this.createProviderMethod('protocolParameters'),
      stake: this.createProviderMethod('stake')
    };
    this.tip$ = this.tipSubject$;

    this.connect();
  }

  private connect() {
    this.status = 'connecting';

    const ws = new WebSocket(this.url);

    ws.onmessage = (event) => {
      try {
        if (typeof event.data !== 'string') throw new Error('Unexpected data from WebSocket ');

        const message = NJSON.parse<WSMessage>(event.data);
        const { clientId, responseTo, tip } = message;

        if (clientId) this.logger.info(`Connected with clientId ${(this.clientId = clientId)}`);
        if (tip) this.tipSubject$.next(tip);

        if (responseTo) {
          const handler = this.handlers.get(responseTo);

          this.handlers.delete(responseTo);
          if (handler) handler(message);
        }
      } catch (error) {
        this.logger.error(error, 'While parsing message', event.data, this.clientId);
      }
    };

    ws.onclose = () => {
      this.logger.info('WebSocket client connection closed', this.clientId);
      this.clientId = 'not-connected';
      this.retry();
    };

    ws.onerror = (error: unknown) => {
      this.logger.error(isEventError(error) ? error.error : error, 'Async error from WebSocket client', this.clientId);
      ws.close();
    };

    ws.onopen = () => {
      this.status = 'connected';
      this.ws = ws;
      this.heartbeat();

      for (const request of this.pending.values()) request();
    };
  }

  private createProviderMethod<M extends RequestMethods>(method: M) {
    // eslint-disable-next-line sonarjs/cognitive-complexity
    return (...args: Parameters<NetworkInfoProvider[M]>) => {
      this.logger.debug(`Requesting ${method}: ${NJSON.stringify(args)}`);

      return new Promise<AsyncReturnType<NetworkInfoProvider[M]>>((resolve, reject) => {
        const requestId = ++this.requestId;

        let timedOut = false;
        const timeout = setTimeout(() => {
          timedOut = true;
          this.pending.delete(requestId);
          reject(new Error('Request timeout'));
        }, this.requestTimeout);

        timeout.unref();

        const perform = () =>
          this.request({ request: { [method]: args } }, (message) => {
            if (timedOut) return;
            clearTimeout(timeout);
            this.pending.delete(requestId);

            this.logger.debug(`Responding to ${method}: ${NJSON.stringify(message)}`);

            const { error, response } = message;

            if (error) return reject(error);
            if (!response) return reject(new Error('Missing "response" attribute from WebSocket response'));

            const methodResponse = response[method];

            if (!methodResponse)
              return reject(new Error(`Missing "response.${method}" attribute from WebSocket response`));

            resolve(methodResponse);
          });

        this.pending.set(requestId, perform);
        perform();
      });
    };
  }

  private heartbeat() {
    if (this.heartbeatTimeout) clearInterval(this.heartbeatTimeout);

    this.heartbeatTimeout = setTimeout(() => this.request({}), this.heartbeatInterval);
    this.heartbeatTimeout.unref();
  }

  private retry() {
    if (this.status !== 'stop') {
      this.status = 'idle';
      setTimeout(() => this.connect(), 1000).unref();
    }
  }

  /** Closes the WebSocket connection. */
  close() {
    this.status = 'stop';
    this.ws.close();
  }

  /**
   * Sends a request through WS to server.
   *
   * @param request the request.
   * @param handler the response handles.
   * @returns `true` is sent, otherwise `false`.
   */
  request(request: WSMessage, handler?: WSHandler) {
    if (this.status !== 'connected') return false;

    const messageId = ++this.messageId;

    this.ws!.send(NJSON.stringify({ ...request, messageId }));
    this.heartbeat();

    if (handler) this.handlers.set(messageId, handler);

    return true;
  }
}
