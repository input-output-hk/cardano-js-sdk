import { BehaviorObservable } from './util';
import { Cardano, EpochRewards } from '@cardano-sdk/core';
import { Observable } from 'rxjs';

export enum TransactionFailure {
  InvalidTransaction = 'INVALID_TRANSACTION',
  FailedToSubmit = 'FAILED_TO_SUBMIT',
  Unknown = 'UNKNOWN',
  CannotTrack = 'CANNOT_TRACK',
  Timeout = 'TIMEOUT'
}

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
  readonly consideredOutOfSyncAfter?: Milliseconds;
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
  error?: Cardano.TxSubmissionError;
}

export interface TransactionsTracker {
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
  /**
   * Rewards at the end of current epoch will
   * be from this stake pool
   */
  currentEpoch?: Cardano.StakePool;
  nextEpoch?: Cardano.StakePool;
  nextNextEpoch: Cardano.StakePool;
}

export enum StakeKeyStatus {
  Registering = 'REGISTERING',
  Registered = 'REGISTERED',
  Unregistering = 'UNREGISTERING',
  Unregistered = 'UNREGISTERED'
}

export interface RewardBalance {
  total: Cardano.Lovelace;
  available: Cardano.Lovelace;
}
export interface RewardAccount {
  address: Cardano.RewardAccount;
  keyStatus: StakeKeyStatus;
  delegatee?: Delegatee;
  rewardBalance: RewardBalance;
  // Maybe add rewardsHistory for each reward account too
}

export interface DelegationTracker {
  rewardsHistory$: BehaviorObservable<RewardsHistory>;
  rewardAccounts$: Observable<RewardAccount[]>;
  shutdown(): void;
}
