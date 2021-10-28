import { Balance, Milliseconds, Transaction, TransactionFailure } from '..';
import { BehaviorObservable, ProviderSubscription } from '../services/util';
import { CSL, Cardano, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { Observable } from 'rxjs';
import { TxInternals } from '../Transaction';

export interface TransactionalTracker<T> {
  total$: BehaviorObservable<T>;
  available$: BehaviorObservable<T>;
}

export type SourceTransactionalTracker<T> = ProviderSubscription & TransactionalTracker<T>;
export interface PollingConfig {
  readonly interval: Milliseconds;
  /**
   * Max timeout for exponential backoff on errors
   */
  readonly maxInterval: Milliseconds;
}

export type NewTx = CSL.Transaction;
export interface FailedTx {
  tx: NewTx;
  reason: TransactionFailure;
}

export type SimpleProvider<T> = () => Observable<T>;

export interface FinalizeTxProps {
  readonly body: Cardano.TxBodyAlonzo;
}

export enum TransactionDirection {
  Incoming = 'Incoming',
  Outgoing = 'Outgoing'
}

export interface DirectionalTransaction {
  tx: Cardano.TxAlonzo;
  direction: TransactionDirection;
}
export interface Transactions extends ProviderSubscription {
  readonly history: {
    all$: BehaviorObservable<DirectionalTransaction[]>;
    outgoing$: BehaviorObservable<Cardano.TxAlonzo[]>;
    incoming$: BehaviorObservable<Cardano.TxAlonzo[]>;
  };
  readonly outgoing: {
    readonly inFlight$: BehaviorObservable<NewTx[]>;
    readonly submitting$: Observable<NewTx>;
    readonly pending$: Observable<NewTx>;
    readonly failed$: Observable<FailedTx>;
    readonly confirmed$: Observable<NewTx>;
  };
  readonly incoming$: Observable<Cardano.TxAlonzo>;
}

export interface Wallet extends ProviderSubscription {
  name: string;
  readonly balance: TransactionalTracker<Balance>;
  readonly utxo: SourceTransactionalTracker<Cardano.Utxo[]>;
  readonly transactions: Transactions;
  readonly tip$: BehaviorObservable<Cardano.Tip>;
  readonly protocolParameters$: BehaviorObservable<ProtocolParametersRequiredByWallet>;
  get addresses(): Cardano.Address[];
  initializeTx(props: Transaction.InitializeTxProps): Promise<TxInternals>;
  finalizeTx(props: TxInternals): Promise<NewTx>;
  submitTx(tx: NewTx): Promise<void>;
}
