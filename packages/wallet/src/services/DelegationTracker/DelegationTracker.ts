import {
  Cardano,
  SlotEpochCalc,
  StakePoolSearchProvider,
  TimeSettings,
  WalletProvider,
  createSlotEpochCalc
} from '@cardano-sdk/core';
import { DelegationTracker, TransactionsTracker } from '../types';
import { Observable, combineLatest, map } from 'rxjs';
import {
  ObservableRewardsProvider,
  ObservableStakePoolSearchProvider,
  createQueryStakePoolsProvider,
  createRewardAccountsTracker,
  createRewardsProvider
} from './RewardAccounts';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { RewardsHistoryProvider, createRewardsHistoryProvider, createRewardsHistoryTracker } from './RewardsHistory';
import { TrackedWalletProvider } from '../ProviderTracker';
import { TrackerSubject, coldObservableProvider } from '../util';
import { TxWithEpoch } from './types';
import { WalletStores } from '../../persistence';
import { transactionsWithCertificates } from './transactionCertificates';

export const createBlockEpochProvider =
  (walletProvider: WalletProvider, retryBackoffConfig: RetryBackoffConfig) => (blockHashes: Cardano.BlockId[]) =>
    coldObservableProvider(() => walletProvider.blocksByHashes(blockHashes), retryBackoffConfig).pipe(
      map((blocks) => blocks.map(({ epoch }) => epoch))
    );

export type BlockEpochProvider = ReturnType<typeof createBlockEpochProvider>;

export interface DelegationTrackerProps {
  walletProvider: TrackedWalletProvider;
  rewardAccountAddresses$: Observable<Cardano.RewardAccount[]>;
  stakePoolSearchProvider: StakePoolSearchProvider;
  timeSettings$: Observable<TimeSettings[]>;
  epoch$: Observable<Cardano.Epoch>;
  transactionsTracker: TransactionsTracker;
  retryBackoffConfig: RetryBackoffConfig;
  stores: WalletStores;
  internals?: {
    queryStakePoolsProvider?: ObservableStakePoolSearchProvider;
    rewardsProvider?: ObservableRewardsProvider;
    rewardsHistoryProvider?: RewardsHistoryProvider;
    slotEpochCalc$?: Observable<SlotEpochCalc>;
  };
}

export const certificateTransactionsWithEpochs = (
  transactionsTracker: TransactionsTracker,
  slotEpochCalc$: Observable<SlotEpochCalc>,
  certificateTypes: Cardano.CertificateType[]
): Observable<TxWithEpoch[]> =>
  combineLatest([
    transactionsWithCertificates(transactionsTracker.history.outgoing$, certificateTypes),
    slotEpochCalc$
  ]).pipe(
    map(([transactions, slotEpochCalc]) =>
      transactions.map((tx) => ({ epoch: slotEpochCalc(tx.blockHeader.slot), tx }))
    )
  );

export const createDelegationTracker = ({
  rewardAccountAddresses$,
  epoch$,
  walletProvider,
  retryBackoffConfig,
  transactionsTracker,
  timeSettings$,
  stakePoolSearchProvider,
  stores,
  internals: {
    queryStakePoolsProvider = createQueryStakePoolsProvider(
      stakePoolSearchProvider,
      stores.stakePools,
      retryBackoffConfig
    ),
    rewardsHistoryProvider = createRewardsHistoryProvider(walletProvider, retryBackoffConfig),
    rewardsProvider = createRewardsProvider(
      epoch$,
      transactionsTracker.outgoing.confirmed$,
      walletProvider,
      retryBackoffConfig
    ),
    slotEpochCalc$ = timeSettings$.pipe(map((timeSettings) => createSlotEpochCalc(timeSettings)))
  } = {}
}: DelegationTrackerProps): DelegationTracker => {
  const transactions$ = certificateTransactionsWithEpochs(transactionsTracker, slotEpochCalc$, [
    Cardano.CertificateType.StakeDelegation,
    Cardano.CertificateType.StakeKeyRegistration,
    Cardano.CertificateType.StakeKeyDeregistration
  ]);
  const rewardsHistory$ = new TrackerSubject(
    createRewardsHistoryTracker(transactions$, rewardAccountAddresses$, rewardsHistoryProvider, stores.rewardsHistory)
  );
  const rewardAccounts$ = new TrackerSubject(
    createRewardAccountsTracker({
      balancesStore: stores.rewardsBalances,
      epoch$,
      rewardAccountAddresses$,
      rewardsProvider,
      stakePoolSearchProvider: queryStakePoolsProvider,
      transactions$,
      transactionsInFlight$: transactionsTracker.outgoing.inFlight$
    })
  );
  return {
    rewardAccounts$,
    rewardsHistory$,
    shutdown: () => {
      rewardAccounts$.complete();
      rewardsHistory$.complete();
    }
  };
};
