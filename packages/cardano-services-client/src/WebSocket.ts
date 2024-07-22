/* eslint-disable max-depth */
/* eslint-disable unicorn/prefer-add-event-listener */

import {
  AsyncReturnType,
  Cardano,
  ChainHistoryProvider,
  EpochInfo,
  EraSummary,
  NetworkInfoMethods,
  NetworkInfoProvider,
  Paginated,
  ProviderError,
  ProviderFailure,
  StakeSummary,
  SupplySummary,
  TransactionsByAddressesArgs,
  WSMessage,
  WsProvider,
  createSlotEpochInfoCalc
} from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Observable, ReplaySubject, Subject, filter, firstValueFrom, merge } from 'rxjs';
import { fromSerializableObject } from '@cardano-sdk/util';
import WebSocket from 'isomorphic-ws';

const NOT_CONNECTED_ID = 'not-connected';

type WSStatus = 'connecting' | 'connected' | 'idle' | 'stop';

type WSHandler = (message: WSMessage) => void;

export interface WsClientConfiguration {
  /** The interval in seconds between two heartbeat messages. Default 55". */
  heartbeatInterval?: number;

  /** The interval in seconds after which a request must timeout. Default 60". */
  requestTimeout?: number;

  /** The WebSocket server URL. */
  url: URL;
}

export interface WsClientDependencies {
  /** The `httpChainHistoryProvider`. */
  chainHistoryProvider: ChainHistoryProvider;

  /** The logger. */
  logger: Logger;
}

interface EpochRollover {
  epochInfo: EpochInfo;
  eraSummaries: EraSummary[];
  ledgerTip: Cardano.Tip;
  lovelaceSupply: SupplySummary;
  protocolParameters: Cardano.ProtocolParameters;
}

const isEventError = (error: unknown): error is { error: Error } =>
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  typeof error === 'object' && !!error && (error as any).error instanceof Error;

export class CardanoWsClient extends WsProvider {
  /** The client id, assigned by the server. */
  clientId = NOT_CONNECTED_ID;

  /** Emits on epoch rollover. */
  epoch$: Observable<EpochRollover>;

  /** The `Observable` form of `NetworkInfoProvider`. */
  networkInfo: {
    [m in `${NetworkInfoMethods}$`]: Observable<
      AsyncReturnType<NetworkInfoProvider[m extends `${infer o}$` ? o : never]>
    >;
  };

  /** WebSocket based `ChainHistoryProvider` implementation. */
  chainHistoryProvider: ChainHistoryProvider;

  /** WebSocket based `NetworkInfoProvider` implementation. */
  networkInfoProvider: NetworkInfoProvider;

  private addresses: { [key: string]: { handlers: (() => void)[]; state: 'synced' | 'syncing' } } = {};
  private closePromise: Promise<void>;
  private closeResolver: () => void;
  private epochSubject$: Subject<EpochRollover>;
  private handlers = new Map<number, WSHandler>();
  private heartbeatInterval: number;
  private heartbeatTimeout: NodeJS.Timeout | undefined;
  private logger: Logger;
  private requestId = 0;
  private status: WSStatus = 'idle';
  private transactions: { [key: Cardano.TransactionId]: Cardano.HydratedTx } = {};
  private url: URL;
  private ws: WebSocket;

  private networkInfoSubjects = {} as {
    [m in `${NetworkInfoMethods}$`]: ReplaySubject<
      AsyncReturnType<NetworkInfoProvider[m extends `${infer o}$` ? o : never]>
    >;
  };

