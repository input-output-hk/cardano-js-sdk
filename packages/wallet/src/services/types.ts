import type { Bip32Account, GroupedAddress, WitnessedTx } from '@cardano-sdk/key-management';
import type { Cardano, Reward, Serialization } from '@cardano-sdk/core';
import type { Observable } from 'rxjs';
import type { Percent } from '@cardano-sdk/util';

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
  /** total - unspendable */
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

/** The AddressDiscovery interface provides a mechanism to discover addresses in Hierarchical Deterministic (HD) wallets */
export interface AddressDiscovery {
  /**
   * Discover used addresses in the HD wallet.
   *
   * @param addressManager The address manager to be used to derive the addresses to be discovered.
   * @returns A promise that will be resolved into a GroupedAddress list containing the discovered addresses.
   */
  discover(addressManager: Bip32Account): Promise<GroupedAddress[]>;
}

export type Milliseconds = number;

export interface PollingConfig {
  readonly interval?: Milliseconds;
  /** Max timeout for exponential backoff on errors */
  readonly maxInterval?: Milliseconds;
  readonly consideredOutOfSyncAfter?: Milliseconds;
}

export interface OutgoingTx {
  cbor: Serialization.TxCBOR;
  body: Cardano.TxBody;
  id: Cardano.TransactionId;
  context?: WitnessedTx['context'];
}

export interface FailedTx extends OutgoingTx {
  reason: TransactionFailure;
  error?: unknown;
}

export interface OutgoingOnChainTx extends OutgoingTx {
  slot: Cardano.PartialBlockHeader['slot'];
}

export interface TxInFlight extends OutgoingTx {
  submittedAt?: Cardano.PartialBlockHeader['slot'];
}

export interface TransactionsTracker {
  readonly history$: Observable<Cardano.HydratedTx[]>;
  /** Transactions that are appended to history$ after initial load */
  readonly new$: Observable<Cardano.HydratedTx>;
  readonly rollback$: Observable<Cardano.HydratedTx>;
  readonly outgoing: {
    readonly inFlight$: Observable<TxInFlight[]>;
    readonly submitting$: Observable<OutgoingTx>;
    readonly pending$: Observable<OutgoingTx>;
    readonly signed$: Observable<WitnessedTx[]>;
    readonly failed$: Observable<FailedTx>;
    readonly onChain$: Observable<OutgoingOnChainTx>;
  };
}

export interface RewardsHistory {
  all: Reward[];
  lastReward: Reward | null;
  avgReward: Cardano.Lovelace | null;
  lifetimeRewards: Cardano.Lovelace;
}

/** Wallet delegated stake by pool. Multiple reward accounts could be delegated to the same pool */
export interface DelegatedStake {
  pool: Cardano.StakePool;
  /** How much from the total delegated stake is delegated to this pool */
  percentage: Percent;
  /** Absolute stake value */
  stake: bigint;
  /** Reward accounts delegated to this pool */
  rewardAccounts: Cardano.RewardAccount[];
}

export interface DelegationTracker {
  rewardsHistory$: Observable<RewardsHistory>;
  rewardAccounts$: Observable<Cardano.RewardAccountInfo[]>;
  distribution$: Observable<Map<Cardano.PoolId, DelegatedStake>>;
  portfolio$: Observable<Cardano.Cip17DelegationPortfolio | null>;
}
