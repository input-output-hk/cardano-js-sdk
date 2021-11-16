import { Cardano, StakePoolSearchProvider, WalletProvider } from '@cardano-sdk/core';
import { DelegationTracker, TransactionsTracker } from '../types';
import { KeyManager } from '../../KeyManagement';
import { Observable, map, of, share, switchMap } from 'rxjs';
import {
  ObservableStakePoolSearchProvider,
  createQueryStakePoolsProvider,
  createRewardAccountsTracker
} from './RewardAccounts';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { RewardsHistoryProvider, createRewardsHistoryProvider, createRewardsHistoryTracker } from './RewardsHistory';
import { TrackerSubject, coldObservableProvider } from '../util';
import { TxWithEpoch } from './types';
import { transactionsWithCertificates } from './transactionCertificates';

export const createBlockEpochProvider =
  (walletProvider: WalletProvider, retryBackoffConfig: RetryBackoffConfig) => (blockHashes: Cardano.Hash16[]) =>
    coldObservableProvider(() => walletProvider.queryBlocksByHashes(blockHashes), retryBackoffConfig).pipe(
      map((blocks) => blocks.map(({ epoch }) => epoch))
    );

export type BlockEpochProvider = ReturnType<typeof createBlockEpochProvider>;

export interface DelegationTrackerProps {
  walletProvider: WalletProvider;
  keyManager: KeyManager;
  stakePoolSearchProvider: StakePoolSearchProvider;
  epoch$: Observable<Cardano.Epoch>;
  transactionsTracker: TransactionsTracker;
  retryBackoffConfig: RetryBackoffConfig;
  internals?: {
    queryStakePoolsProvider?: ObservableStakePoolSearchProvider;
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
      blockEpochProvider(transactions.map((tx) => tx.blockHeader.blockHash)).pipe(
        map((epochs) => transactions.map((tx, txIndex) => ({ epoch: epochs[txIndex], tx })))
      )
    ),
    share()
  );

export const createDelegationTracker = ({
  keyManager,
  epoch$,
  walletProvider,
  retryBackoffConfig,
  transactionsTracker,
  stakePoolSearchProvider,
  internals: {
    queryStakePoolsProvider = createQueryStakePoolsProvider(stakePoolSearchProvider, retryBackoffConfig),
    rewardsHistoryProvider = createRewardsHistoryProvider(walletProvider, keyManager, retryBackoffConfig),
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
    createRewardAccountsTracker(
      of([keyManager.rewardAccount]),
      queryStakePoolsProvider,
      epoch$,
      transactions$,
      transactionsTracker.outgoing.inFlight$
    )
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