  constructor(deps: WsClientDependencies, cfg: WsClientConfiguration) {
    super();

    this.epoch$ = this.epochSubject$ = new Subject<EpochRollover>();
    this.heartbeatInterval = (cfg.heartbeatInterval || 55) * 1000;
    this.logger = deps.logger;
    this.url = cfg.url;

    this.closePromise = new Promise((resolve) => {
      this.closeResolver = resolve;
    });

    this.networkInfoSubjects = {
      eraSummaries$: new ReplaySubject<EraSummary[]>(1),
      genesisParameters$: new ReplaySubject<Cardano.CompactGenesis>(1),
      ledgerTip$: new ReplaySubject<Cardano.Tip>(1),
      lovelaceSupply$: new ReplaySubject<SupplySummary>(1),
      protocolParameters$: new ReplaySubject<Cardano.ProtocolParameters>(1),
      stake$: new ReplaySubject<StakeSummary>(1)
    };
    this.networkInfo = this.networkInfoSubjects;

    this.chainHistoryProvider = {
      blocksByHashes: (args) => deps.chainHistoryProvider.blocksByHashes(args),
      healthCheck: () => this.healthCheck(),
      transactionsByAddresses: (args) => this.transactionsByAddresses(args),
      transactionsByHashes: (args) => deps.chainHistoryProvider.transactionsByHashes(args)
    };

    this.networkInfoProvider = {
      eraSummaries: this.createNetworkInfoProviderMethod('eraSummaries'),
      genesisParameters: this.createNetworkInfoProviderMethod('genesisParameters'),
      healthCheck: () => this.healthCheck(),
      ledgerTip: this.createNetworkInfoProviderMethod('ledgerTip'),
      lovelaceSupply: this.createNetworkInfoProviderMethod('lovelaceSupply'),
      protocolParameters: this.createNetworkInfoProviderMethod('protocolParameters'),
      stake: this.createNetworkInfoProviderMethod('stake')
    };

    this.connect();
  }

  private createNetworkInfoProviderMethod<M extends NetworkInfoMethods>(method: M) {
    return async (): Promise<AsyncReturnType<NetworkInfoProvider[M]>> => {
      // Take the first value from the method's observable or the first not ok health check not due to the provider is still starting
      const value = await firstValueFrom(
        merge(
          this.health$.pipe(filter(({ ok, reason }) => !ok && reason !== 'starting')),
          this.networkInfo[`${method}$`]
        )
      );

      // If the value was an error different from starting, throw it, otherwise it is a return value for the method
      if ('ok' in value && 'reason' in value && value.ok === false)
        throw new ProviderError(ProviderFailure.ConnectionFailure, undefined, value.reason);
      else return value as AsyncReturnType<NetworkInfoProvider[M]>;
    };
  }

  // eslint-disable-next-line sonarjs/cognitive-complexity
  private connect() {
    if (this.status !== 'stop') this.status = 'connecting';

    const ws = (this.ws = new WebSocket(this.url));

    // eslint-disable-next-line sonarjs/cognitive-complexity, complexity
    ws.onmessage = (event) => {
      try {
        if (typeof event.data !== 'string') throw new Error('Unexpected data from WebSocket ');

        const message = fromSerializableObject<WSMessage>(JSON.parse(event.data));
        const { clientId, networkInfo, responseTo, transactions } = message;

        if (clientId) this.logger.info(`Connected with clientId ${(this.clientId = clientId)}`);

        if (networkInfo) {
          const { eraSummaries, genesisParameters, ledgerTip, lovelaceSupply, protocolParameters, stake } = networkInfo;

          if (eraSummaries) this.networkInfoSubjects.eraSummaries$.next(eraSummaries);
          if (genesisParameters) this.networkInfoSubjects.genesisParameters$.next(genesisParameters);
          if (lovelaceSupply) this.networkInfoSubjects.lovelaceSupply$.next(lovelaceSupply);
          if (protocolParameters) this.networkInfoSubjects.protocolParameters$.next(protocolParameters);
          if (stake) this.networkInfoSubjects.stake$.next(stake);

          // Emit ledgerTip as last one
          if (ledgerTip) {
            this.networkInfoSubjects.ledgerTip$.next(ledgerTip);

            // If there was a rollback, remove all transactions from the old chain
            for (const id in this.transactions)
              if (this.transactions[id as Cardano.TransactionId].blockHeader.blockNo >= ledgerTip.blockNo)
                delete this.transactions[id as Cardano.TransactionId];
          }

          // If it is an epoch rollover, emit it
          if (eraSummaries && ledgerTip && lovelaceSupply && protocolParameters && !clientId) {
            const epochInfo = createSlotEpochInfoCalc(eraSummaries)(ledgerTip.slot);

            this.epochSubject$.next({ epochInfo, eraSummaries, ledgerTip, lovelaceSupply, protocolParameters });
          }
        }

        if (transactions) {
          const newTransactions = transactions.filter(({ id }) => !(id in this.transactions));

          for (const transaction of newTransactions) this.transactions[transaction.id] = transaction;
        }

        if (responseTo) {
          const handler = this.handlers.get(responseTo);

          if (handler) {
            this.handlers.delete(responseTo);
            handler(message);
          }
        }
      } catch (error) {
        this.logger.error(error, 'While parsing message', event.data, this.clientId);
      }
    };

    ws.onclose = () => {
      this.logger.info('WebSocket client connection closed', this.clientId);

      if (this.heartbeatTimeout) {
        clearInterval(this.heartbeatTimeout);
        this.heartbeatTimeout = undefined;
      }

      this.clientId = NOT_CONNECTED_ID;

      if (this.status === 'stop') this.closeResolver();
      else {
        this.status = 'idle';
        setTimeout(() => this.connect(), 1000).unref();
      }

      this.emitHealth('closed');
    };

    ws.onerror = (error: unknown) => {
      const err =
        error instanceof Error
          ? error
          : isEventError(error)
          ? error.error
          : new Error(`Unknown error: ${JSON.stringify(error)}`);

      this.logger.error(err, 'Async error from WebSocket client', this.clientId);
      ws.close();
      this.emitHealth(err.message, true);
    };

    ws.onopen = () => {
      if (this.status !== 'stop') this.status = 'connected';
      this.heartbeat();
      this.emitHealth();
    };
  }

