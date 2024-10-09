// cSpell:ignore cardano sonarjs utxos
/* eslint-disable max-depth */
/* eslint-disable unicorn/prefer-add-event-listener */

import {
  Cardano,
  ChainHistoryProvider,
  EpochInfo,
  EraSummary,
  HealthCheckResponse,
  NetworkInfoProvider,
  Paginated,
  Provider,
  ProviderError,
  ProviderFailure,
  Serialization,
  StakeSummary,
  SupplySummary,
  TransactionsByAddressesArgs,
  UtxoByAddressesArgs,
  UtxoProvider,
  createSlotEpochInfoCalc
} from '@cardano-sdk/core';
import { HexBlob, fromSerializableObject } from '@cardano-sdk/util';
import { Logger } from 'ts-log';
import { Observable, ReplaySubject, Subject, filter, firstValueFrom, merge } from 'rxjs';
import WebSocket from 'isomorphic-ws';

const NOT_CONNECTED_ID = 'not-connected';

export type AsyncReturnType<F extends () => unknown> = F extends () => Promise<infer R> ? R : never;

export type MetadataDbModel = [string, HexBlob];

export type NetworkInfoMethods = Exclude<keyof NetworkInfoProvider, 'healthCheck'>;
export type NetworkInfoResponses = { [m in NetworkInfoMethods]: AsyncReturnType<NetworkInfoProvider[m]> };

export interface WSMessage {
  /** The addresses the client subscribes. */
  txsByAddresses?: { addresses: Cardano.PaymentAddress[]; lower: Cardano.BlockNo };

  /** The client id assigned by the server. */
  clientId?: string;

  /** The error on server while performing a request. */
  error?: Error;

  /** Latest value(s) for the `NetworkInfoProvider` methods.*/
  networkInfo?: Partial<NetworkInfoResponses>;

  /** The request id from client to server. */
  requestId?: number;

  /** This message is the response to the message with this id. */
  responseTo?: number;

  /** The server is still syncing. */
  syncing?: boolean;

  /** The transactions. */
  transactions?: Cardano.HydratedTx[];

  // When ChainHistoryProvider.transactionsByAddresses is called with blockRange.lowerBound set (i.e. wallet re-open),
  // this middleware doesn't know the full transaction history. To serve the UtxoProvider.utxoByAddresses it needs the
  // UTXOs from transactions before blockRange.lowerBound. Those partial transactions (transaction with only the UTXOs
  // without any other transaction detail) are loaded through this property.
  /** The partial transactions for UTXOs. */
  utxos?: Cardano.HydratedTx[];
}

type Txs = { [key: Cardano.TransactionId]: Cardano.HydratedTx };

type TxsByAddresses = Exclude<WSMessage['txsByAddresses'], undefined>;

type WSStatus = 'connecting' | 'connected' | 'idle' | 'stop';

type WSHandler = (error?: Error, message?: WSMessage) => void;

interface DeferredRequests {
  timeout?: NodeJS.Timeout;
  requests: { complete: (error?: Error) => void; txsByAddresses: TxsByAddresses }[];
}

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

interface AddressStatus {
  lower: Cardano.BlockNo;
  status: 'synced' | 'syncing';
}

interface EpochRollover {
  epochInfo: EpochInfo;
  eraSummaries: EraSummary[];
  ledgerTip: Cardano.Tip;
  lovelaceSupply: SupplySummary;
  protocolParameters: Cardano.ProtocolParameters;
}

const deserializeDatum = (tx: Cardano.HydratedTx) => {
  for (const output of tx.body.outputs)
    if (output.datum) output.datum = Serialization.PlutusData.fromCbor(output.datum as unknown as HexBlob).toCore();
};

const deserializeMetadata = (tx: Cardano.HydratedTx) => {
  if (tx.auxiliaryData)
    tx.auxiliaryData = {
      blob: new Map(
        (tx.auxiliaryData as unknown as MetadataDbModel[]).map((metadata) => {
          const bKey = BigInt(metadata[0]);

          return [bKey, Serialization.GeneralTransactionMetadata.fromCbor(metadata[1]).toCore().get(bKey)!] as const;
        })
      )
    };
};

