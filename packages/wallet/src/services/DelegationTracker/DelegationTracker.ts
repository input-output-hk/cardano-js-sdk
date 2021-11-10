import { Cardano, StakePoolSearchProvider, WalletProvider } from '@cardano-sdk/core';
import { CertificateType, Epoch } from '@cardano-sdk/core/src/Cardano';
import { Delegation, Transactions } from '../types';
import { KeyManager } from '../../KeyManagement';
import { Observable, distinctUntilChanged, filter, map, share, switchMap } from 'rxjs';
import { ObservableStakePoolSearchProvider, createDelegateeTracker, createQueryStakePoolsProvider } from './Delegatee';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { RewardsHistoryProvider, createRewardsHistoryTracker } from './RewardsHistory';
import { TrackerSubject, coldObservableProvider, transactionsEquals } from '../util';
import { TxWithEpoch, transactionHasAnyCertificate } from './util';
import { createRewardsHistoryProvider } from '.';

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
  epoch$: Observable<Epoch>;
  transactionsTracker: Transactions;
  retryBackoffConfig: RetryBackoffConfig;
  internals?: {
    queryStakePoolsProvider?: ObservableStakePoolSearchProvider;
    rewardsHistoryProvider?: RewardsHistoryProvider;
    blockEpochProvider?: BlockEpochProvider;
  };
}

export const certificateTransactionsWithEpochs = (
  transactionsTracker: Transactions,
  blockEpochProvider: BlockEpochProvider,
  certificateTypes: Cardano.CertificateType[]
): Observable<TxWithEpoch[]> =>
  transactionsTracker.history.outgoing$.pipe(
    map((transactions) => transactions.filter((tx) => transactionHasAnyCertificate(tx, certificateTypes))),
    distinctUntilChanged(transactionsEquals),
    filter((transactions) => transactions.length > 0),
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
}: DelegationTrackerProps): Delegation => {
  const transactions$ = certificateTransactionsWithEpochs(transactionsTracker, blockEpochProvider, [
    CertificateType.StakeDelegation,
    CertificateType.StakeRegistration,
    CertificateType.StakeDeregistration
  ]);
  const rewardsHistory$ = new TrackerSubject(createRewardsHistoryTracker(transactions$, rewardsHistoryProvider));
  const delegatee$ = new TrackerSubject(createDelegateeTracker(queryStakePoolsProvider, epoch$, transactions$));
  return {
    delegatee$,
    rewardsHistory$,
    shutdown: () => {
      rewardsHistory$.complete();
      delegatee$.complete();
    }
  };
};
