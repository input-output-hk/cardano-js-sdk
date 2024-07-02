/* eslint-disable unicorn/prefer-add-event-listener */
// cSpell:ignore njson

import {
  AsyncReturnType,
  Cardano,
  EraSummary,
  NetworkInfoMethods,
  NetworkInfoProvider,
  StakeSummary,
  SupplySummary,
  WSMessage
} from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Observable, ReplaySubject, firstValueFrom } from 'rxjs';

import { NJSON } from 'next-json';
import WebSocket from 'isomorphic-ws';

type WSStatus = 'connecting' | 'connected' | 'idle' | 'stop';

export type WSHandler = (message: WSMessage) => void;

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

  /** The `Observable` form of `NetworkInfoProvider`. */
  networkInfo: {
    [m in NetworkInfoMethods]: Observable<AsyncReturnType<NetworkInfoProvider[m]>>;
  };

  /** WebSocket based `NetworkInfoProvider` implementation. */
  networkInfoProvider: NetworkInfoProvider;

  private heartbeatInterval: number;
  private heartbeatTimeout: NodeJS.Timeout;
  private logger: Logger;
  private status: WSStatus = 'idle';
  private url: URL;
  private ws: WebSocket;

  private networkInfoSubjects = {} as {
    [m in NetworkInfoMethods]: ReplaySubject<AsyncReturnType<NetworkInfoProvider[m]>>;
  };

  constructor(deps: WsClientDependencies, cfg: WsClientConfiguration) {
    this.heartbeatInterval = (cfg.heartbeatInterval || 55) * 1000;
    this.logger = deps.logger;
    this.url = cfg.url;

    this.networkInfoSubjects = {
      eraSummaries: new ReplaySubject<EraSummary[]>(1),
      genesisParameters: new ReplaySubject<Cardano.CompactGenesis>(1),
      ledgerTip: new ReplaySubject<Cardano.Tip>(1),
      lovelaceSupply: new ReplaySubject<SupplySummary>(1),
      protocolParameters: new ReplaySubject<Cardano.ProtocolParameters>(1),
      stake: new ReplaySubject<StakeSummary>(1)
    };
    this.networkInfo = this.networkInfoSubjects;

    this.networkInfoProvider = {
      eraSummaries: () => firstValueFrom(this.networkInfo.eraSummaries),
      genesisParameters: () => firstValueFrom(this.networkInfo.genesisParameters),
      healthCheck: () => Promise.resolve({ ok: this.status === 'connected' }),
      ledgerTip: () => firstValueFrom(this.networkInfo.ledgerTip),
      lovelaceSupply: () => firstValueFrom(this.networkInfo.lovelaceSupply),
      protocolParameters: () => firstValueFrom(this.networkInfo.protocolParameters),
      stake: () => firstValueFrom(this.networkInfo.stake)
    };

    this.connect();
  }

  private connect() {
    this.status = 'connecting';

    const ws = new WebSocket(this.url);

    // eslint-disable-next-line sonarjs/cognitive-complexity
    ws.onmessage = (event) => {
      try {
        if (typeof event.data !== 'string') throw new Error('Unexpected data from WebSocket ');

        const message = NJSON.parse<WSMessage>(event.data);
        const { clientId, networkInfo } = message;

        if (clientId) this.logger.info(`Connected with clientId ${(this.clientId = clientId)}`);

        if (networkInfo) {
          const { eraSummaries, genesisParameters, ledgerTip, lovelaceSupply, protocolParameters, stake } = networkInfo;

          if (eraSummaries) this.networkInfoSubjects.eraSummaries.next(eraSummaries);
          if (genesisParameters) this.networkInfoSubjects.genesisParameters.next(genesisParameters);
          if (lovelaceSupply) this.networkInfoSubjects.lovelaceSupply.next(lovelaceSupply);
          if (protocolParameters) this.networkInfoSubjects.protocolParameters.next(protocolParameters);
          if (stake) this.networkInfoSubjects.stake.next(stake);
          // Emit ledgerTip as last one
          if (ledgerTip) this.networkInfoSubjects.ledgerTip.next(ledgerTip);
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
    if (this.heartbeatTimeout) clearInterval(this.heartbeatTimeout);

    this.status = 'stop';
    this.ws.close();
  }

  /**
   * Sends a request through WS to server.
   *
   * @param request the request.
   * @returns `true` is sent, otherwise `false`.
   */
  request(request: WSMessage) {
    if (this.status !== 'connected') return false;

    this.ws!.send(NJSON.stringify(request));
    this.heartbeat();

    return true;
  }
}