const isEventError = (error: unknown): error is { error: Error } =>
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  typeof error === 'object' && !!error && (error as any).error instanceof Error;

export const isTxRelevant = (
  { body: { collaterals, collateralReturn, inputs, outputs }, inputSource }: Cardano.HydratedTx,
  addresses: Cardano.PaymentAddress[]
) =>
  inputSource === Cardano.InputSource.inputs
    ? inputs.some((input) => addresses.includes(input.address)) ||
      outputs.some((output) => addresses.includes(output.address))
    : collaterals!.some((input) => addresses.includes(input.address)) ||
      (collateralReturn && addresses.includes(collateralReturn.address));

const removeRolledBackTxs = (txs: Txs, blockNo: Cardano.BlockNo) => {
  let id: Cardano.TransactionId;

  for (id in txs) if (txs[id].blockHeader.blockNo > blockNo) delete txs[id];
};

interface EmitHealthOptions {
  notRecoverable?: boolean;
  overwrite?: boolean;
}

interface WSHealthCheckResponse extends HealthCheckResponse {
  notRecoverable?: boolean;
}

export class WsProvider implements Provider {
  /** Emits the health state. */
  public health$: Observable<WSHealthCheckResponse>;

  private healthSubject$: ReplaySubject<WSHealthCheckResponse>;
  private notRecoverable?: boolean;
  private reason?: string;

  constructor() {
    this.health$ = this.healthSubject$ = new ReplaySubject<WSHealthCheckResponse>(1);
    this.healthSubject$.next({ ok: false, reason: 'starting' });
  }

  protected emitHealth(reason?: string | HealthCheckResponse, { notRecoverable, overwrite }: EmitHealthOptions = {}) {
    if (this.notRecoverable) return;

    if (!reason) {
      this.reason = undefined;

      return this.healthSubject$.next({ ok: true });
    }

    if (notRecoverable) this.notRecoverable = true;

    let result: WSHealthCheckResponse;

    if (typeof reason === 'string') {
      if (overwrite || !this.reason) this.reason = reason;

      result = { notRecoverable: this.notRecoverable, ok: false, reason: this.reason };
    } else result = reason;

    this.healthSubject$.next(result);
  }

