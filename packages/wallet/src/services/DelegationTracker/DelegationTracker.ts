import {
  Cardano,
  SlotEpochCalc,
  StakePoolProvider,
  TimeSettings,
  WalletProvider,
  createSlotEpochCalc
} from '@cardano-sdk/core';
import { DelegationTracker, TransactionsTracker } from '../types';
import { Observable, combineLatest, map } from 'rxjs';
import {
  ObservableRewardsProvider,
  ObservableStakePoolProvider,
  createQueryStakePoolsProvider,
  createRewardAccountsTracker,
  createRewardsProvider
} from './RewardAccounts';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { RewardsHistoryProvider, createRewardsHistoryProvider, createRewardsHistoryTracker } from './RewardsHistory';
import { Shutdown } from '@cardano-sdk/util';
import { TrackedWalletProvider } from '../ProviderTracker';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import { TxWithEpoch } from './types';
import { WalletStores } from '../../persistence';
import { coldObservableProvider } from '../util';
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
  stakePoolProvider: StakePoolProvider;
  timeSettings$: Observable<TimeSettings[]>;
  epoch$: Observable<Cardano.Epoch>;
  transactionsTracker: TransactionsTracker;
  retryBackoffConfig: RetryBackoffConfig;
  stores: WalletStores;
  internals?: {
    queryStakePoolsProvider?: ObservableStakePoolProvider;
    rewardsProvider?: ObservableRewardsProvider;
    rewardsHistoryProvider?: RewardsHistoryProvider;
    slotEpochCalc$?: Observable<SlotEpochCalc>;
  };
}

export const certificateTransactionsWithEpochs = (
  transactionsTracker: TransactionsTracker,
  rewardAccountAddresses$: Observable<Cardano.RewardAccount[]>,
  slotEpochCalc$: Observable<SlotEpochCalc>,
  certificateTypes: Cardano.CertificateType[]
): Observable<TxWithEpoch[]> =>
  combineLatest([
    transactionsWithCertificates(transactionsTracker.history$, rewardAccountAddresses$, certificateTypes),
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
  stakePoolProvider,
  stores,
  internals: {
    queryStakePoolsProvider = createQueryStakePoolsProvider(stakePoolProvider, stores.stakePools, retryBackoffConfig),
    rewardsHistoryProvider = createRewardsHistoryProvider(walletProvider, retryBackoffConfig),
    rewardsProvider = createRewardsProvider(
      epoch$,
      transactionsTracker.outgoing.confirmed$,
      walletProvider,
      retryBackoffConfig
    ),
    slotEpochCalc$ = timeSettings$.pipe(map((timeSettings) => createSlotEpochCalc(timeSettings)))
  } = {}
}: DelegationTrackerProps): DelegationTracker & Shutdown => {
  const transactions$ = certificateTransactionsWithEpochs(
    transactionsTracker,
    rewardAccountAddresses$,
    slotEpochCalc$,
    [
      Cardano.CertificateType.StakeDelegation,
      Cardano.CertificateType.StakeKeyRegistration,
      Cardano.CertificateType.StakeKeyDeregistration
    ]
  );
  const rewardsHistory$ = new TrackerSubject(
    createRewardsHistoryTracker(transactions$, rewardAccountAddresses$, rewardsHistoryProvider, stores.rewardsHistory)
  );
  const rewardAccounts$ = new TrackerSubject(
    createRewardAccountsTracker({
      balancesStore: stores.rewardsBalances,
      epoch$,
      rewardAccountAddresses$,
      rewardsProvider,
      stakePoolProvider: queryStakePoolsProvider,
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
