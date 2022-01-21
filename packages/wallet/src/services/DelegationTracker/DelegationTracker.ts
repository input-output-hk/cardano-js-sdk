import { Cardano, StakePoolSearchProvider, WalletProvider } from '@cardano-sdk/core';
import { DelegationTracker, TransactionsTracker } from '../types';
import { Observable, map, share, switchMap } from 'rxjs';
import {
  ObservableRewardsProvider,
  ObservableStakePoolSearchProvider,
  createQueryStakePoolsProvider,
  createRewardAccountsTracker,
  createRewardsProvider
} from './RewardAccounts';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { RewardsHistoryProvider, createRewardsHistoryProvider, createRewardsHistoryTracker } from './RewardsHistory';
import { TrackerSubject, coldObservableProvider } from '../util';
import { TxWithEpoch } from './types';
import { transactionsWithCertificates } from './transactionCertificates';

export const createBlockEpochProvider =
  (walletProvider: WalletProvider, retryBackoffConfig: RetryBackoffConfig) => (blockHashes: Cardano.BlockId[]) =>
    coldObservableProvider(() => walletProvider.queryBlocksByHashes(blockHashes), retryBackoffConfig).pipe(
      map((blocks) => blocks.map(({ epoch }) => epoch))
    );

export type BlockEpochProvider = ReturnType<typeof createBlockEpochProvider>;

export interface DelegationTrackerProps {
  walletProvider: WalletProvider;
  rewardAccountAddresses$: Observable<Cardano.RewardAccount[]>;
  stakePoolSearchProvider: StakePoolSearchProvider;
  epoch$: Observable<Cardano.Epoch>;
  transactionsTracker: TransactionsTracker;
  retryBackoffConfig: RetryBackoffConfig;
  internals?: {
    queryStakePoolsProvider?: ObservableStakePoolSearchProvider;
    rewardsProvider?: ObservableRewardsProvider;
    rewardsHistoryProvider?: RewardsHistoryProvider;
    blockEpochProvider?: BlockEpochProvider;
  };
}

export const certificateTransactionsWithEpochs = (
  transactionsTracker: TransactionsTracker,
  blockEpochProvider: BlockEpochProvider,
  certificateTypes: Cardano.CertificateType[]
): Observable<TxWithEpoch[]> =>
  transactionsWithCertificates(transactionsTracker.history.outgoing$, certificateTypes).pipe(
    switchMap((transactions) =>
      blockEpochProvider(transactions.map((tx) => tx.blockHeader.hash)).pipe(
        map((epochs) => transactions.map((tx, txIndex) => ({ epoch: epochs[txIndex], tx })))
      )
    ),
    share()
  );

export const createDelegationTracker = ({
  rewardAccountAddresses$,
  epoch$,
  walletProvider,
  retryBackoffConfig,
  transactionsTracker,
  stakePoolSearchProvider,
  internals: {
    queryStakePoolsProvider = createQueryStakePoolsProvider(stakePoolSearchProvider, retryBackoffConfig),
    rewardsHistoryProvider = createRewardsHistoryProvider(walletProvider, rewardAccountAddresses$, retryBackoffConfig),
    rewardsProvider = createRewardsProvider(
      epoch$,
      transactionsTracker.outgoing.confirmed$,
      walletProvider,
      retryBackoffConfig
    ),
    blockEpochProvider = createBlockEpochProvider(walletProvider, retryBackoffConfig)
  } = {}
}: DelegationTrackerProps): DelegationTracker => {
  const transactions$ = certificateTransactionsWithEpochs(transactionsTracker, blockEpochProvider, [
    Cardano.CertificateType.StakeDelegation,
    Cardano.CertificateType.StakeKeyRegistration,
    Cardano.CertificateType.StakeKeyDeregistration
  ]);
  const rewardsHistory$ = new TrackerSubject(createRewardsHistoryTracker(transactions$, rewardsHistoryProvider));
  const rewardAccounts$ = new TrackerSubject(
    createRewardAccountsTracker({
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