  public healthCheck() {
    return firstValueFrom(this.health$);
  }
}

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

  /** WebSocket based `UtxoProvider` implementation. */
  utxoProvider: UtxoProvider;

  private addresses: { [key: Cardano.PaymentAddress]: AddressStatus } = {};
  private closePromise: Promise<void>;
  private closeResolver: () => void;
  private deferredRequests: DeferredRequests = { requests: [] };
  private epochSubject$: Subject<EpochRollover>;
  private handlers = new Map<number, WSHandler>();
  private heartbeatInterval: number;
  private heartbeatTimeout: NodeJS.Timeout | undefined;
  private logger: Logger;
  private requestId = 0;
  private status: WSStatus = 'idle';
  private transactions: Txs = {};
  private url: URL;
  private utxos: Txs = {};
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

    this.utxoProvider = {
      healthCheck: () => this.healthCheck(),
      utxoByAddresses: (args) => this.utxoByAddresses(args)
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

      return value as AsyncReturnType<NetworkInfoProvider[M]>;
    };
  }

  // eslint-disable-next-line sonarjs/cognitive-complexity
  private connect() {
    if (this.status !== 'stop') this.status = 'connecting';

    const ws = (this.ws = new WebSocket(this.url));

    // eslint-disable-next-line sonarjs/cognitive-complexity, complexity, max-statements
    ws.onmessage = (event) => {
      try {
        if (typeof event.data !== 'string') throw new Error('Unexpected data from WebSocket ');

        const message = fromSerializableObject<WSMessage>(JSON.parse(event.data));
        const { clientId, networkInfo, responseTo, syncing, transactions, utxos } = message;

        if (clientId) {
          this.logger.info(`Connected with clientId ${(this.clientId = clientId)}`);

          if (syncing) this.emitHealth('Server is still syncing', { overwrite: true });
          else this.emitHealth();
        }

        if (transactions)
          for (const tx of transactions) {
            deserializeDatum(tx);
            deserializeMetadata(tx);
            this.transactions[tx.id] = tx;
            delete this.utxos[tx.id];
          }

        if (utxos)
          for (const tx of utxos)
            if (!this.transactions[tx.id]) {
              deserializeDatum(tx);
              this.utxos[tx.id] = tx;
            }

        // Handle networkInfo as last one
        if (networkInfo) {
          const { eraSummaries, genesisParameters, ledgerTip, lovelaceSupply, protocolParameters, stake } = networkInfo;

          if (eraSummaries) this.networkInfoSubjects.eraSummaries$.next(eraSummaries);
          if (genesisParameters) this.networkInfoSubjects.genesisParameters$.next(genesisParameters);
          if (lovelaceSupply) this.networkInfoSubjects.lovelaceSupply$.next(lovelaceSupply);
          if (protocolParameters) this.networkInfoSubjects.protocolParameters$.next(protocolParameters);
          if (stake) this.networkInfoSubjects.stake$.next(stake);

          // Emit ledgerTip as last one
          if (ledgerTip) {
            removeRolledBackTxs(this.transactions, ledgerTip.blockNo);
            removeRolledBackTxs(this.utxos, ledgerTip.blockNo);

            this.networkInfoSubjects.ledgerTip$.next(ledgerTip);
          }

          // If it is an epoch rollover, emit it
          if (eraSummaries && ledgerTip && lovelaceSupply && protocolParameters && !clientId) {
            const epochInfo = createSlotEpochInfoCalc(eraSummaries)(ledgerTip.slot);

            this.epochSubject$.next({ epochInfo, eraSummaries, ledgerTip, lovelaceSupply, protocolParameters });
          }
        }

        if (responseTo) {
          const handler = this.handlers.get(responseTo);

          if (handler) {
            const { error } = message;

            this.handlers.delete(responseTo);
            error ? handler(error) : handler(undefined, message);
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
        const timeout = setTimeout(() => this.connect(), 1000);
        if (typeof timeout.unref === 'function') timeout.unref();
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
      this.emitHealth(err.message, { overwrite: true });

      for (const handler of this.handlers.values()) handler(err);
      this.handlers.clear();
      this.addresses = {};
      this.transactions = {};
    };

    ws.onopen = () => {
      if (this.status !== 'stop') this.status = 'connected';
      this.heartbeat();
    };
  }

  private heartbeat() {
    if (this.heartbeatTimeout) clearInterval(this.heartbeatTimeout);

    this.heartbeatTimeout = setTimeout(() => {
      try {
        this.request({});
      } catch (error) {
        this.logger.error(error, 'Error while refreshing heartbeat', this.clientId);
      }
    }, this.heartbeatInterval);
    if (typeof this.heartbeatTimeout.unref === 'function') this.heartbeatTimeout.unref();
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
      const lower = blockRange?.lowerBound || (0 as Cardano.BlockNo);
      const upper = blockRange?.upperBound || Number.POSITIVE_INFINITY;
      const requestAddresses: Cardano.PaymentAddress[] = [];
      const request = { addresses: requestAddresses, lower };

      const complete = (error?: Error) => {
        if (error) {
          for (const address of requestAddresses) delete this.addresses[address];

          return reject(error);
        }

        const transactions = Object.values(this.transactions)
          .filter(({ blockHeader: { blockNo } }) => lower <= blockNo && blockNo <= upper)
          .filter((tx) => isTxRelevant(tx, addresses))
          .sort((a, b) => a.blockHeader.blockNo - b.blockHeader.blockNo || a.index - b.index);

        const first = pagination?.startAt || 0;
        const last = first + (pagination?.limit || Number.POSITIVE_INFINITY);

        const pageResults = transactions.filter((_, i) => first <= i && i < last);

        resolve({ pageResults, totalResultCount: transactions.length });
      };

      // Check which addresses require sync
      for (const address of addresses) {
        const status = this.addresses[address];
        let toSend = false;

        if (status) {
          if (status.status === 'syncing')
            return complete(new ProviderError(ProviderFailure.Conflict, null, `${address} still loading`));
          if (lower < status.lower) toSend = true;
        } else toSend = true;

        if (toSend) {
          requestAddresses.push(address);
          this.addresses[address] = { lower, status: 'syncing' };
        }
      }

      firstValueFrom(this.health$.pipe(filter(({ reason }) => reason !== 'starting')))
        .then(({ ok, reason }) => {
          if (!ok) return complete(new ProviderError(ProviderFailure.ConnectionFailure, undefined, reason));

          // If no addresses need to be synced, just run complete
          if (requestAddresses.length === 0) return complete();

          this.deferRequest(request, (error) => {
            if (error) return complete(new ProviderError(ProviderFailure.ConnectionFailure, error, error.message));

            for (const address of requestAddresses) this.addresses[address].status = 'synced';

            complete();
          });
        })
        // This should actually never happen
        .catch(complete);
    });
  }

  private deferRequest(txsByAddresses: TxsByAddresses, complete: (error?: Error) => void) {
    const { requests, timeout } = this.deferredRequests;

    if (timeout) clearTimeout(timeout);

    requests.push({ complete, txsByAddresses });

    this.deferredRequests.timeout = setTimeout(() => {
      this.deferredRequests = { requests: [] };
      this.request(
        {
          txsByAddresses: requests.reduce(
            (prev, { txsByAddresses: { addresses, lower } }) => ({
              addresses: [...prev.addresses, ...addresses],
              lower: prev.lower < lower ? prev.lower : lower
            }),
            { addresses: [], lower: Number.POSITIVE_INFINITY as Cardano.BlockNo } as TxsByAddresses
          )
        },
        // eslint-disable-next-line @typescript-eslint/no-shadow, unicorn/no-array-for-each
        (error) => requests.forEach(({ complete }) => complete(error))
      );
    }, 3);
  }

  // eslint-disable-next-line sonarjs/cognitive-complexity, complexity
  private utxoByAddresses({ addresses }: UtxoByAddressesArgs) {
    for (const address of addresses) {
      const status = this.addresses[address];

      if (!status)
        return Promise.reject(new ProviderError(ProviderFailure.NotImplemented, null, `${address} not loaded`));

      if (status.status === 'syncing')
        return Promise.reject(new ProviderError(ProviderFailure.Conflict, null, `${address} still loading`));
    }

    const result: [Cardano.HydratedTxIn, Cardano.TxOut][] = [];
    const transactions = [...Object.values(this.utxos), ...Object.values(this.transactions)]
      .filter((tx) => isTxRelevant(tx, addresses))
      .sort((a, b) => a.blockHeader.blockNo - b.blockHeader.blockNo || a.index - b.index);

    for (let txOutIdx = 0; txOutIdx < transactions.length; ++txOutIdx) {
      const txOut = transactions[txOutIdx];

      for (let txOutOutIdx = 0; txOutOutIdx < txOut.body.outputs.length; ++txOutOutIdx) {
        const txOutput = txOut.body.outputs[txOutOutIdx];

        if (addresses.includes(txOutput.address)) {
          let unspent = true;

          for (let txInIdx = txOutIdx + 1; txInIdx < transactions.length && unspent; ++txInIdx) {
            const txIn = transactions[txInIdx];

            for (let txInInIdx = 0; txInInIdx < txIn.body.inputs.length && unspent; ++txInInIdx) {
              const txInput = txIn.body.inputs[txInInIdx];

              if (txInput.txId === txOut.id && txInput.index === txOutOutIdx) unspent = false;
            }
          }

          if (unspent) result.push([{ address: txOutput.address, index: txOutOutIdx, txId: txOut.id }, txOutput]);
        }
      }
    }

    return Promise.resolve(result);
  }
}
