import { BehaviorObservable } from './util';
import { Cardano, EpochRewards } from '@cardano-sdk/core';
import { Observable } from 'rxjs';
import { TransactionFailure } from './TransactionError';

export interface Balance extends Cardano.Value {
  rewards: Cardano.Lovelace;
  deposit: Cardano.Lovelace;
}

export interface TransactionalObservables<T> {
  total$: BehaviorObservable<T>;
  available$: BehaviorObservable<T>;
}

export interface TransactionalTracker<T> extends TransactionalObservables<T> {
  shutdown(): void;
}

export type Milliseconds = number;

export interface PollingConfig {
  readonly interval?: Milliseconds;
  /**
   * Max timeout for exponential backoff on errors
   */
  readonly maxInterval?: Milliseconds;
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

// TODO: rename -> TransactionsTracker
export interface Transactions {
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
  shutdown(): void;
}

export interface RewardsHistory {
  all: EpochRewards[];
  lastReward: EpochRewards | null;
  avgReward: Cardano.Lovelace | null;
  lifetimeRewards: Cardano.Lovelace;
}

export interface Delegatee {
  currentEpoch: Cardano.StakePool | null;
  nextEpoch: Cardano.StakePool | null;
  nextNextEpoch: Cardano.StakePool | null;
}

export enum DelegationKeyStatus {
  Registering = 'REGISTERING',
  Registered = 'REGISTERED',
  Unregistering = 'UNREGISTERING',
  Unregistered = 'UNREGISTERED'
}

export interface RewardAccount {
  address: Cardano.Address;
  keyStatus: DelegationKeyStatus;
  // Maybe add rewardsHistory$ and delegatee$ for each reward account too
}

// TODO: rename -> DelegationTracker
export interface Delegation {
  rewardsHistory$: BehaviorObservable<RewardsHistory>;
  delegatee$: BehaviorObservable<Delegatee>;
  rewardAccounts$: BehaviorObservable<RewardAccount[]>;
  shutdown(): void;
}
