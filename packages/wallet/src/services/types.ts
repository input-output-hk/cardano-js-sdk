import { Cardano, CardanoNodeErrors, EpochRewards, TxCBOR } from '@cardano-sdk/core';
import { Observable } from 'rxjs';

export enum TransactionFailure {
  InvalidTransaction = 'INVALID_TRANSACTION',
  FailedToSubmit = 'FAILED_TO_SUBMIT',
  Unknown = 'UNKNOWN',
  CannotTrack = 'CANNOT_TRACK',
  Timeout = 'TIMEOUT',
  Phase2Validation = 'PHASE_2_VALIDATION'
}

export interface TransactionalObservables<T> {
  total$: Observable<T>;
  /**
   * total - unspendable
   */
  available$: Observable<T>;
  unspendable$: Observable<T>;
}

export interface BalanceTracker {
  rewardAccounts: {
    rewards$: Observable<Cardano.Lovelace>;
    deposit$: Observable<Cardano.Lovelace>;
  };
  utxo: TransactionalObservables<Cardano.Value>;
}

export interface TransactionalTracker<T> extends TransactionalObservables<T> {
  shutdown(): void;
}

export interface UtxoTracker extends TransactionalTracker<Cardano.Utxo[]> {
  setUnspendable(utxo: Cardano.Utxo[]): Promise<void>;
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

export interface OutgoingTx {
  cbor: TxCBOR;
  body: Cardano.TxBody;
  id: Cardano.TransactionId;
}

export interface FailedTx extends OutgoingTx {
  reason: TransactionFailure;
  error?: CardanoNodeErrors.TxSubmissionError;
}

export interface ConfirmedTx extends OutgoingTx {
  confirmedAt: Cardano.PartialBlockHeader['slot'];
}

export interface TxInFlight extends OutgoingTx {
  submittedAt?: Cardano.PartialBlockHeader['slot'];
}

export interface TransactionsTracker {
  readonly history$: Observable<Cardano.HydratedTx[]>;
  readonly rollback$: Observable<Cardano.HydratedTx>;
  readonly outgoing: {
    readonly inFlight$: Observable<TxInFlight[]>;
    readonly submitting$: Observable<OutgoingTx>;
    readonly pending$: Observable<OutgoingTx>;
    readonly failed$: Observable<FailedTx>;
    readonly confirmed$: Observable<ConfirmedTx>;
  };
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
  nextNextEpoch?: Cardano.StakePool;
}

export enum StakeKeyStatus {
  Registering = 'REGISTERING',
  Registered = 'REGISTERED',
  Unregistering = 'UNREGISTERING',
  Unregistered = 'UNREGISTERED'
}

export interface RewardAccount {
  address: Cardano.RewardAccount;
  keyStatus: StakeKeyStatus;
  delegatee?: Delegatee;
  rewardBalance: Cardano.Lovelace;
  // Maybe add rewardsHistory for each reward account too
}

export interface DelegationTracker {
  rewardsHistory$: Observable<RewardsHistory>;
  rewardAccounts$: Observable<RewardAccount[]>;
}