  private heartbeat() {
    if (this.heartbeatTimeout) clearInterval(this.heartbeatTimeout);

    (this.heartbeatTimeout = setTimeout(() => {
      try {
        this.request({});
      } catch (error) {
        this.logger.error(error, 'Error while refreshing heartbeat', this.clientId);
      }
    }, this.heartbeatInterval)).unref();
  }

  /** Closes the WebSocket connection. */
  close() {
    this.status = 'stop';
    this.ws.close();

    return this.closePromise;
  }

  /**
   * Sends a request through WS to server.
   *
   * @param request the request.
   * @returns `true` is sent, otherwise `false`.
   */
  private request(request: WSMessage, handler?: WSHandler) {
    if (this.status !== 'connected') return false;

    // Heartbeat messages do not expect a response, so they neither need a requestId, ...
    if (Object.keys(request).length > 0)
      // ... otherwise add requestId
      request = { ...request, requestId: ++this.requestId };

    this.ws.send(JSON.stringify(request));
    this.heartbeat();

    if (request.requestId && handler) this.handlers.set(request.requestId, handler);

    return true;
  }

  private transactionsByAddresses({ addresses, blockRange, pagination }: TransactionsByAddressesArgs) {
    // eslint-disable-next-line sonarjs/cognitive-complexity
    return new Promise<Paginated<Cardano.HydratedTx>>((resolve, reject) => {
      // The function to be executed once all requested addresses are synced
      const done = () => {
        const lower = blockRange?.lowerBound || 0;
        const upper = blockRange?.upperBound || Number.POSITIVE_INFINITY;

        const transactions = Object.values(this.transactions)
          .filter(({ blockHeader: { blockNo } }) => lower <= blockNo && blockNo <= upper)
          .filter(
            ({ body: { inputs, outputs } }) =>
              inputs.some((input) => addresses.includes(input.address)) ||
              outputs.some((output) => addresses.includes(output.address))
          )
          .sort((a, b) => a.blockHeader.blockNo - b.blockHeader.blockNo);

        const first = pagination?.startAt || 0;
        const last = first + (pagination?.limit || Number.POSITIVE_INFINITY);

        const pageResults = transactions.filter((_, i) => first <= i && i < last);

        resolve({ pageResults, totalResultCount: transactions.length });
      };

      const request: WSMessage = { addresses: [] };
      let boundAddress: Cardano.PaymentAddress | undefined;

      const pushHandler = (address: Cardano.PaymentAddress) => {
        if (!boundAddress) {
          boundAddress = address;
          this.addresses[address].handlers.push(done);
        }
      };

      // Check which addresses require sync
      for (const address of addresses) {
        if (address in this.addresses) {
          if (this.addresses[address].state === 'syncing') pushHandler(address);
        } else {
          request.addresses!.push(address);
          this.addresses[address] = { handlers: [], state: 'syncing' };
          pushHandler(address);
        }
      }

      // If no addresses need to be synced, just run done
      if (!boundAddress) return done();

      // If some addresses need to be requested, perform the request
      if (request.addresses!.length > 0)
        this.request(request, () => {
          for (const address of request.addresses!) {
            const addressState = this.addresses[address];

            if (!addressState) return reject(new Error(`Got response for address ${address} but no state found`));

            addressState.state = 'synced';

            // Run all the done functions associated to that address
            for (const handler of addressState.handlers) handler();
          }
        });
    });
  }
}
