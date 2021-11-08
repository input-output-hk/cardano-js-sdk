import { BehaviorObservable } from './util';
import { Cardano, EpochRewards } from '@cardano-sdk/core';
import { Observable } from 'rxjs';
import { TransactionFailure } from './TransactionError';

export interface Balance extends Cardano.Value {
  rewards: Cardano.Lovelace;
}

export interface ProviderSubscription {
  sync(): void;
  shutdown(): void;
}

export interface TransactionalTracker<T> {
  total$: BehaviorObservable<T>;
  available$: BehaviorObservable<T>;
}

export type Milliseconds = number;

export type SourceTransactionalTracker<T> = ProviderSubscription & TransactionalTracker<T>;
export interface PollingConfig {
  readonly interval: Milliseconds;
  /**
   * Max timeout for exponential backoff on errors
   */
  readonly maxInterval: Milliseconds;
}

export enum TransactionDirection {
  Incoming = 'Incoming',
  Outgoing = 'Outgoing'
}

export interface DirectionalTransaction {
  tx: Cardano.TxAlonzo;
  direction: TransactionDirection;
}

export interface FailedTx {
  tx: Cardano.NewTxAlonzo;
  reason: TransactionFailure;
}

export interface Transactions extends ProviderSubscription {
  readonly history: {
    all$: BehaviorObservable<DirectionalTransaction[]>;
    outgoing$: BehaviorObservable<Cardano.TxAlonzo[]>;
    incoming$: BehaviorObservable<Cardano.TxAlonzo[]>;
  };
  readonly outgoing: {
    readonly inFlight$: BehaviorObservable<Cardano.NewTxAlonzo[]>;
    readonly submitting$: Observable<Cardano.NewTxAlonzo>;
    readonly pending$: Observable<Cardano.NewTxAlonzo>;
    readonly failed$: Observable<FailedTx>;
    readonly confirmed$: Observable<Cardano.NewTxAlonzo>;
  };
  readonly incoming$: Observable<Cardano.TxAlonzo>;
}

export interface RewardsHistory {
  all: EpochRewards[];
  lastReward: EpochRewards | null;
  avgReward: Cardano.Lovelace | null;
  lifetimeRewards: Cardano.Lovelace;
}

export interface Delegatee {
  currentEpoch: Cardano.StakePool;
  nextEpoch: Cardano.StakePool;
  nextNextEpoch: Cardano.StakePool;
}

export interface Delegation extends ProviderSubscription {
  rewardsHistory$: BehaviorObservable<RewardsHistory>;
  delegatee$: BehaviorObservable<Delegatee>;
}

export type SimpleProvider<T> = () => Observable<T>;
export type ProviderWithArg<T, A> = (arg: A) => Observable<T>;
